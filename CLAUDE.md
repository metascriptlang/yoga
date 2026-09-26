# Yoga — Flexbox Layout for MetaScript

Yoga (Facebook's C++ flexbox engine, v3.x) bindings for MetaScript.

## Architecture

Durable package boundaries, integration modes, native dependency ownership, and rejected alternatives live in `docs/ARCHITECTURE.md`. This file keeps the contributor-facing build, coding, limitation, and gate rules.

## Build

Yoga is **vendored** at `deps/yoga/` (Facebook source, v3.x). iOS and Android consumers compile the package-owned sources declared in `src/yogaH.ms` through ordinary `msc build`; the compiler supplies the active SDK or NDK target, dependency tracking, and native object cache. macOS, Windows, and Emscripten consume prebuilt archives:

```bash
scripts/build-yoga.sh macos      # → deps/yoga/build/macos/libyoga.a
scripts/build-yoga.sh windows    # → deps/yoga/build/windows/libyoga.a
scripts/build-yoga.sh emscripten # → deps/yoga/build/emscripten/libyoga.a
```

The archive script invokes the C++20 compiler directly without cmake.

## Conventions

- **camelCase** for files, vars, functions; **PascalCase** for types. No snake_case (Yoga's `YGNodeStyleSetFlexDirection` is C-API extern only; our public API wraps it as `applyStyle(node, {flexDirection: "column"})`).
- **Memory**: pair `YGNodeNew`/`YGNodeFreeRecursive` via `freeYogaNode(node)` + `defer`. Wrap in `struct YogaNode` for DRC auto-cleanup where it makes sense.
- **No `any`**: use `unknown` + narrowing. A C handle keeps its header type: a node is `Ptr<YGNode>` (`YGNode` imported from `Yoga.h`, exported by `src/index.ms` for hosts), never `Ptr<void>`. msc refuses `Ptr<void>` → `Ptr<T>` by design (Nim: `pointer` into `ptr T`), so a handle stored untyped cannot reach the C API again without a cast.
- **Layering**: `yogaH.ms` (raw C externs) → `node.ms`/`style.ms`/`layout.ms`/`sync.ms` (typed wrappers + generic pass) → `index.ms` (public API). One-way deps. **Consumers import ONLY `src/index.ms`** — never deep paths (one find/replace when the package loader lands).

## Known Limitations

- **Backend is C++.** Yoga 3.x requires C++20. On iOS and Android, msc compiles the package-owned sources declared in `src/yogaH.ms`; macOS, Windows, and Emscripten use `libyoga.a`. Only the flat C-API is bound to MetaScript.
- **`import-from-.h` not used.** msc's `.h` parser is C-only and doesn't follow `#include`. Use `extern function + @include` pattern (proven in void2d `gpu.ms`).
- **No measure callbacks yet.** `YGMeasureFunc` (for intrinsic-size text) needs a C-bridge for MetaScript callbacks. Planned.
- **No percent/auto dimensions yet.** FlexStyle fields are `float32 | null` (points only). `"50%"`/`"auto"` needs `float32 | string | null` fields — planned after the points-only surface is proven on Void.
- **Receiver form on `Ptr<YGNode>`.** `CODE-STYLE.md` §5 wants `yg.applyStyle(s)`, but msc does not resolve an extension whose receiver is `Ptr<T>` (card `~/metascript/.inbox/compiler/2026-09-22-method-call-is-not-an-ordinary-call.md`). `applyStyle` and the `set*` helpers in `src/style.ms` stay free functions until it lands.

## Git and the gate

Yoga follows the worktree playbook enabled by `~/metascript/CLAUDE.md` and uses `~/nerdtools/claude/tools/wt.sh` with the gate below. The shared session context reads this repo's card and `~/metascript/.inbox/yoga/`. A MetaScript or runtime limitation follows the workspace compiler boundary: repro, card in `~/metascript/.inbox/compiler/`, park, move on.

The gate is `sh scripts/test.sh`, read by its exit code (green 2026-09-20 on `msc` build `94c23bfd`: `yoga-layout PASS (34 checks)`). A change to `src/sync.ms` or to the seven layout extensions also runs void's consumer of the pass, `msc test tests/layout.test.ms` in `~/metascript/void` — that entry is red today for a compiler reason, card `2026-09-20-typeinfo-demanded-but-reachability-marked-it-dead`.

## References

- Yoga source: https://github.com/facebook/yoga
- Yoga docs: https://yogalayout.com
- Nim bindings (reference): `~/projects/neon/src/core/yoga.nim`
- React Native layout: https://reactnative.dev/docs/flexbox
