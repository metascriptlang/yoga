// FlexStyle — React/RN-friendly partial style object. Every field is
// `T | null`; a partial literal auto-nulls the rest, and applyStyle only
// touches setters for non-null fields (Yoga's own defaults cover the rest).
//
// Percent/auto dimension values ("50%", "auto") are not yet supported —
// needs `float32 | string | null` fields. Planned after the points-only
// surface is proven on Void.

import {
	FlexDirection, Justify, Align, PositionType, Wrap, Overflow, Display, Direction,
	flexDirectionToC, justifyToC, alignToC, positionTypeToC, wrapToC, overflowToC, displayToC, directionToC,
	edgeLeft, edgeTop, edgeRight, edgeBottom, edgeHorizontal, edgeVertical, edgeAll,
	gutterColumn, gutterRow, gutterAll,
} from "./enums";
import {
	YGNodeStyleSetDirection, YGNodeStyleSetFlexDirection, YGNodeStyleSetJustifyContent,
	YGNodeStyleSetAlignContent, YGNodeStyleSetAlignItems, YGNodeStyleSetAlignSelf,
	YGNodeStyleSetPositionType, YGNodeStyleSetFlexWrap, YGNodeStyleSetOverflow, YGNodeStyleSetDisplay,
	YGNodeStyleSetFlex, YGNodeStyleSetFlexGrow, YGNodeStyleSetFlexShrink, YGNodeStyleSetFlexBasis,
	YGNodeStyleSetPosition, YGNodeStyleSetMargin, YGNodeStyleSetPadding, YGNodeStyleSetBorder,
	YGNodeStyleSetWidth, YGNodeStyleSetHeight,
	YGNodeStyleSetMinWidth, YGNodeStyleSetMinHeight, YGNodeStyleSetMaxWidth, YGNodeStyleSetMaxHeight,
	YGNodeStyleSetAspectRatio, YGNodeStyleSetGap,
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
	flexBasis: float32 | null;

	width: float32 | null;
	height: float32 | null;
	minWidth: float32 | null;
	minHeight: float32 | null;
	maxWidth: float32 | null;
	maxHeight: float32 | null;
	aspectRatio: float32 | null;

	margin: float32 | null;
	marginTop: float32 | null;
	marginBottom: float32 | null;
	marginLeft: float32 | null;
	marginRight: float32 | null;
	marginHorizontal: float32 | null;
	marginVertical: float32 | null;

	padding: float32 | null;
	paddingTop: float32 | null;
	paddingBottom: float32 | null;
	paddingLeft: float32 | null;
	paddingRight: float32 | null;
	paddingHorizontal: float32 | null;
	paddingVertical: float32 | null;

	borderWidth: float32 | null;

	top: float32 | null;
	left: float32 | null;
	right: float32 | null;
	bottom: float32 | null;

	gap: float32 | null;
	rowGap: float32 | null;
	columnGap: float32 | null;
}

export function applyStyle(yg: Ptr<void>, s: FlexStyle): void {
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
	if (s.flexBasis !== null) YGNodeStyleSetFlexBasis(yg, s.flexBasis);

	if (s.width !== null) YGNodeStyleSetWidth(yg, s.width);
	if (s.height !== null) YGNodeStyleSetHeight(yg, s.height);
	if (s.minWidth !== null) YGNodeStyleSetMinWidth(yg, s.minWidth);
	if (s.minHeight !== null) YGNodeStyleSetMinHeight(yg, s.minHeight);
	if (s.maxWidth !== null) YGNodeStyleSetMaxWidth(yg, s.maxWidth);
	if (s.maxHeight !== null) YGNodeStyleSetMaxHeight(yg, s.maxHeight);
	if (s.aspectRatio !== null) YGNodeStyleSetAspectRatio(yg, s.aspectRatio);

	if (s.margin !== null) YGNodeStyleSetMargin(yg, edgeAll, s.margin);
	if (s.marginHorizontal !== null) YGNodeStyleSetMargin(yg, edgeHorizontal, s.marginHorizontal);
	if (s.marginVertical !== null) YGNodeStyleSetMargin(yg, edgeVertical, s.marginVertical);
	if (s.marginTop !== null) YGNodeStyleSetMargin(yg, edgeTop, s.marginTop);
	if (s.marginBottom !== null) YGNodeStyleSetMargin(yg, edgeBottom, s.marginBottom);
	if (s.marginLeft !== null) YGNodeStyleSetMargin(yg, edgeLeft, s.marginLeft);
	if (s.marginRight !== null) YGNodeStyleSetMargin(yg, edgeRight, s.marginRight);

	if (s.padding !== null) YGNodeStyleSetPadding(yg, edgeAll, s.padding);
	if (s.paddingHorizontal !== null) YGNodeStyleSetPadding(yg, edgeHorizontal, s.paddingHorizontal);
	if (s.paddingVertical !== null) YGNodeStyleSetPadding(yg, edgeVertical, s.paddingVertical);
	if (s.paddingTop !== null) YGNodeStyleSetPadding(yg, edgeTop, s.paddingTop);
	if (s.paddingBottom !== null) YGNodeStyleSetPadding(yg, edgeBottom, s.paddingBottom);
	if (s.paddingLeft !== null) YGNodeStyleSetPadding(yg, edgeLeft, s.paddingLeft);
	if (s.paddingRight !== null) YGNodeStyleSetPadding(yg, edgeRight, s.paddingRight);

	if (s.borderWidth !== null) YGNodeStyleSetBorder(yg, edgeAll, s.borderWidth);

	if (s.top !== null) YGNodeStyleSetPosition(yg, edgeTop, s.top);
	if (s.left !== null) YGNodeStyleSetPosition(yg, edgeLeft, s.left);
	if (s.right !== null) YGNodeStyleSetPosition(yg, edgeRight, s.right);
	if (s.bottom !== null) YGNodeStyleSetPosition(yg, edgeBottom, s.bottom);

	if (s.gap !== null) YGNodeStyleSetGap(yg, gutterAll, s.gap);
	if (s.rowGap !== null) YGNodeStyleSetGap(yg, gutterRow, s.rowGap);
	if (s.columnGap !== null) YGNodeStyleSetGap(yg, gutterColumn, s.columnGap);
}
