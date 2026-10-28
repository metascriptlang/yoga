// Measure hook: a host leaf whose size comes from its content (text) gives
// yoga a LayoutMeasure. Yoga calls a C function pointer, which msc cannot yet
// pass a MetaScript routine to (card .inbox/compiler/2026-10-16-function-into-
// c-function-pointer-emits-msclosure.md), so measure.c holds the pointer and
// calls yogaMeasureNode below; the closure lives in the yoga node's context
// until releaseMeasures frees it with the node.

@passC("-I../deps/yoga");
import { Handle } from "std/ffi";
import { MeasureMode, measureModeFromC } from "./enums";
import {
	YGNode,
	YGSize,
	YGMeasureMode,
	YGNodeSetContext,
	YGNodeGetContext,
	YGNodeGetChild,
	YGNodeGetChildCount,
} from "./yogaH";
import { yogaBindMeasure } from "./measure.h";

export interface MeasureSize {
	width: float32;
	height: float32;
}

export type LayoutMeasure = (
	width: float32,
	widthMode: MeasureMode,
	height: float32,
	heightMode: MeasureMode,
) => MeasureSize;

class MeasureSlot {
	measure: LayoutMeasure;
	constructor(measure: LayoutMeasure) { this.measure = measure; }
}

@exportName("yogaMeasureNode")
function measureNode(
	node: Ptr<YGNode>,
	width: float32,
	widthMode: YGMeasureMode,
	height: float32,
	heightMode: YGMeasureMode,
): YGSize {
	const slot = Handle.at<MeasureSlot>(YGNodeGetContext(node)).value();
	const size = slot.measure(width, measureModeFromC(widthMode), height, measureModeFromC(heightMode));
	return { width: size.width, height: size.height };
}

export function bindMeasure(yg: Ptr<YGNode>, measure: LayoutMeasure): void {
	YGNodeSetContext(yg, Handle.retain(new MeasureSlot(measure)).ptr);
	yogaBindMeasure(yg);
}

export function releaseMeasures(yg: Ptr<YGNode>): void {
	const count = YGNodeGetChildCount(yg);
	for (let i: uint32 = 0; i < count; i++) { releaseMeasures(YGNodeGetChild(yg, i)); }
	const ctx = YGNodeGetContext(yg);
	if (ctx === null) return;
	Handle.at<MeasureSlot>(ctx).release();
	YGNodeSetContext(yg, null);
}
