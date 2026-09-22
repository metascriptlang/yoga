# Vendored upstream

- **Source**: https://github.com/facebook/yoga
- **Vendored from**: branch `main`, 2026-07-08 (exact SHA unrecorded — the original `.git` pointer was removed; API surface is the v3.x line)
- **Trim**: C/C++ core only — `yoga/`, `cmake/`, `CMakeLists.txt`, packaging + license files. Upstream's `java/`, `javascript/`, `website/`, `tests/`, `gentest/` are excluded.
- **Local additions (NOT upstream)**: `build/` (macOS, Windows, and Emscripten `libyoga.a` archives produced by `scripts/build-yoga.sh`) and this file. iOS compiles the vendored sources declared in `src/yogaH.ms`. Never overwrite the local additions when re-vendoring.
- **No local patches.** The MetaScript side binds the flat C API via `extern function` only (`src/yogaH.ms`); upstream sources are byte-identical to the trim.

## Update procedure

```bash
scripts/update-yoga.sh v3.2.0        # fetch tag, re-trim, replace, re-pin this file
scripts/build-yoga.sh macos          # rebuild the static lib
sh scripts/test.sh
git commit -m "chore: bump yoga to v3.2.0"
```
