#include <yoga/Yoga.h>
#include "measure.h"

YGSize yogaMeasureNode(YGNodeRef node, float width, YGMeasureMode widthMode, float height, YGMeasureMode heightMode);

static YGSize trampoline(YGNodeConstRef node, float width, YGMeasureMode widthMode, float height, YGMeasureMode heightMode) {
	return yogaMeasureNode((YGNodeRef)node, width, widthMode, height, heightMode);
}

void yogaBindMeasure(YGNodeRef node) { YGNodeSetMeasureFunc(node, trampoline); }
