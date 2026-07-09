// Raw C-API externs against deps/yoga/yoga/*.h (Yoga v3.x, flat C surface).
// Layering: this file is the ONLY place that speaks YG*; typed wrappers live
// in node.ms / style.ms / layout.ms.
//
// Enums cross the ABI as int32 (C enums are ints; see enums.ms for ordinals).
// YGValue-returning style getters are intentionally unbound — struct-by-value
// FFI is untested and the wrapper API only needs setters + float layout reads.
//
// Build convention (matches void): compile from the repo root so the -I path
// resolves; @link paths resolve relative to this source file.

@passC("-Ideps/yoga");
@include("yoga/Yoga.h");
@passL("-lc++");

@platform("macos") {
	@link("../deps/yoga/build/macos/libyoga.a");
}

@platform("ios") {
	@link("../deps/yoga/build/ios/libyoga.a");
}

// ===== Node lifecycle =====
export extern function YGNodeNew(): Ptr<void>;
export extern function YGNodeFree(node: Ptr<void>): void;
export extern function YGNodeFreeRecursive(node: Ptr<void>): void;
export extern function YGNodeReset(node: Ptr<void>): void;

// ===== Dirty machinery =====
export extern function YGNodeIsDirty(node: Ptr<void>): boolean;
export extern function YGNodeMarkDirty(node: Ptr<void>): void;
export extern function YGNodeGetHasNewLayout(node: Ptr<void>): boolean;
export extern function YGNodeSetHasNewLayout(node: Ptr<void>, hasNewLayout: boolean): void;

// ===== Tree ops =====
export extern function YGNodeInsertChild(node: Ptr<void>, child: Ptr<void>, index: int32): void;
export extern function YGNodeSwapChild(node: Ptr<void>, child: Ptr<void>, index: int32): void;
export extern function YGNodeRemoveChild(node: Ptr<void>, child: Ptr<void>): void;
export extern function YGNodeRemoveAllChildren(node: Ptr<void>): void;
export extern function YGNodeGetChild(node: Ptr<void>, index: int32): Ptr<void>;
export extern function YGNodeGetChildCount(node: Ptr<void>): int32;
export extern function YGNodeGetParent(node: Ptr<void>): Ptr<void>;

// ===== Layout =====
export extern function YGNodeCalculateLayout(node: Ptr<void>, availableWidth: float32, availableHeight: float32, ownerDirection: int32): void;
export extern function YGNodeLayoutGetLeft(node: Ptr<void>): float32;
export extern function YGNodeLayoutGetTop(node: Ptr<void>): float32;
export extern function YGNodeLayoutGetRight(node: Ptr<void>): float32;
export extern function YGNodeLayoutGetBottom(node: Ptr<void>): float32;
export extern function YGNodeLayoutGetWidth(node: Ptr<void>): float32;
export extern function YGNodeLayoutGetHeight(node: Ptr<void>): float32;
export extern function YGNodeLayoutGetHadOverflow(node: Ptr<void>): boolean;
export extern function YGNodeLayoutGetMargin(node: Ptr<void>, edge: int32): float32;
export extern function YGNodeLayoutGetBorder(node: Ptr<void>, edge: int32): float32;
export extern function YGNodeLayoutGetPadding(node: Ptr<void>, edge: int32): float32;

// ===== Style setters — enums =====
export extern function YGNodeStyleSetDirection(node: Ptr<void>, direction: int32): void;
export extern function YGNodeStyleSetFlexDirection(node: Ptr<void>, flexDirection: int32): void;
export extern function YGNodeStyleSetJustifyContent(node: Ptr<void>, justifyContent: int32): void;
export extern function YGNodeStyleSetAlignContent(node: Ptr<void>, alignContent: int32): void;
export extern function YGNodeStyleSetAlignItems(node: Ptr<void>, alignItems: int32): void;
export extern function YGNodeStyleSetAlignSelf(node: Ptr<void>, alignSelf: int32): void;
export extern function YGNodeStyleSetPositionType(node: Ptr<void>, positionType: int32): void;
export extern function YGNodeStyleSetFlexWrap(node: Ptr<void>, flexWrap: int32): void;
export extern function YGNodeStyleSetOverflow(node: Ptr<void>, overflow: int32): void;
export extern function YGNodeStyleSetDisplay(node: Ptr<void>, display: int32): void;

// ===== Style setters — flex =====
export extern function YGNodeStyleSetFlex(node: Ptr<void>, flex: float32): void;
export extern function YGNodeStyleSetFlexGrow(node: Ptr<void>, flexGrow: float32): void;
export extern function YGNodeStyleSetFlexShrink(node: Ptr<void>, flexShrink: float32): void;
export extern function YGNodeStyleSetFlexBasis(node: Ptr<void>, flexBasis: float32): void;
export extern function YGNodeStyleSetFlexBasisPercent(node: Ptr<void>, flexBasis: float32): void;
export extern function YGNodeStyleSetFlexBasisAuto(node: Ptr<void>): void;

// ===== Style setters — position / margin / padding / border (per edge) =====
export extern function YGNodeStyleSetPosition(node: Ptr<void>, edge: int32, position: float32): void;
export extern function YGNodeStyleSetPositionPercent(node: Ptr<void>, edge: int32, position: float32): void;
export extern function YGNodeStyleSetMargin(node: Ptr<void>, edge: int32, margin: float32): void;
export extern function YGNodeStyleSetMarginPercent(node: Ptr<void>, edge: int32, margin: float32): void;
export extern function YGNodeStyleSetMarginAuto(node: Ptr<void>, edge: int32): void;
export extern function YGNodeStyleSetPadding(node: Ptr<void>, edge: int32, padding: float32): void;
export extern function YGNodeStyleSetPaddingPercent(node: Ptr<void>, edge: int32, padding: float32): void;
export extern function YGNodeStyleSetBorder(node: Ptr<void>, edge: int32, border: float32): void;

// ===== Style setters — dimensions =====
export extern function YGNodeStyleSetWidth(node: Ptr<void>, width: float32): void;
export extern function YGNodeStyleSetWidthPercent(node: Ptr<void>, width: float32): void;
export extern function YGNodeStyleSetWidthAuto(node: Ptr<void>): void;
export extern function YGNodeStyleSetHeight(node: Ptr<void>, height: float32): void;
export extern function YGNodeStyleSetHeightPercent(node: Ptr<void>, height: float32): void;
export extern function YGNodeStyleSetHeightAuto(node: Ptr<void>): void;
export extern function YGNodeStyleSetMinWidth(node: Ptr<void>, minWidth: float32): void;
export extern function YGNodeStyleSetMinWidthPercent(node: Ptr<void>, minWidth: float32): void;
export extern function YGNodeStyleSetMinHeight(node: Ptr<void>, minHeight: float32): void;
export extern function YGNodeStyleSetMinHeightPercent(node: Ptr<void>, minHeight: float32): void;
export extern function YGNodeStyleSetMaxWidth(node: Ptr<void>, maxWidth: float32): void;
export extern function YGNodeStyleSetMaxWidthPercent(node: Ptr<void>, maxWidth: float32): void;
export extern function YGNodeStyleSetMaxHeight(node: Ptr<void>, maxHeight: float32): void;
export extern function YGNodeStyleSetMaxHeightPercent(node: Ptr<void>, maxHeight: float32): void;
export extern function YGNodeStyleSetAspectRatio(node: Ptr<void>, aspectRatio: float32): void;

// ===== Style setters — gap =====
export extern function YGNodeStyleSetGap(node: Ptr<void>, gutter: int32, gapLength: float32): void;
export extern function YGNodeStyleSetGapPercent(node: Ptr<void>, gutter: int32, gapLength: float32): void;

// ===== Config =====
export extern function YGConfigNew(): Ptr<void>;
export extern function YGConfigFree(config: Ptr<void>): void;
export extern function YGConfigGetDefault(): Ptr<void>;
export extern function YGConfigSetPointScaleFactor(config: Ptr<void>, pixelsInPoint: float32): void;
export extern function YGConfigGetPointScaleFactor(config: Ptr<void>): float32;
export extern function YGConfigSetUseWebDefaults(config: Ptr<void>, enabled: boolean): void;
export extern function YGNodeNewWithConfig(config: Ptr<void>): Ptr<void>;
export extern function YGNodeSetConfig(node: Ptr<void>, config: Ptr<void>): void;

// ===== Float helpers =====
export extern function YGFloatIsUndefined(value: float32): boolean;
