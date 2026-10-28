import {
	YGAlign,
	YGDirection,
	YGDisplay,
	YGFlexDirection,
	YGJustify,
	YGMeasureMode,
	YGOverflow,
	YGPositionType,
	YGWrap,
} from "./yogaH";

export type FlexDirection = "column" | "column-reverse" | "row" | "row-reverse";
export type Justify = "flex-start" | "center" | "flex-end" | "space-between" | "space-around" |
	"space-evenly";
export type Align = "auto" | "flex-start" | "center" | "flex-end" | "stretch" | "baseline" |
	"space-between" | "space-around" | "space-evenly";
export type PositionType = "static" | "relative" | "absolute";
export type Wrap = "nowrap" | "wrap" | "wrap-reverse";
export type Overflow = "visible" | "hidden" | "scroll";
export type Display = "flex" | "none" | "contents";
export type Direction = "inherit" | "ltr" | "rtl";
export type MeasureMode = "undefined" | "exactly" | "at-most";

export function flexDirectionToC(v: FlexDirection): YGFlexDirection {
	return match (v) {
		"column" => YGFlexDirection.YGFlexDirectionColumn,
		"column-reverse" => YGFlexDirection.YGFlexDirectionColumnReverse,
		"row" => YGFlexDirection.YGFlexDirectionRow,
		"row-reverse" => YGFlexDirection.YGFlexDirectionRowReverse,
	};
}

export function justifyToC(v: Justify): YGJustify {
	return match (v) {
		"flex-start" => YGJustify.YGJustifyFlexStart,
		"center" => YGJustify.YGJustifyCenter,
		"flex-end" => YGJustify.YGJustifyFlexEnd,
		"space-between" => YGJustify.YGJustifySpaceBetween,
		"space-around" => YGJustify.YGJustifySpaceAround,
		"space-evenly" => YGJustify.YGJustifySpaceEvenly,
	};
}

export function alignToC(v: Align): YGAlign {
	return match (v) {
		"auto" => YGAlign.YGAlignAuto,
		"flex-start" => YGAlign.YGAlignFlexStart,
		"center" => YGAlign.YGAlignCenter,
		"flex-end" => YGAlign.YGAlignFlexEnd,
		"stretch" => YGAlign.YGAlignStretch,
		"baseline" => YGAlign.YGAlignBaseline,
		"space-between" => YGAlign.YGAlignSpaceBetween,
		"space-around" => YGAlign.YGAlignSpaceAround,
		"space-evenly" => YGAlign.YGAlignSpaceEvenly,
	};
}

export function positionTypeToC(v: PositionType): YGPositionType {
	return match (v) {
		"static" => YGPositionType.YGPositionTypeStatic,
		"relative" => YGPositionType.YGPositionTypeRelative,
		"absolute" => YGPositionType.YGPositionTypeAbsolute,
	};
}

export function wrapToC(v: Wrap): YGWrap {
	return match (v) {
		"nowrap" => YGWrap.YGWrapNoWrap,
		"wrap" => YGWrap.YGWrapWrap,
		"wrap-reverse" => YGWrap.YGWrapWrapReverse,
	};
}

export function overflowToC(v: Overflow): YGOverflow {
	return match (v) {
		"visible" => YGOverflow.YGOverflowVisible,
		"hidden" => YGOverflow.YGOverflowHidden,
		"scroll" => YGOverflow.YGOverflowScroll,
	};
}

export function displayToC(v: Display): YGDisplay {
	return match (v) {
		"flex" => YGDisplay.YGDisplayFlex,
		"none" => YGDisplay.YGDisplayNone,
		"contents" => YGDisplay.YGDisplayContents,
	};
}

export function directionToC(v: Direction): YGDirection {
	return match (v) {
		"inherit" => YGDirection.YGDirectionInherit,
		"ltr" => YGDirection.YGDirectionLTR,
		"rtl" => YGDirection.YGDirectionRTL,
	};
}

export function measureModeFromC(v: YGMeasureMode): MeasureMode {
	return match (v) {
		YGMeasureMode.YGMeasureModeUndefined => "undefined",
		YGMeasureMode.YGMeasureModeExactly => "exactly",
		YGMeasureMode.YGMeasureModeAtMost => "at-most",
	};
}
