import { YogaNode, LayoutResult } from "./node";
import { Direction } from "./enums";
import { layoutPass } from "./sync";

export function calculateLayout(
	root: YogaNode,
	availableWidth: float32,
	availableHeight: float32,
	direction: Direction,
): void {
	layoutPass(root, availableWidth, availableHeight, direction);
}

export function getLayout(n: YogaNode): LayoutResult {
	return n.layout;
}

export function layoutTree(root: YogaNode, width: float32, height: float32): void {
	calculateLayout(root, width, height, "ltr");
}
