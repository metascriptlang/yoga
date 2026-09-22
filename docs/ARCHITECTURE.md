# Architecture

`@metascript/yoga` is the framework-independent MetaScript binding for the vendored Yoga layout engine. Neon, Void, and standalone applications are consumers; none owns this package or is required to use it.

## Boundary

```text
host tree and lifecycle
        │
        ▼
@metascript/yoga typed API or host protocol
        │
        ▼
Yoga flat C API
        │
        ▼
vendored Yoga C++ core
```

The responsibilities on either side of that flow are deliberately separate:

- The consumer owns its node tree, style production, lifecycle, and rendering.
- This package owns the MetaScript API, host adaptation, vendored dependency, and native dependency declarations.
- `msc` owns target selection, native compilation, dependency tracking, caching, and final linking.
- An outer build system may supply the SDK, architecture, deployment target, packaging, and signing context. It does not reproduce Yoga's native dependency graph.

Ion can provide the outer Xcode context and Neon can provide a host tree, but those are integrations of the boundary, not dependencies of the package.

## Integration modes

A direct consumer uses the package-owned node wrapper and layout entry points exported by `src/index.ms`. A framework or renderer can instead adapt its own node type to the generic pass in `src/sync.ms`.

The generic host protocol is static and cross-module: its host extensions must be exported because the instantiated walker calls them from this package's translation unit. Style snapshots are compared by reference, so a restyle replaces the style object rather than mutating it in place. These constraints preserve direct calls and avoid a runtime adapter or dispatch layer.

## Native dependency ownership

The package vendors Yoga under `deps/yoga/`; consumers do not maintain a second source or linker inventory.

The artifact strategy may differ by target without changing the public layout API. iOS compiles package-owned C++ sources through the declarations in `src/yogaH.ms`, using the active compiler target and SDK context. macOS, Windows, and Emscripten use archives produced by `scripts/build-yoga.sh`. The current target mapping and source inventory live in those files and are not duplicated here.

This boundary gives each fact one owner:

- Yoga knows which native implementation it requires.
- `msc` knows how native inputs participate in a build and invalidate its caches.
- The consumer knows only which target it is building.

A standalone MetaScript iOS application therefore needs a valid iOS compiler context, not Ion or Neon and not a separately prepared Yoga archive.

## Rejected boundaries

### Consumer-built iOS archives

Requiring every consumer to select or build a simulator/device archive moves package knowledge into application setup and creates an artifact matrix outside the compiler's ordinary dependency graph. Package-owned source compilation keeps target selection with the active build.

### Native source inventories in Ion, Neon, or project files

Copying Yoga's source list or flags into a framework or project generator creates two owners. A vendored-source change can then leave generated projects stale even though the package itself is correct.

### Static archive plus link metadata sidecar

A static archive does not carry a complete transitive link contract. Adding a sidecar would create a new protocol for discovery, ordering, quoting, cache identity, and downstream tool integration. The current whole-application build already lets `msc` own those concerns.

### Generated-source scanning

Scanning compiler outputs or regenerating project files when native inputs change makes an outer build system infer compiler state. Native declarations remain in the imported package so ordinary compiler dependency tracking is authoritative.

## Stability contract

Consumers may depend on the exports from `src/index.ms` and, when adapting a host tree, the protocol defined by `src/sync.ms`. They must not depend on deep module imports, the vendored source inventory, archive object order, or an iOS archive path.

Target-specific compilation and archive choices are implementation details. Changing one must preserve the public MetaScript API and keep native dependency ownership inside this package.

## Code pointers

- Public package boundary: `src/index.ms`
- Raw C API and target-owned native declarations: `src/yogaH.ms`
- Generic host protocol: `src/sync.ms`
- Direct node wrapper: `src/node.ms`
- Archive builder: `scripts/build-yoga.sh`
- Vendored-source provenance and update procedure: `deps/yoga/UPSTREAM.md`
