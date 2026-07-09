// Generic layout pass over any host node tree — the cross-module convention
// protocol from recompiler docs/PROTOCOLS.md Part II (Nim mixin semantics).
//
// A host opts in by defining SEVEN exported extensions on its node type T:
//
//   export function layoutGetChildren(this n: T): T[]
//   export function layoutGetStyle(this n: T): FlexStyle | null
//   export function layoutGetLastStyle(this n: T): FlexStyle | null
//   export function layoutSetLastStyle(this n: T, s: FlexStyle | null): void
//   export function layoutGetYg(this n: T): Ptr<void> | null
//   export function layoutSetYg(this n: T, yg: Ptr<void> | null): void
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

import { directionToC } from "./enums";
import {
	YGNodeNew, YGNodeFreeRecursive, YGNodeCalculateLayout,
	YGNodeInsertChild, YGNodeRemoveAllChildren, YGNodeGetChild, YGNodeGetChildCount,
	YGNodeLayoutGetLeft, YGNodeLayoutGetTop, YGNodeLayoutGetWidth, YGNodeLayoutGetHeight,
	YGNodeGetHasNewLayout, YGNodeSetHasNewLayout,
} from "./yogaH";
import { applyStyle } from "./style";

export function layoutPass<T>(root: T, availableWidth: float32, availableHeight: float32): void {
	if (root.layoutGetStyle() === null) return;
	const yg = syncLayoutNode(root);
	YGNodeCalculateLayout(yg, availableWidth, availableHeight, directionToC("ltr"));
	copyBackLayout(root);
}

export function freeLayoutTree<T>(root: T): void {
	const yg = root.layoutGetYg();
	if (yg !== null) { YGNodeFreeRecursive(yg); }
	clearLayoutYg(root);
}

function clearLayoutYg<T>(n: T): void {
	n.layoutSetYg(null);
	n.layoutSetLastStyle(null);
	for (const c of n.layoutGetChildren()) { clearLayoutYg(c); }
}

function ensureLayoutYg<T>(n: T): Ptr<void> {
	const cur = n.layoutGetYg();
	if (cur !== null) return cur;
	const fresh = YGNodeNew();
	n.layoutSetYg(fresh);
	return fresh;
}

function syncLayoutNode<T>(n: T): Ptr<void> {
	const yg = ensureLayoutYg(n);
	const style = n.layoutGetStyle();
	if (style !== null && n.layoutGetLastStyle() !== style) {
		applyStyle(yg, style);
		n.layoutSetLastStyle(style);
	}
	let li: int32 = 0;
	let aligned = true;
	for (const c of n.layoutGetChildren()) {
		if (c.layoutGetStyle() === null) continue;
		const cyg = syncLayoutNode(c);
		if (aligned && YGNodeGetChild(yg, li) !== cyg) { aligned = false; }
		li += 1;
	}
	if (aligned && YGNodeGetChildCount(yg) === li) return yg;
	YGNodeRemoveAllChildren(yg);
	let i: int32 = 0;
	for (const c of n.layoutGetChildren()) {
		if (c.layoutGetStyle() === null) continue;
		const cyg = c.layoutGetYg();
		if (cyg !== null) {
			YGNodeInsertChild(yg, cyg, i);
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
