# Yoga — Flexbox Layout for MetaScript

Yoga (Facebook's C++ flexbox engine, v3.x) bindings for MetaScript.

## Architecture

Durable package boundaries, integration modes, native dependency ownership, and rejected alternatives live in `docs/ARCHITECTURE.md`. This file keeps the contributor-facing build, coding, limitation, and gate rules.

## Build

Yoga is **vendored** at `deps/yoga/` (Facebook source, v3.x). iOS consumers compile the package-owned sources declared in `src/yogaH.ms` through ordinary `msc build`; the compiler supplies the active SDK, target, dependency tracking, and native object cache. macOS, Windows, and Emscripten consume prebuilt archives:

```bash
scripts/build-yoga.sh macos      # → deps/yoga/build/macos/libyoga.a
scripts/build-yoga.sh windows    # → deps/yoga/build/windows/libyoga.a
scripts/build-yoga.sh emscripten # → deps/yoga/build/emscripten/libyoga.a
```

The archive script invokes the C++20 compiler directly without cmake.

## Conventions

- **camelCase** for files, vars, functions; **PascalCase** for types. No snake_case (Yoga's `YGNodeStyleSetFlexDirection` is C-API extern only; our public API wraps it as `applyStyle(node, {flexDirection: "column"})`).
- **Memory**: pair `YGNodeNew`/`YGNodeFreeRecursive` via `freeYogaNode(node)` + `defer`. Wrap in `struct YogaNode` for DRC auto-cleanup where it makes sense.
- **No `any`**: use `unknown` + narrowing. Opaque pointers are `Ptr<void>`.
- **Layering**: `yogaH.ms` (raw C externs) → `node.ms`/`style.ms`/`layout.ms`/`sync.ms` (typed wrappers + generic pass) → `index.ms` (public API). One-way deps. **Consumers import ONLY `src/index.ms`** — never deep paths (one find/replace when the package loader lands).

## Known Limitations

- **Backend is C++.** Yoga 3.x requires C++20. On iOS, msc compiles the package-owned sources declared in `src/yogaH.ms`; macOS, Windows, and Emscripten use `libyoga.a`. Only the flat C-API is bound to MetaScript.
- **`import-from-.h` not used.** msc's `.h` parser is C-only and doesn't follow `#include`. Use `extern function + @include` pattern (proven in void2d `gpu.ms`).
- **No measure callbacks yet.** `YGMeasureFunc` (for intrinsic-size text) needs a C-bridge for MetaScript callbacks. Planned.
- **No percent/auto dimensions yet.** FlexStyle fields are `float32 | null` (points only). `"50%"`/`"auto"` needs `float32 | string | null` fields — planned after the points-only surface is proven on Void.
- **Detached yoga nodes leak.** `freeLayoutTree` frees the ROOT island only (`YGNodeFreeRecursive`); a node whose yg was detached during a sync rebuild (removed from tree / layoutStyle→null between passes) is orphaned — ~19KB across the Void test suite, pre-existing since the pre-DRY version. Candidate fix: free the yg in `syncLayoutNode`'s rebuild path when a child leaves the island.

## Git and the gate

Yoga follows the worktree playbook enabled by `~/metascript/CLAUDE.md` and uses `~/nerdtools/claude/tools/wt.sh` with the gate below. The shared session context reads this repo's card and `~/metascript/.inbox/yoga/`. A MetaScript or runtime limitation follows the workspace compiler boundary: repro, card in `~/metascript/.inbox/compiler/`, park, move on.

The gate is `sh scripts/test.sh`, read by its exit code (green 2026-09-20 on `msc` build `94c23bfd`: `yoga-layout PASS (34 checks)`). A change to `src/sync.ms` or to the seven layout extensions also runs void's consumer of the pass, `msc test tests/layout.test.ms` in `~/metascript/void` — that entry is red today for a compiler reason, card `2026-09-20-typeinfo-demanded-but-reachability-marked-it-dead`.

## References

- Yoga source: https://github.com/facebook/yoga
- Yoga docs: https://yogalayout.com
- Nim bindings (reference): `~/projects/neon/src/core/yoga.nim`
- React Native layout: https://reactnative.dev/docs/flexbox
