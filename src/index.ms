// @metascript/yoga — public entry. Re-exports the layout API.
//
// See CLAUDE.md for architecture. Layered:
//   - enums.ms   — string-literal unions + toC mapping for C-API enums
//   - yogaH.ms   — extern function declarations against deps/yoga/yoga/*.h
//   - node.ms    — YogaNode wrapper tree around YGNodeRef (+ sync protocol opt-in)
//   - style.ms   — FlexStyle interface + applyStyle
//   - layout.ms  — calculateLayout + LayoutResult read-back
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

export { YogaNode, LayoutResult, yogaNode, yogaLeaf, appendChild, setStyle, freeYogaNode, layoutGetChildren, layoutGetStyle, layoutGetLastStyle, layoutSetLastStyle, layoutGetYg, layoutSetYg, layoutSetFrame } from "./node";
export { FlexStyle, applyStyle } from "./style";
export { calculateLayout, getLayout, layoutTree } from "./layout";
export { layoutPass, freeLayoutTree } from "./sync";
export { FlexDirection, Justify, Align, PositionType, Wrap, Overflow, Display, Direction } from "./enums";
