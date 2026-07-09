// String-literal unions mirroring YGEnums.h (deps/yoga/yoga/YGEnums.h).
// Ordinal mapping must match the YG_ENUM_DECL declaration order exactly —
// these ints cross the C ABI as the corresponding YG* enum values.

export type FlexDirection = "column" | "column-reverse" | "row" | "row-reverse";
export type Justify = "flex-start" | "center" | "flex-end" | "space-between" | "space-around" | "space-evenly";
export type Align = "auto" | "flex-start" | "center" | "flex-end" | "stretch" | "baseline" | "space-between" | "space-around" | "space-evenly";
export type PositionType = "static" | "relative" | "absolute";
export type Wrap = "nowrap" | "wrap" | "wrap-reverse";
export type Overflow = "visible" | "hidden" | "scroll";
export type Display = "flex" | "none" | "contents";
export type Direction = "inherit" | "ltr" | "rtl";

export function flexDirectionToC(v: FlexDirection): int32 {
	return match (v) {
		"column" => 0,
		"column-reverse" => 1,
		"row" => 2,
		"row-reverse" => 3,
	};
}

export function justifyToC(v: Justify): int32 {
	return match (v) {
		"flex-start" => 0,
		"center" => 1,
		"flex-end" => 2,
		"space-between" => 3,
		"space-around" => 4,
		"space-evenly" => 5,
	};
}

export function alignToC(v: Align): int32 {
	return match (v) {
		"auto" => 0,
		"flex-start" => 1,
		"center" => 2,
		"flex-end" => 3,
		"stretch" => 4,
		"baseline" => 5,
		"space-between" => 6,
		"space-around" => 7,
		"space-evenly" => 8,
	};
}

export function positionTypeToC(v: PositionType): int32 {
	return match (v) {
		"static" => 0,
		"relative" => 1,
		"absolute" => 2,
	};
}

export function wrapToC(v: Wrap): int32 {
	return match (v) {
		"nowrap" => 0,
		"wrap" => 1,
		"wrap-reverse" => 2,
	};
}

export function overflowToC(v: Overflow): int32 {
	return match (v) {
		"visible" => 0,
		"hidden" => 1,
		"scroll" => 2,
	};
}

export function displayToC(v: Display): int32 {
	return match (v) {
		"flex" => 0,
		"none" => 1,
		"contents" => 2,
	};
}

export function directionToC(v: Direction): int32 {
	return match (v) {
		"inherit" => 0,
		"ltr" => 1,
		"rtl" => 2,
	};
}

// YGEdge ordinals (internal — edges surface as marginTop/paddingLeft/... fields)
export const edgeLeft: int32 = 0;
export const edgeTop: int32 = 1;
export const edgeRight: int32 = 2;
export const edgeBottom: int32 = 3;
export const edgeStart: int32 = 4;
export const edgeEnd: int32 = 5;
export const edgeHorizontal: int32 = 6;
export const edgeVertical: int32 = 7;
export const edgeAll: int32 = 8;

// YGGutter ordinals (gap)
export const gutterColumn: int32 = 0;
export const gutterRow: int32 = 1;
export const gutterAll: int32 = 2;
