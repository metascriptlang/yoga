// Layout pass: run Yoga's flexbox solve, then read results back into each
// wrapper's `layout` field so hosts read plain floats (no FFI on the hot
// read path).

import { YGNodeCalculateLayout, YGNodeLayoutGetLeft, YGNodeLayoutGetTop, YGNodeLayoutGetWidth, YGNodeLayoutGetHeight, YGNodeGetHasNewLayout, YGNodeSetHasNewLayout } from "./yogaH";
import { YogaNode, LayoutResult } from "./node";
import { Direction, directionToC } from "./enums";

export function calculateLayout(root: YogaNode, availableWidth: float32, availableHeight: float32, direction: Direction): void {
	YGNodeCalculateLayout(root.yg, availableWidth, availableHeight, directionToC(direction));
	readback(root);
}

// hasNewLayout gates the copy AND the descent: yoga leaves the flag false on
// nodes (and subtrees) whose layout did not change, so a stable subtree costs
// one flag check — this is what keeps per-frame layout cheap for Layer B.
function readback(n: YogaNode): void {
	if (!YGNodeGetHasNewLayout(n.yg)) return;
	YGNodeSetHasNewLayout(n.yg, false);
	n.layout.left = YGNodeLayoutGetLeft(n.yg);
	n.layout.top = YGNodeLayoutGetTop(n.yg);
	n.layout.width = YGNodeLayoutGetWidth(n.yg);
	n.layout.height = YGNodeLayoutGetHeight(n.yg);
	for (const c of n.children) {
		readback(c);
	}
}

export function getLayout(n: YogaNode): LayoutResult {
	return n.layout;
}

export function layoutTree(root: YogaNode, width: float32, height: float32): void {
	calculateLayout(root, width, height, "ltr");
}
