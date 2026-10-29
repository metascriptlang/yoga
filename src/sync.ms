// Generic layout pass over any host node tree — the cross-module convention
// protocol from recompiler docs/PROTOCOLS.md Part II (Nim mixin semantics).
//
// A host opts in by defining SEVEN exported extensions on its node type T:
//
//   export function layoutGetChildren(this n: T): T[]
//   export function layoutGetStyle(this n: T): FlexStyle | null
//   export function layoutGetLastStyle(this n: T): FlexStyle | null
//   export function layoutSetLastStyle(this n: T, s: FlexStyle | null): void
//   export function layoutGetYg(this n: T): Ptr<YGNode> | null
//   export function layoutSetYg(this n: T, yg: Ptr<YGNode> | null): void
//   export function layoutSetFrame(this n: T, x: float32, y: float32, w: float32, h: float32): void
//
// `export` is required: the monomorphized pass is emitted in THIS module's TU
// and calls the extensions cross-TU. A node whose layoutGetStyle() is null
// keeps manual positioning and is invisible to yoga. Style objects are
// compared by REFERENCE — restyle by assigning a fresh FlexStyle, never by
// mutating the old one. Copy-back is gated on hasNewLayout, so a stable
// subtree costs one flag check per frame.
//
// Known gap (same as before the DRY refactor): reparenting a laid-out node
// between two islands within one frame can trip yoga's single-owner assert —
// detach via freeLayoutTree first.

import { Direction, directionToC } from "./enums";
import {
	YGNode,
	YGConfig,
	YGConfigNew,
	YGConfigSetPointScaleFactor,
	YGNodeNewWithConfig,
	YGNodeGetConfig,
	YGNodeSetConfig,
	YGNodeFreeRecursive,
	YGNodeCalculateLayout,
	YGNodeInsertChild,
	YGNodeRemoveChild,
	YGNodeRemoveAllChildren,
	YGNodeGetChild,
	YGNodeGetChildCount,
	YGNodeGetParent,
	YGNodeLayoutGetLeft,
	YGNodeLayoutGetTop,
	YGNodeLayoutGetWidth,
	YGNodeLayoutGetHeight,
	YGNodeGetHasNewLayout,
	YGNodeSetHasNewLayout,
	YGNodeHasMeasureFunc,
	YGNodeMarkDirty,
} from "./yogaH";
import { applyStyle } from "./style";
import { releaseMeasures } from "./measure";

export function layoutPass<T>(
	root: T,
	availableWidth: float32,
	availableHeight: float32,
	direction: Direction = "ltr",
	pointScale: float32 = 1.0,
): void {
	if (root.layoutGetStyle() === null) return;
	const yg = syncLayoutNode(root, configFor(pointScale));
	YGNodeCalculateLayout(yg, availableWidth, availableHeight, directionToC(direction));
	copyBackLayout(root);
}

export function freeLayoutTree<T>(root: T): void {
	const yg = root.layoutGetYg();
	if (yg !== null) {
		const owner = YGNodeGetParent(yg);
		if (owner !== null) { YGNodeRemoveChild(owner, yg); }
		releaseMeasures(yg);
		YGNodeFreeRecursive(yg);
	}
	clearLayoutYg(root);
}

function clearLayoutYg<T>(n: T): void {
	n.layoutSetYg(null);
	n.layoutSetLastStyle(null);
	for (const c of n.layoutGetChildren()) { clearLayoutYg(c); }
}

const scaledConfigs = new Map<float32, Ptr<YGConfig>>();

function configFor(pointScale: float32): Ptr<YGConfig> {
	const known = scaledConfigs.get(pointScale);
	if (known !== undefined) return known;
	const made = YGConfigNew();
	YGConfigSetPointScaleFactor(made, pointScale);
	scaledConfigs.set(pointScale, made);
	return made;
}

export function markLayoutDirty<T>(n: T): void {
	const yg = n.layoutGetYg();
	if (yg === null) return;
	if (!YGNodeHasMeasureFunc(yg)) {
		throw new Error("yoga: markLayoutDirty on a node without a measure; restyle it instead");
	}
	YGNodeMarkDirty(yg);
}

function ensureLayoutYg<T>(n: T, config: Ptr<YGConfig>): Ptr<YGNode> {
	const cur = n.layoutGetYg();
	if (cur === null) {
		const fresh = YGNodeNewWithConfig(config);
		n.layoutSetYg(fresh);
		return fresh;
	}
	if (YGNodeGetConfig(cur) !== config) YGNodeSetConfig(cur, config);
	return cur;
}

function syncLayoutNode<T>(n: T, config: Ptr<YGConfig>): Ptr<YGNode> {
	const yg = ensureLayoutYg(n, config);
	const style = n.layoutGetStyle();
	if (style !== null && n.layoutGetLastStyle() !== style) {
		applyStyle(yg, style);
		n.layoutSetLastStyle(style);
	}
	let li: int32 = 0;
	let aligned = true;
	for (const c of n.layoutGetChildren()) {
		if (c.layoutGetStyle() === null) continue;
		if (YGNodeHasMeasureFunc(yg)) {
			throw new Error("yoga: a node with a measure is a leaf; it cannot lay out children");
		}
		const cyg = syncLayoutNode(c, config);
		if (aligned && YGNodeGetChild(yg, li as uint32) !== cyg) { aligned = false; }
		li += 1;
	}
	if (aligned && YGNodeGetChildCount(yg) === li as uint32) return yg;
	YGNodeRemoveAllChildren(yg);
	let i: int32 = 0;
	for (const c of n.layoutGetChildren()) {
		if (c.layoutGetStyle() === null) {
			if (c.layoutGetYg() !== null) { freeLayoutTree(c); }
			continue;
		}
		const cyg = c.layoutGetYg();
		if (cyg !== null) {
			YGNodeInsertChild(yg, cyg, i as uint32);
			i += 1;
		}
	}
	return yg;
}

function copyBackLayout<T>(n: T): void {
	const yg = n.layoutGetYg();
	if (yg === null) return;
	if (!YGNodeGetHasNewLayout(yg)) return;
	YGNodeSetHasNewLayout(yg, false);
	n.layoutSetFrame(
		YGNodeLayoutGetLeft(yg), YGNodeLayoutGetTop(yg),
		YGNodeLayoutGetWidth(yg), YGNodeLayoutGetHeight(yg));
	for (const c of n.layoutGetChildren()) {
		if (c.layoutGetStyle() !== null) copyBackLayout(c);
	}
}

// The same pass for a host whose node cannot hand out a child array, because the tree lives in a table and the
// node is a handle into it. Such a host defines `layoutChildCount(this n: T): int32` and
// `layoutChildAt(this n: T, i: int32): T` in place of `layoutGetChildren`, so a pass allocates nothing per node.
export function layoutPassAt<T>(
	root: T,
	availableWidth: float32,
	availableHeight: float32,
	direction: Direction = "ltr",
	pointScale: float32 = 1.0,
): void {
	if (root.layoutGetStyle() === null) return;
	const yg = syncLayoutNodeAt(root, configFor(pointScale));
	YGNodeCalculateLayout(yg, availableWidth, availableHeight, directionToC(direction));
	copyBackLayoutAt(root);
}

export function freeLayoutTreeAt<T>(root: T): void {
	const yg = root.layoutGetYg();
	if (yg !== null) {
		const owner = YGNodeGetParent(yg);
		if (owner !== null) { YGNodeRemoveChild(owner, yg); }
		YGNodeFreeRecursive(yg);
	}
	clearLayoutYgAt(root);
}

function clearLayoutYgAt<T>(n: T): void {
	n.layoutSetYg(null);
	n.layoutSetLastStyle(null);
	const count = n.layoutChildCount();
	for (let k: int32 = 0; k < count; k += 1) { clearLayoutYgAt(n.layoutChildAt(k)); }
}

function syncLayoutNodeAt<T>(n: T, config: Ptr<YGConfig>): Ptr<YGNode> {
	const yg = ensureLayoutYg(n, config);
	const style = n.layoutGetStyle();
	if (style !== null && n.layoutGetLastStyle() !== style) {
		applyStyle(yg, style);
		n.layoutSetLastStyle(style);
	}
	const count = n.layoutChildCount();
	let li: int32 = 0;
	let aligned = true;
	for (let k: int32 = 0; k < count; k += 1) {
		const c = n.layoutChildAt(k);
		if (c.layoutGetStyle() === null) continue;
		const cyg = syncLayoutNodeAt(c, config);
		if (aligned && YGNodeGetChild(yg, li as uint64) !== cyg) { aligned = false; }
		li += 1;
	}
	if (aligned && YGNodeGetChildCount(yg) === li as uint64) return yg;
	YGNodeRemoveAllChildren(yg);
	let i: int32 = 0;
	for (let k: int32 = 0; k < count; k += 1) {
		const c = n.layoutChildAt(k);
		if (c.layoutGetStyle() === null) {
			if (c.layoutGetYg() !== null) { freeLayoutTreeAt(c); }
			continue;
		}
		const cyg = c.layoutGetYg();
		if (cyg !== null) {
			YGNodeInsertChild(yg, cyg, i as uint64);
			i += 1;
		}
	}
	return yg;
}

function copyBackLayoutAt<T>(n: T): void {
	const yg = n.layoutGetYg();
	if (yg === null) return;
	if (!YGNodeGetHasNewLayout(yg)) return;
	YGNodeSetHasNewLayout(yg, false);
	n.layoutSetFrame(
		YGNodeLayoutGetLeft(yg), YGNodeLayoutGetTop(yg),
		YGNodeLayoutGetWidth(yg), YGNodeLayoutGetHeight(yg));
	const count = n.layoutChildCount();
	for (let k: int32 = 0; k < count; k += 1) {
		const c = n.layoutChildAt(k);
		if (c.layoutGetStyle() !== null) copyBackLayoutAt(c);
	}
}
