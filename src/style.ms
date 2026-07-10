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
	edgeLeft, edgeTop, edgeRight, edgeBottom, edgeHorizontal, edgeVertical, edgeAll,
	gutterColumn, gutterRow, gutterAll,
} from "./enums";
import {
	YGNodeStyleSetDirection, YGNodeStyleSetFlexDirection, YGNodeStyleSetJustifyContent,
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

// ===== Dimension-string routing =====
// Helpers take the string AFTER extraction (plain `string` params — never
// bare-union params: only Maybe-backed FIELDS have the storage rewrite).

function isPct(v: string): boolean {
	return v.length > 0 && v.slice(v.length - 1, v.length) === "%";
}

function pctValue(v: string): float32 {
	return v.slice(0, v.length - 1).parseFloat() as float32;
}

function setWidthStr(yg: Ptr<void>, v: string): void {
	if (v === "auto") { YGNodeStyleSetWidthAuto(yg); return; }
	if (isPct(v)) { YGNodeStyleSetWidthPercent(yg, pctValue(v)); return; }
	YGNodeStyleSetWidth(yg, v.parseFloat() as float32);
}

function setHeightStr(yg: Ptr<void>, v: string): void {
	if (v === "auto") { YGNodeStyleSetHeightAuto(yg); return; }
	if (isPct(v)) { YGNodeStyleSetHeightPercent(yg, pctValue(v)); return; }
	YGNodeStyleSetHeight(yg, v.parseFloat() as float32);
}

function setFlexBasisStr(yg: Ptr<void>, v: string): void {
	if (v === "auto") { YGNodeStyleSetFlexBasisAuto(yg); return; }
	if (isPct(v)) { YGNodeStyleSetFlexBasisPercent(yg, pctValue(v)); return; }
	YGNodeStyleSetFlexBasis(yg, v.parseFloat() as float32);
}

function setMinMaxStr(yg: Ptr<void>, which: int32, v: string): void {
	if (v === "auto") return;
	const pct = isPct(v);
	const f = pct ? pctValue(v) : (v.parseFloat() as float32);
	if (which === 0) { if (pct) YGNodeStyleSetMinWidthPercent(yg, f); else YGNodeStyleSetMinWidth(yg, f); }
	else if (which === 1) { if (pct) YGNodeStyleSetMinHeightPercent(yg, f); else YGNodeStyleSetMinHeight(yg, f); }
	else if (which === 2) { if (pct) YGNodeStyleSetMaxWidthPercent(yg, f); else YGNodeStyleSetMaxWidth(yg, f); }
	else { if (pct) YGNodeStyleSetMaxHeightPercent(yg, f); else YGNodeStyleSetMaxHeight(yg, f); }
}

function setMarginStr(yg: Ptr<void>, edge: int32, v: string): void {
	if (v === "auto") { YGNodeStyleSetMarginAuto(yg, edge); return; }
	if (isPct(v)) { YGNodeStyleSetMarginPercent(yg, edge, pctValue(v)); return; }
	YGNodeStyleSetMargin(yg, edge, v.parseFloat() as float32);
}

function setPaddingStr(yg: Ptr<void>, edge: int32, v: string): void {
	if (v === "auto") return;
	if (isPct(v)) { YGNodeStyleSetPaddingPercent(yg, edge, pctValue(v)); return; }
	YGNodeStyleSetPadding(yg, edge, v.parseFloat() as float32);
}

function setPosStr(yg: Ptr<void>, edge: int32, v: string): void {
	if (v === "auto") return;
	if (isPct(v)) { YGNodeStyleSetPositionPercent(yg, edge, pctValue(v)); return; }
	YGNodeStyleSetPosition(yg, edge, v.parseFloat() as float32);
}

function setGapStr(yg: Ptr<void>, gutter: int32, v: string): void {
	if (v === "auto") return;
	if (isPct(v)) { YGNodeStyleSetGapPercent(yg, gutter, pctValue(v)); return; }
	YGNodeStyleSetGap(yg, gutter, v.parseFloat() as float32);
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
	if (s.flexBasis !== null) {
		if (typeof s.flexBasis === "string") setFlexBasisStr(yg, s.flexBasis as string);
		else YGNodeStyleSetFlexBasis(yg, s.flexBasis as float32);
	}

	if (s.width !== null) {
		if (typeof s.width === "string") setWidthStr(yg, s.width as string);
		else YGNodeStyleSetWidth(yg, s.width as float32);
	}
	if (s.height !== null) {
		if (typeof s.height === "string") setHeightStr(yg, s.height as string);
		else YGNodeStyleSetHeight(yg, s.height as float32);
	}
	if (s.minWidth !== null) {
		if (typeof s.minWidth === "string") setMinMaxStr(yg, 0, s.minWidth as string);
		else YGNodeStyleSetMinWidth(yg, s.minWidth as float32);
	}
	if (s.minHeight !== null) {
		if (typeof s.minHeight === "string") setMinMaxStr(yg, 1, s.minHeight as string);
		else YGNodeStyleSetMinHeight(yg, s.minHeight as float32);
	}
	if (s.maxWidth !== null) {
		if (typeof s.maxWidth === "string") setMinMaxStr(yg, 2, s.maxWidth as string);
		else YGNodeStyleSetMaxWidth(yg, s.maxWidth as float32);
	}
	if (s.maxHeight !== null) {
		if (typeof s.maxHeight === "string") setMinMaxStr(yg, 3, s.maxHeight as string);
		else YGNodeStyleSetMaxHeight(yg, s.maxHeight as float32);
	}
	if (s.aspectRatio !== null) YGNodeStyleSetAspectRatio(yg, s.aspectRatio);

	if (s.margin !== null) {
		if (typeof s.margin === "string") setMarginStr(yg, edgeAll, s.margin as string);
		else YGNodeStyleSetMargin(yg, edgeAll, s.margin as float32);
	}
	if (s.marginHorizontal !== null) {
		if (typeof s.marginHorizontal === "string") setMarginStr(yg, edgeHorizontal, s.marginHorizontal as string);
		else YGNodeStyleSetMargin(yg, edgeHorizontal, s.marginHorizontal as float32);
	}
	if (s.marginVertical !== null) {
		if (typeof s.marginVertical === "string") setMarginStr(yg, edgeVertical, s.marginVertical as string);
		else YGNodeStyleSetMargin(yg, edgeVertical, s.marginVertical as float32);
	}
	if (s.marginTop !== null) {
		if (typeof s.marginTop === "string") setMarginStr(yg, edgeTop, s.marginTop as string);
		else YGNodeStyleSetMargin(yg, edgeTop, s.marginTop as float32);
	}
	if (s.marginBottom !== null) {
		if (typeof s.marginBottom === "string") setMarginStr(yg, edgeBottom, s.marginBottom as string);
		else YGNodeStyleSetMargin(yg, edgeBottom, s.marginBottom as float32);
	}
	if (s.marginLeft !== null) {
		if (typeof s.marginLeft === "string") setMarginStr(yg, edgeLeft, s.marginLeft as string);
		else YGNodeStyleSetMargin(yg, edgeLeft, s.marginLeft as float32);
	}
	if (s.marginRight !== null) {
		if (typeof s.marginRight === "string") setMarginStr(yg, edgeRight, s.marginRight as string);
		else YGNodeStyleSetMargin(yg, edgeRight, s.marginRight as float32);
	}

	if (s.padding !== null) {
		if (typeof s.padding === "string") setPaddingStr(yg, edgeAll, s.padding as string);
		else YGNodeStyleSetPadding(yg, edgeAll, s.padding as float32);
	}
	if (s.paddingHorizontal !== null) {
		if (typeof s.paddingHorizontal === "string") setPaddingStr(yg, edgeHorizontal, s.paddingHorizontal as string);
		else YGNodeStyleSetPadding(yg, edgeHorizontal, s.paddingHorizontal as float32);
	}
	if (s.paddingVertical !== null) {
		if (typeof s.paddingVertical === "string") setPaddingStr(yg, edgeVertical, s.paddingVertical as string);
		else YGNodeStyleSetPadding(yg, edgeVertical, s.paddingVertical as float32);
	}
	if (s.paddingTop !== null) {
		if (typeof s.paddingTop === "string") setPaddingStr(yg, edgeTop, s.paddingTop as string);
		else YGNodeStyleSetPadding(yg, edgeTop, s.paddingTop as float32);
	}
	if (s.paddingBottom !== null) {
		if (typeof s.paddingBottom === "string") setPaddingStr(yg, edgeBottom, s.paddingBottom as string);
		else YGNodeStyleSetPadding(yg, edgeBottom, s.paddingBottom as float32);
	}
	if (s.paddingLeft !== null) {
		if (typeof s.paddingLeft === "string") setPaddingStr(yg, edgeLeft, s.paddingLeft as string);
		else YGNodeStyleSetPadding(yg, edgeLeft, s.paddingLeft as float32);
	}
	if (s.paddingRight !== null) {
		if (typeof s.paddingRight === "string") setPaddingStr(yg, edgeRight, s.paddingRight as string);
		else YGNodeStyleSetPadding(yg, edgeRight, s.paddingRight as float32);
	}

	if (s.borderWidth !== null) YGNodeStyleSetBorder(yg, edgeAll, s.borderWidth);

	if (s.top !== null) {
		if (typeof s.top === "string") setPosStr(yg, edgeTop, s.top as string);
		else YGNodeStyleSetPosition(yg, edgeTop, s.top as float32);
	}
	if (s.left !== null) {
		if (typeof s.left === "string") setPosStr(yg, edgeLeft, s.left as string);
		else YGNodeStyleSetPosition(yg, edgeLeft, s.left as float32);
	}
	if (s.right !== null) {
		if (typeof s.right === "string") setPosStr(yg, edgeRight, s.right as string);
		else YGNodeStyleSetPosition(yg, edgeRight, s.right as float32);
	}
	if (s.bottom !== null) {
		if (typeof s.bottom === "string") setPosStr(yg, edgeBottom, s.bottom as string);
		else YGNodeStyleSetPosition(yg, edgeBottom, s.bottom as float32);
	}

	if (s.gap !== null) {
		if (typeof s.gap === "string") setGapStr(yg, gutterAll, s.gap as string);
		else YGNodeStyleSetGap(yg, gutterAll, s.gap as float32);
	}
	if (s.rowGap !== null) {
		if (typeof s.rowGap === "string") setGapStr(yg, gutterRow, s.rowGap as string);
		else YGNodeStyleSetGap(yg, gutterRow, s.rowGap as float32);
	}
	if (s.columnGap !== null) {
		if (typeof s.columnGap === "string") setGapStr(yg, gutterColumn, s.columnGap as string);
		else YGNodeStyleSetGap(yg, gutterColumn, s.columnGap as float32);
	}
}
