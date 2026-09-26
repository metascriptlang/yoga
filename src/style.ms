// FlexStyle — React/RN-friendly partial style object. Every field is
// `T | null`; a partial literal auto-nulls the rest, and applyStyle only
// touches setters for non-null fields (Yoga's own defaults cover the rest).
//
// Dimension fields are `float32 | string | null`: bare numbers are points,
// "NN%" routes to the *Percent setter, "auto" to the *Auto setter (where Yoga
// has one — min/max/padding/position ignore "auto"), and a numeric string
// ("120") reads as points, mirroring React Native.

import {
	FlexDirection, Justify, Align, PositionType, Wrap, Overflow, Display, Direction,
	flexDirectionToC, justifyToC, alignToC, positionTypeToC, wrapToC, overflowToC, displayToC, directionToC,
} from "./enums";
import {
	YGNode, YGEdge, YGGutter, YGNodeStyleSetDirection, YGNodeStyleSetFlexDirection, YGNodeStyleSetJustifyContent,
	YGNodeStyleSetAlignContent, YGNodeStyleSetAlignItems, YGNodeStyleSetAlignSelf,
	YGNodeStyleSetPositionType, YGNodeStyleSetFlexWrap, YGNodeStyleSetOverflow, YGNodeStyleSetDisplay,
	YGNodeStyleSetFlex, YGNodeStyleSetFlexGrow, YGNodeStyleSetFlexShrink,
	YGNodeStyleSetFlexBasis, YGNodeStyleSetFlexBasisPercent, YGNodeStyleSetFlexBasisAuto,
	YGNodeStyleSetPosition, YGNodeStyleSetPositionPercent,
	YGNodeStyleSetMargin, YGNodeStyleSetMarginPercent, YGNodeStyleSetMarginAuto,
	YGNodeStyleSetPadding, YGNodeStyleSetPaddingPercent, YGNodeStyleSetBorder,
	YGNodeStyleSetWidth, YGNodeStyleSetWidthPercent, YGNodeStyleSetWidthAuto,
	YGNodeStyleSetHeight, YGNodeStyleSetHeightPercent, YGNodeStyleSetHeightAuto,
	YGNodeStyleSetMinWidth, YGNodeStyleSetMinWidthPercent,
	YGNodeStyleSetMinHeight, YGNodeStyleSetMinHeightPercent,
	YGNodeStyleSetMaxWidth, YGNodeStyleSetMaxWidthPercent,
	YGNodeStyleSetMaxHeight, YGNodeStyleSetMaxHeightPercent,
	YGNodeStyleSetAspectRatio, YGNodeStyleSetGap, YGNodeStyleSetGapPercent,
} from "./yogaH";

export interface FlexStyle {
	direction: Direction | null;
	flexDirection: FlexDirection | null;
	justifyContent: Justify | null;
	alignContent: Align | null;
	alignItems: Align | null;
	alignSelf: Align | null;
	position: PositionType | null;
	flexWrap: Wrap | null;
	overflow: Overflow | null;
	display: Display | null;

	flex: float32 | null;
	flexGrow: float32 | null;
	flexShrink: float32 | null;
	flexBasis: float32 | string | null;

	width: float32 | string | null;
	height: float32 | string | null;
	minWidth: float32 | string | null;
	minHeight: float32 | string | null;
	maxWidth: float32 | string | null;
	maxHeight: float32 | string | null;
	aspectRatio: float32 | null;

	margin: float32 | string | null;
	marginTop: float32 | string | null;
	marginBottom: float32 | string | null;
	marginLeft: float32 | string | null;
	marginRight: float32 | string | null;
	marginHorizontal: float32 | string | null;
	marginVertical: float32 | string | null;

	padding: float32 | string | null;
	paddingTop: float32 | string | null;
	paddingBottom: float32 | string | null;
	paddingLeft: float32 | string | null;
	paddingRight: float32 | string | null;
	paddingHorizontal: float32 | string | null;
	paddingVertical: float32 | string | null;

	borderWidth: float32 | null;

	top: float32 | string | null;
	left: float32 | string | null;
	right: float32 | string | null;
	bottom: float32 | string | null;

	gap: float32 | string | null;
	rowGap: float32 | string | null;
	columnGap: float32 | string | null;
}

enum Unit {
	Points,
	Percent,
	Auto,
}

struct Dimension {
	unit: Unit;
	value: float32;
}

function dimension(v: float32 | string): Dimension {
	if (typeof v === "string") {
		if (v === "auto") return { unit: Unit.Auto, value: 0.0 };
		if (v.endsWith("%")) {
			return { unit: Unit.Percent, value: v.slice(0, v.length - 1).parseFloat() as float32 };
		}
		return { unit: Unit.Points, value: v.parseFloat() as float32 };
	}
	return { unit: Unit.Points, value: v };
}

function setWidth(yg: Ptr<YGNode>, v: float32 | string): void {
	const d = dimension(v);
	match (d.unit) {
		Unit.Points => YGNodeStyleSetWidth(yg, d.value),
		Unit.Percent => YGNodeStyleSetWidthPercent(yg, d.value),
		Unit.Auto => YGNodeStyleSetWidthAuto(yg),
	}
}

function setHeight(yg: Ptr<YGNode>, v: float32 | string): void {
	const d = dimension(v);
	match (d.unit) {
		Unit.Points => YGNodeStyleSetHeight(yg, d.value),
		Unit.Percent => YGNodeStyleSetHeightPercent(yg, d.value),
		Unit.Auto => YGNodeStyleSetHeightAuto(yg),
	}
}

function setFlexBasis(yg: Ptr<YGNode>, v: float32 | string): void {
	const d = dimension(v);
	match (d.unit) {
		Unit.Points => YGNodeStyleSetFlexBasis(yg, d.value),
		Unit.Percent => YGNodeStyleSetFlexBasisPercent(yg, d.value),
		Unit.Auto => YGNodeStyleSetFlexBasisAuto(yg),
	}
}

enum MinMax {
	MinWidth,
	MinHeight,
	MaxWidth,
	MaxHeight,
}

function setMinMaxPoints(yg: Ptr<YGNode>, which: MinMax, f: float32): void {
	match (which) {
		MinMax.MinWidth => YGNodeStyleSetMinWidth(yg, f),
		MinMax.MinHeight => YGNodeStyleSetMinHeight(yg, f),
		MinMax.MaxWidth => YGNodeStyleSetMaxWidth(yg, f),
		MinMax.MaxHeight => YGNodeStyleSetMaxHeight(yg, f),
	}
}

function setMinMaxPercent(yg: Ptr<YGNode>, which: MinMax, f: float32): void {
	match (which) {
		MinMax.MinWidth => YGNodeStyleSetMinWidthPercent(yg, f),
		MinMax.MinHeight => YGNodeStyleSetMinHeightPercent(yg, f),
		MinMax.MaxWidth => YGNodeStyleSetMaxWidthPercent(yg, f),
		MinMax.MaxHeight => YGNodeStyleSetMaxHeightPercent(yg, f),
	}
}

function setMinMax(yg: Ptr<YGNode>, which: MinMax, v: float32 | string): void {
	const d = dimension(v);
	match (d.unit) {
		Unit.Points => setMinMaxPoints(yg, which, d.value),
		Unit.Percent => setMinMaxPercent(yg, which, d.value),
		Unit.Auto => {},
	}
}

function setMargin(yg: Ptr<YGNode>, edge: YGEdge, v: float32 | string): void {
	const d = dimension(v);
	match (d.unit) {
		Unit.Points => YGNodeStyleSetMargin(yg, edge, d.value),
		Unit.Percent => YGNodeStyleSetMarginPercent(yg, edge, d.value),
		Unit.Auto => YGNodeStyleSetMarginAuto(yg, edge),
	}
}

function setPadding(yg: Ptr<YGNode>, edge: YGEdge, v: float32 | string): void {
	const d = dimension(v);
	match (d.unit) {
		Unit.Points => YGNodeStyleSetPadding(yg, edge, d.value),
		Unit.Percent => YGNodeStyleSetPaddingPercent(yg, edge, d.value),
		Unit.Auto => {},
	}
}

function setPosition(yg: Ptr<YGNode>, edge: YGEdge, v: float32 | string): void {
	const d = dimension(v);
	match (d.unit) {
		Unit.Points => YGNodeStyleSetPosition(yg, edge, d.value),
		Unit.Percent => YGNodeStyleSetPositionPercent(yg, edge, d.value),
		Unit.Auto => {},
	}
}

function setGap(yg: Ptr<YGNode>, gutter: YGGutter, v: float32 | string): void {
	const d = dimension(v);
	match (d.unit) {
		Unit.Points => YGNodeStyleSetGap(yg, gutter, d.value),
		Unit.Percent => YGNodeStyleSetGapPercent(yg, gutter, d.value),
		Unit.Auto => {},
	}
}

export function applyStyle(yg: Ptr<YGNode>, s: FlexStyle): void {
	if (s.direction !== null) YGNodeStyleSetDirection(yg, directionToC(s.direction));
	if (s.flexDirection !== null) YGNodeStyleSetFlexDirection(yg, flexDirectionToC(s.flexDirection));
	if (s.justifyContent !== null) YGNodeStyleSetJustifyContent(yg, justifyToC(s.justifyContent));
	if (s.alignContent !== null) YGNodeStyleSetAlignContent(yg, alignToC(s.alignContent));
	if (s.alignItems !== null) YGNodeStyleSetAlignItems(yg, alignToC(s.alignItems));
	if (s.alignSelf !== null) YGNodeStyleSetAlignSelf(yg, alignToC(s.alignSelf));
	if (s.position !== null) YGNodeStyleSetPositionType(yg, positionTypeToC(s.position));
	if (s.flexWrap !== null) YGNodeStyleSetFlexWrap(yg, wrapToC(s.flexWrap));
	if (s.overflow !== null) YGNodeStyleSetOverflow(yg, overflowToC(s.overflow));
	if (s.display !== null) YGNodeStyleSetDisplay(yg, displayToC(s.display));

	if (s.flex !== null) YGNodeStyleSetFlex(yg, s.flex);
	if (s.flexGrow !== null) YGNodeStyleSetFlexGrow(yg, s.flexGrow);
	if (s.flexShrink !== null) YGNodeStyleSetFlexShrink(yg, s.flexShrink);
	if (s.flexBasis !== null) setFlexBasis(yg, s.flexBasis);

	if (s.width !== null) setWidth(yg, s.width);
	if (s.height !== null) setHeight(yg, s.height);
	if (s.minWidth !== null) setMinMax(yg, MinMax.MinWidth, s.minWidth);
	if (s.minHeight !== null) setMinMax(yg, MinMax.MinHeight, s.minHeight);
	if (s.maxWidth !== null) setMinMax(yg, MinMax.MaxWidth, s.maxWidth);
	if (s.maxHeight !== null) setMinMax(yg, MinMax.MaxHeight, s.maxHeight);
	if (s.aspectRatio !== null) YGNodeStyleSetAspectRatio(yg, s.aspectRatio);

	if (s.margin !== null) setMargin(yg, YGEdge.YGEdgeAll, s.margin);
	if (s.marginHorizontal !== null) setMargin(yg, YGEdge.YGEdgeHorizontal, s.marginHorizontal);
	if (s.marginVertical !== null) setMargin(yg, YGEdge.YGEdgeVertical, s.marginVertical);
	if (s.marginTop !== null) setMargin(yg, YGEdge.YGEdgeTop, s.marginTop);
	if (s.marginBottom !== null) setMargin(yg, YGEdge.YGEdgeBottom, s.marginBottom);
	if (s.marginLeft !== null) setMargin(yg, YGEdge.YGEdgeLeft, s.marginLeft);
	if (s.marginRight !== null) setMargin(yg, YGEdge.YGEdgeRight, s.marginRight);

	if (s.padding !== null) setPadding(yg, YGEdge.YGEdgeAll, s.padding);
	if (s.paddingHorizontal !== null) setPadding(yg, YGEdge.YGEdgeHorizontal, s.paddingHorizontal);
	if (s.paddingVertical !== null) setPadding(yg, YGEdge.YGEdgeVertical, s.paddingVertical);
	if (s.paddingTop !== null) setPadding(yg, YGEdge.YGEdgeTop, s.paddingTop);
	if (s.paddingBottom !== null) setPadding(yg, YGEdge.YGEdgeBottom, s.paddingBottom);
	if (s.paddingLeft !== null) setPadding(yg, YGEdge.YGEdgeLeft, s.paddingLeft);
	if (s.paddingRight !== null) setPadding(yg, YGEdge.YGEdgeRight, s.paddingRight);

	if (s.borderWidth !== null) YGNodeStyleSetBorder(yg, YGEdge.YGEdgeAll, s.borderWidth);

	if (s.top !== null) setPosition(yg, YGEdge.YGEdgeTop, s.top);
	if (s.left !== null) setPosition(yg, YGEdge.YGEdgeLeft, s.left);
	if (s.right !== null) setPosition(yg, YGEdge.YGEdgeRight, s.right);
	if (s.bottom !== null) setPosition(yg, YGEdge.YGEdgeBottom, s.bottom);

	if (s.gap !== null) setGap(yg, YGGutter.YGGutterAll, s.gap);
	if (s.rowGap !== null) setGap(yg, YGGutter.YGGutterRow, s.rowGap);
	if (s.columnGap !== null) setGap(yg, YGGutter.YGGutterColumn, s.columnGap);
}
