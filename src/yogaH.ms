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
	@compile("../deps/yoga/yoga/YGConfig.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/YGEnums.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/YGNode.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/YGNodeLayout.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/YGNodeStyle.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/YGPixelGrid.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/YGValue.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/algorithm/AbsoluteLayout.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/algorithm/Baseline.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/algorithm/Cache.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/algorithm/CalculateLayout.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/algorithm/FlexLine.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/algorithm/PixelGrid.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/config/Config.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/debug/AssertFatal.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/debug/Log.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/event/event.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/node/LayoutResults.cpp", "-std=c++20");
	@compile("../deps/yoga/yoga/node/Node.cpp", "-std=c++20");
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
