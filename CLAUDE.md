# Yoga — Flexbox Layout for MetaScript

Yoga (Facebook's C++ flexbox engine, v3.x) bindings for MetaScript. One layout engine across **every** MetaScript target — Desktop, iOS, Android, Browser, Terminal.

## What this is

- **Production-grade flexbox.** Same engine React Native uses (`yogalayout.com`).
- **One API, every platform.** Native (Metal/D3D11/GL/Vulkan) + Browser (WebGPU/WebGL2) — single source.
- **React/RN-friendly surface.** String-literal enums (`"column" | "row"`), `style={{flex: 1}}` shape, `flexGrow`/`marginHorizontal`/etc.
- **Zero custom dirty code.** Yoga's `YGNodeIsDirty` + `YGNodeGetHasNewLayout` handle invalidation + cache.
- **Opt-in per node.** `Node2D.layoutStyle?: FlexStyle` — set it to participate in layout, leave null for manual Heaps-style positioning.

## Layering

```
                        ┌─ Neon (Layer A: reconcile) ─┐
                        |   JSX style={{...}} →        |
                        |   node.layoutStyle = ...     |
                        └──────────────┬───────────────┘
                                       │ (imperative in Void standalone)
                                       ▼
@metascript/yoga  ◀── this package ─▶  layoutTree(root)
  │                                    │
  │ FlexStyle  →  YGNodeStyleSet*       │
  │ YGNodeCalculateLayout  (Yoga core)  │
  │ LayoutResult ← YGNodeLayoutGet*     │
  │                                     │
  └─────────────┬───────────────────────┘
                ▼
   Host reads YogaNode.layout {left, top, width, height}
                │
                ▼
   void2d Paint (Layer B) → sokol_gfx (Layer C)
```

See `~/metascript/neon/docs/RENDER-LAYERS.md` for the full 3-layer model.

## Build

Yoga is **vendored** at `deps/yoga/` (Facebook source, v3.x). The C++ core compiles to a static lib per platform:

```bash
scripts/build-yoga.sh macos     # → deps/yoga/build/macos/libyoga.a
scripts/build-yoga.sh ios       # → deps/yoga/build/ios/libyoga.a
scripts/build-yoga.sh ios-sim   # → deps/yoga/build/ios-sim/libyoga.a
scripts/build-yoga.sh emscripten # → deps/yoga/build/emscripten/libyoga.a
```

Direct `clang++ -std=c++20` (no cmake) — one source list, one ar invocation.

## MetaScript Strengths Exploited

| Strength | Use |
|---|---|
| `extern function` + `@include` | Bind Yoga C-API directly (no hand-written C bridge — Yoga's C-API is already flat) |
| `struct` value types | `LayoutResult { left, top, width, height }` zero-alloc on hot path |
| `defer` | `defer freeYogaNode(node)` cleanup tường minh |
| String-literal unions | `type FlexDirection = "column" \| "row" \| ...` — React-friendly, exhaustively checked |
| `match` | Enum dispatch (e.g. `flexDirection` string → int32 for C-API) |
| DRC | Auto-cleanup of `YogaNode` wrappers (when last ref dropped) |

## C-API surface

Bound in `src/yogaH.ms` — ~80 `extern function` declarations (setters + layout getters + lifecycle + dirty + config), trimmed from the Nim reference at `~/projects/neon/src/core/yoga.nim`. `YGValue`-returning style getters are deliberately unbound (struct-by-value FFI untested; wrapper API needs none of them). Public C-API headers (vendored at `deps/yoga/yoga/`):

- `YGNode.h` — node lifecycle, tree ops, dirty machinery
- `YGNodeStyle.h` — style setters (flexDirection, margin, padding, ...)
- `YGNodeLayout.h` — layout read-back (getLeft/Top/Width/Height)
- `YGConfig.h` — config (point scale factor, errata, logger)
- `YGEnums.h` — auto-generated enum declarations
- `YGValue.h` — `YGValue { value, unit }` struct + constants
- `YGPixelGrid.h` — pixel-grid rounding helpers
- `Yoga.h` — umbrella (just `#include`s the above)

## Shared layout pass — `src/sync.ms` (convention protocol)

`layoutPass<T>(root, w, h)` + `freeLayoutTree<T>(root)` are generic over ANY host node tree — the cross-module convention protocol from recompiler `docs/PROTOCOLS.md` Part II. A host opts in with seven **exported** extensions on its node type (`layoutGetChildren`, `layoutGetStyle`, `layoutGetLastStyle`, `layoutSetLastStyle`, `layoutGetYg`, `layoutSetYg`, `layoutSetFrame`); the walker monomorphizes to direct static calls — zero dispatch cost.

Consumers today: `YogaNode` (opt-in lives in `node.ms`) and Void's `Node2D` (`void/src/void2d/layout.ms`, ~35 lines). iOS/Android/desktop hosts later copy the same shape. `export` on the extensions is REQUIRED — the monomorphized pass is emitted in this package's TU and calls them cross-TU. Style objects are reference-compared: restyle = assign a fresh `FlexStyle`, never mutate.

Neon never imports this package: the reconciler only does `setAttr("style", ...)` through the Host seam; each host maps that to its `layoutStyle` (DOM host maps to CSS instead).

## Conventions

- **camelCase** for files, vars, functions; **PascalCase** for types. No snake_case (Yoga's `YGNodeStyleSetFlexDirection` is C-API extern only; our public API wraps it as `applyStyle(node, {flexDirection: "column"})`).
- **Memory**: pair `YGNodeNew`/`YGNodeFreeRecursive` via `freeYogaNode(node)` + `defer`. Wrap in `struct YogaNode` for DRC auto-cleanup where it makes sense.
- **No `any`**: use `unknown` + narrowing. Opaque pointers are `Ptr<void>`.
- **Layering**: `yogaH.ms` (raw C externs) → `node.ms`/`style.ms`/`layout.ms`/`sync.ms` (typed wrappers + generic pass) → `index.ms` (public API). One-way deps. **Consumers import ONLY `src/index.ms`** — never deep paths (one find/replace when the package loader lands).

## Known Limitations

- **Backend is C++.** Yoga 3.x requires C++20. We compile the C++ core into `libyoga.a` via clang++; only the flat C-API is bound to MetaScript.
- **`import-from-.h` not used.** msc's `.h` parser is C-only and doesn't follow `#include`. Use `extern function + @include` pattern (proven in void2d `gpu.ms`).
- **No measure callbacks yet.** `YGMeasureFunc` (for intrinsic-size text) needs a C-bridge for MetaScript callbacks. Planned.
- **No percent/auto dimensions yet.** FlexStyle fields are `float32 | null` (points only). `"50%"`/`"auto"` needs `float32 | string | null` fields — planned after the points-only surface is proven on Void.
- **Build from repo root.** `@passC("-Ideps/yoga")` resolves against the build CWD (`@link` paths resolve against the source file, so they survive cross-repo imports). A consumer repo (e.g. Void) importing `src/index.ms` by relative path must make `deps/yoga` resolvable from its own root — symlink `ln -s ../yoga/deps/yoga deps/yoga`. Candidate msc fix: make `@passC` source-relative like `@link`.
- **Detached yoga nodes leak.** `freeLayoutTree` frees the ROOT island only (`YGNodeFreeRecursive`); a node whose yg was detached during a sync rebuild (removed from tree / layoutStyle→null between passes) is orphaned — ~19KB across the Void test suite, pre-existing since the pre-DRY version. Candidate fix: free the yg in `syncLayoutNode`'s rebuild path when a child leaves the island.

## Co-Evolution Policy

When hitting a MetaScript or runtime limitation:
1. Stop Yoga work
2. Fix in `~/metascript/recompiler` (compiler) or runtime
3. Return to Yoga with proper support

Never workaround compiler issues — we own the whole stack.

## References

- Yoga source: https://github.com/facebook/yoga
- Yoga docs: https://yogalayout.com
- Nim bindings (reference): `~/projects/neon/src/core/yoga.nim`
- React Native layout: https://reactnative.dev/docs/flexbox
