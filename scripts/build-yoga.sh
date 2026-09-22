#!/bin/sh
# Build libyoga.a for one platform. Direct clang++ invocation, no cmake.
#
# Usage:
#   scripts/build-yoga.sh macos        # → deps/yoga/build/macos/libyoga.a
#   scripts/build-yoga.sh emscripten   # → deps/yoga/build/emscripten/libyoga.a
#   scripts/build-yoga.sh windows      # → deps/yoga/build/windows/libyoga.a
#
# Source list is one Yoga tree: deps/yoga/yoga/{*.cpp, */*.cpp}.
# 19 .cpp files total — ~1s compile time per platform.

set -e

PLATFORM="${1:-macos}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
YOGA_SRC="$ROOT/deps/yoga"
SRC_DIR="$YOGA_SRC/yoga"
OUT_DIR="$YOGA_SRC/build/$PLATFORM"
OBJ_DIR="$OUT_DIR/obj"

mkdir -p "$OBJ_DIR"

SOURCES=""
for f in "$SRC_DIR"/*.cpp "$SRC_DIR"/algorithm/*.cpp "$SRC_DIR"/config/*.cpp \
		 "$SRC_DIR"/debug/*.cpp "$SRC_DIR"/event/*.cpp "$SRC_DIR"/node/*.cpp; do
	SOURCES="$SOURCES $f"
done

case "$PLATFORM" in
	macos)
		CXX="clang++"
		CXXFLAGS="-std=c++20 -O2 -arch arm64 -arch x86_64 -I$YOGA_SRC"
		;;
	emscripten)
		# Requires emsdk activated upstream.
		CXX="em++"
		CXXFLAGS="-std=c++20 -O2 -I$YOGA_SRC"
		;;
	windows)
		# msc links Windows builds with zig cc for x86_64-windows-gnu; match its ABI.
		# ZIG defaults to the zig that ships with msc.
		CXX="${ZIG:-$HOME/.metascript/zig/zig.exe} c++"
		CXXFLAGS="-target x86_64-windows-gnu -std=c++20 -O2 -I$YOGA_SRC"
		;;
	*)
		echo "unknown platform: $PLATFORM (expected: macos | emscripten | windows)"
		exit 1
		;;
esac

echo "compiling $PLATFORM (libyoga.a)..."
echo "  CXX=$CXX"
echo "  sources=$(echo $SOURCES | wc -w | tr -d ' ') cpp files"

# Compile each .cpp → .o in OBJ_DIR.
for src in $SOURCES; do
	rel="${src#$SRC_DIR/}"
	obj="$OBJ_DIR/${rel%.cpp}.o"
	mkdir -p "$(dirname "$obj")"
	$CXX $CXXFLAGS -c "$src" -o "$obj"
done

# Archive.
rm -f "$OUT_DIR/libyoga.a"
ar rcs "$OUT_DIR/libyoga.a" "$OBJ_DIR"/*.o "$OBJ_DIR"/*/*.o
ranlib "$OUT_DIR/libyoga.a" 2>/dev/null || true

# Cleanup objs (keep just the .a).
rm -rf "$OBJ_DIR"

ls -lh "$OUT_DIR/libyoga.a"
echo "done: $OUT_DIR/libyoga.a"
