#include "yogaCount.h"

#include <yoga/event/event.h>

using facebook::yoga::Event;

static int live = 0;
static bool started = false;

void yogaCountStart(void) {
  if (started) {
    return;
  }
  started = true;
  Event::subscribe([](YGNodeConstRef, Event::Type type, Event::Data) {
    if (type == Event::NodeAllocation) {
      live += 1;
    } else if (type == Event::NodeDeallocation) {
      live -= 1;
    }
  });
}

int yogaLiveNodes(void) {
  return live;
}
