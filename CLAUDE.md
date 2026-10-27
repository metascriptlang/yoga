# Yoga — Flexbox Layout for MetaScript

Yoga (Facebook's C++ flexbox engine, v3.x) bindings for MetaScript.

## Architecture

Durable package boundaries, integration modes, native dependency ownership, and rejected alternatives live in `docs/ARCHITECTURE.md`. This file keeps the contributor-facing build, coding, limitation, and gate rules.

## Build

Yoga is **vendored** at `deps/yoga/` (Facebook source, v3.x). iOS, Android, Emscripten and Linux consumers compile the package-owned sources declared in `src/yogaH.ms` through ordinary `msc build`; the compiler supplies the active SDK, NDK, emsdk or Linux target, dependency tracking, and native object cache. macOS and Windows consume prebuilt archives:

```bash
scripts/build-yoga.sh macos      # → deps/yoga/build/macos/libyoga.a
scripts/build-yoga.sh windows    # → deps/yoga/build/windows/libyoga.a
```

The archive script invokes the C++20 compiler directly without cmake.

## Conventions

- **camelCase** for files, vars, functions; **PascalCase** for types. No snake_case (Yoga's `YGNodeStyleSetFlexDirection` is C-API extern only; our public API wraps it as `applyStyle(node, {flexDirection: "column"})`).
- **Memory**: a Yoga node is native memory that DRC does not see. A `YogaNode` tree (an `interface`, refcounted wrappers only) is released with `root.freeYogaNode()`; a host tree with `freeLayoutTree(root)`, and a node the host drops from its tree with `freeLayoutTree(node)` (`docs/ARCHITECTURE.md` §Integration modes).
- **No `any`**: use `unknown` + narrowing. A C handle keeps its header type: a node is `Ptr<YGNode>` (`YGNode` imported from `Yoga.h`, exported by `src/index.ms` for hosts), never `Ptr<void>`. msc refuses `Ptr<void>` → `Ptr<T>` by design (Nim: `pointer` into `ptr T`), so a handle stored untyped cannot reach the C API again without a cast.
- **Layering**: `yogaH.ms` (raw C externs) → `node.ms`/`style.ms`/`layout.ms`/`sync.ms` (typed wrappers + generic pass) → `index.ms` (public API). One-way deps. **Consumers import ONLY `src/index.ms`** — never deep paths (one find/replace when the package loader lands).

## Known Limitations

- **Backend is C++.** Yoga 3.x requires C++20. On iOS, Android, Emscripten and Linux, msc compiles the package-owned sources declared in `src/yogaH.ms`; macOS and Windows use `libyoga.a`. Only the flat C-API is bound to MetaScript.
- **No measure callbacks yet.** `YGMeasureFunc` (for intrinsic-size text) needs a C-bridge for MetaScript callbacks. Planned.
- **Invalid style values fail silently.** `"auto"` on padding, position, gap and min/max is dropped (the `Unit.Auto => {}` arms in `src/style.ms`), and an unparsable dimension string becomes `NaN` through `parseFloat`. Where this should fail loud (compile time for literal styles, run time in `applyStyle`, or both) is an open design question.
- **Receiver form on `Ptr<YGNode>`.** `CODE-STYLE.md` §5 wants `yg.applyStyle(s)`, but msc does not resolve an extension whose receiver is `Ptr<T>` (card `~/metascript/.inbox/compiler/2026-09-22-method-call-is-not-an-ordinary-call.md`). `applyStyle` and the `set*` helpers in `src/style.ms` stay free functions until it lands.

## Git and the gate

Yoga follows the worktree playbook enabled by `~/metascript/CLAUDE.md` and uses `~/nerdtools/claude/tools/wt.sh` with the gate below. The shared session context reads this repo's card and `~/metascript/.inbox/yoga/`. A MetaScript or runtime limitation follows the workspace compiler boundary: repro, card in `~/metascript/.inbox/compiler/`, park, move on.

The gate is `sh scripts/test.sh` (`msc test test/layout.test.ms`), read by its exit code (green 2026-10-01 on `msc` build `013853dd` and on a build of recompiler `main` `347ad600`: the file's 23 tests pass). Every test also asserts that no Yoga node outlives it, counted from Yoga's own allocation events by `test/yogaCount.cpp`. A change to `src/sync.ms` or to the seven layout extensions also runs void's consumer of the pass: `msc build tests/layout.test.ms && ./out/debug/layout.test` in `~/metascript/void`. That file has no `test` blocks, so `msc test` there only builds it. On 2026-09-26 the run printed `void-layout PASS (15 checks)` on a copy of Void whose `yg` field is `Ptr<YGNode>`; Void main does not build that file: on 2026-10-01 (`msc` `013853dd`, Void `69e1f7c`) it stops at 42 type errors, 2 from the untyped `yg` field (`~/metascript/.inbox/void/2026-09-26-yoga-typed-handle.md`) and 40 writes into `const` arrays (`~/metascript/.inbox/void/2026-09-28-const-vec-element-write.md`).

## References

- Yoga source: https://github.com/facebook/yoga
- Yoga docs: https://yogalayout.com
- Nim bindings (reference): `~/projects/neon/src/core/yoga.nim`
- React Native layout: https://reactnative.dev/docs/flexbox
