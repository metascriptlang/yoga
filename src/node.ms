// YogaNode — typed wrapper tree around YGNodeRef. The wrapper tree mirrors
// the yoga tree 1:1; DRC manages the wrappers, freeYogaNode releases the
// yoga side (YGNodeFreeRecursive frees the whole yoga subtree, so call it
// on the root only).

import { YGNodeNew, YGNodeFreeRecursive, YGNodeInsertChild, YGNodeGetChildCount } from "./yogaH";
import { FlexStyle, applyStyle } from "./style";

export interface LayoutResult {
	left: float32;
	top: float32;
	width: float32;
	height: float32;
}

export interface YogaNode {
	yg: Ptr<void>;
	style: FlexStyle;
	children: YogaNode[];
	layout: LayoutResult;
}

export function yogaNode(style: FlexStyle, children: YogaNode[]): YogaNode {
	const yg = YGNodeNew();
	applyStyle(yg, style);
	let i: int32 = 0;
	while (i < children.length) {
		YGNodeInsertChild(yg, children[i].yg, i);
		i += 1;
	}
	return {
		yg: yg,
		style: style,
		children: children,
		layout: { left: 0.0, top: 0.0, width: 0.0, height: 0.0 },
	};
}

export function yogaLeaf(style: FlexStyle): YogaNode {
	const empty: YogaNode[] = [];
	return yogaNode(style, empty);
}

export function appendChild(parent: YogaNode, child: YogaNode): void {
	YGNodeInsertChild(parent.yg, child.yg, YGNodeGetChildCount(parent.yg));
	parent.children.push(child);
}

export function setStyle(node: YogaNode, style: FlexStyle): void {
	node.style = style;
	applyStyle(node.yg, style);
}

export function freeYogaNode(root: YogaNode): void {
	YGNodeFreeRecursive(root.yg);
}

// sync.ms layout protocol. yg/style are always live on a YogaNode (applyStyle
// ran in yogaNode/setStyle), so last-style tracking and yg assignment are no-ops.
export function layoutGetChildren(this n: YogaNode): YogaNode[] { return n.children; }
export function layoutGetStyle(this n: YogaNode): FlexStyle | null { return n.style; }
export function layoutGetLastStyle(this n: YogaNode): FlexStyle | null { return n.style; }
export function layoutSetLastStyle(this n: YogaNode, s: FlexStyle | null): void {}
export function layoutGetYg(this n: YogaNode): Ptr<void> | null { return n.yg; }
export function layoutSetYg(this n: YogaNode, yg: Ptr<void> | null): void {}
export function layoutSetFrame(this n: YogaNode, x: float32, y: float32, w: float32, h: float32): void {
	n.layout.left = x;
	n.layout.top = y;
	n.layout.width = w;
	n.layout.height = h;
}
