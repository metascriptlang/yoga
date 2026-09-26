#!/bin/sh
# Run the yoga test suite through `msc test`. MSC=... overrides the compiler
# (e.g. MSC="bun /Users/le/metascript/recompiler/bun/run.ts" for the
# bun-hosted tree while a compiler fix is not yet synced to ~/.metascript).
set -e
cd "$(dirname "$0")/.."
MSC="${MSC:-msc}"
$MSC test test/layout.test.ms
