// Raw C-API surface re-exported from the umbrella header (Yoga v3.x).
// Layering: this file is the ONLY place that speaks YG*; typed wrappers live
// in node.ms / style.ms / layout.ms.
//
// Signatures come from deps/yoga/yoga/*.h via import-from-.h — nothing is
// hand-transcribed, so the binding cannot drift from the vendored header.
// YGNodeRef crosses as Ptr<void>-compatible; enums cross as int32 (see
// enums.ms for ordinals); YGValue-returning getters stay unbound (wrappers
// only need setters + float layout reads).
//
// Build convention (matches void): the -I and @link paths resolve relative to
// this source file, so importers in other repos (void, neon) find them.

@passC("-I../deps/yoga");
@passL("-lc++");

when (macos) {
	@link("../deps/yoga/build/macos/libyoga.a");
}

when (ios) {
	@link("../deps/yoga/build/ios/libyoga.a");
}

when (windows) {
	@link("../deps/yoga/build/windows/libyoga.a");
}

export {
	YGNodeNew, YGNodeFree, YGNodeFreeRecursive, YGNodeReset, YGNodeIsDirty, YGNodeMarkDirty,
	YGNodeGetHasNewLayout, YGNodeSetHasNewLayout, YGNodeInsertChild, YGNodeSwapChild, YGNodeRemoveChild, YGNodeRemoveAllChildren,
	YGNodeGetChild, YGNodeGetChildCount, YGNodeGetParent, YGNodeCalculateLayout, YGNodeLayoutGetLeft, YGNodeLayoutGetTop,
	YGNodeLayoutGetRight, YGNodeLayoutGetBottom, YGNodeLayoutGetWidth, YGNodeLayoutGetHeight, YGNodeLayoutGetHadOverflow, YGNodeLayoutGetMargin,
	YGNodeLayoutGetBorder, YGNodeLayoutGetPadding, YGNodeStyleSetDirection, YGNodeStyleSetFlexDirection, YGNodeStyleSetJustifyContent, YGNodeStyleSetAlignContent,
	YGNodeStyleSetAlignItems, YGNodeStyleSetAlignSelf, YGNodeStyleSetPositionType, YGNodeStyleSetFlexWrap, YGNodeStyleSetOverflow, YGNodeStyleSetDisplay,
	YGNodeStyleSetFlex, YGNodeStyleSetFlexGrow, YGNodeStyleSetFlexShrink, YGNodeStyleSetFlexBasis, YGNodeStyleSetFlexBasisPercent, YGNodeStyleSetFlexBasisAuto,
	YGNodeStyleSetPosition, YGNodeStyleSetPositionPercent, YGNodeStyleSetMargin, YGNodeStyleSetMarginPercent, YGNodeStyleSetMarginAuto, YGNodeStyleSetPadding,
	YGNodeStyleSetPaddingPercent, YGNodeStyleSetBorder, YGNodeStyleSetWidth, YGNodeStyleSetWidthPercent, YGNodeStyleSetWidthAuto, YGNodeStyleSetHeight,
	YGNodeStyleSetHeightPercent, YGNodeStyleSetHeightAuto, YGNodeStyleSetMinWidth, YGNodeStyleSetMinWidthPercent, YGNodeStyleSetMinHeight, YGNodeStyleSetMinHeightPercent,
	YGNodeStyleSetMaxWidth, YGNodeStyleSetMaxWidthPercent, YGNodeStyleSetMaxHeight, YGNodeStyleSetMaxHeightPercent, YGNodeStyleSetAspectRatio, YGNodeStyleSetGap,
	YGNodeStyleSetGapPercent, YGConfigNew, YGConfigFree, YGConfigGetDefault, YGConfigSetPointScaleFactor, YGConfigGetPointScaleFactor,
	YGConfigSetUseWebDefaults, YGNodeNewWithConfig, YGNodeSetConfig, YGFloatIsUndefined,
} from "../deps/yoga/yoga/Yoga.h";
