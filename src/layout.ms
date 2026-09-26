import { YogaNode, LayoutResult } from "./node";
import { Direction } from "./enums";
import { layoutPass } from "./sync";

export function calculateLayout(
	this root: YogaNode,
	availableWidth: float32,
	availableHeight: float32,
	direction: Direction,
): void {
	layoutPass(root, availableWidth, availableHeight, direction);
}

export function getLayout(this n: YogaNode): LayoutResult {
	return n.layout;
}

export function layoutTree(this root: YogaNode, width: float32, height: float32): void {
	root.calculateLayout(width, height, "ltr");
}
