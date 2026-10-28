// @metascript/yoga — public entry. Re-exports the layout API.
//
// See CLAUDE.md for architecture. Layered:
//   - enums.ms   — string-literal unions + toC mapping for C-API enums
//   - yogaH.ms   — C-API re-exported from deps/yoga/yoga/Yoga.h (import-from-.h)
//   - node.ms    — YogaNode wrapper tree around YGNodeRef (+ sync protocol opt-in)
//   - style.ms   — FlexStyle interface + applyStyle
//   - layout.ms  — calculateLayout / layoutTree: layoutPass on a YogaNode tree
//   - measure.ms — LayoutMeasure: a leaf's content size, called by yoga
//   - sync.ms    — generic layoutPass<T> over any host tree (convention
//                  protocol: 7 exported `layout*` extensions on T)
//
// Consumers (Neon reconciler, Void-standalone) call:
//   const root = yogaNode({flexDirection: "column", padding: 10.0}, [
//       yogaLeaf({flexGrow: 1.0}),
//       yogaLeaf({height: 50.0}),
//   ]);
//   layoutTree(root, 800.0, 600.0);  // → hosts read node.layout {left, top, width, height}
//   freeYogaNode(root);

export {
	YogaNode,
	LayoutResult,
	yogaNode,
	yogaLeaf,
	appendChild,
	setStyle,
	freeYogaNode,
	layoutGetChildren,
	layoutGetStyle,
	layoutGetLastStyle,
	layoutSetLastStyle,
	layoutGetYg,
	layoutSetYg,
	layoutSetFrame,
	layoutGetMeasure,
} from "./node";
export { FlexStyle, applyStyle } from "./style";
export { calculateLayout, getLayout, layoutTree } from "./layout";
export { layoutPass, freeLayoutTree, markLayoutDirty } from "./sync";
export { LayoutMeasure, MeasureSize } from "./measure";
export { YGNode } from "./yogaH";
export {
	FlexDirection,
	Justify,
	Align,
	PositionType,
	Wrap,
	Overflow,
	Display,
	Direction,
	MeasureMode,
} from "./enums";
