#!/bin/sh
# Build + run the yoga test suite natively. MSC=... overrides the compiler
# (e.g. MSC="bun /Users/le/metascript/recompiler/bun/run.ts" for the
# bun-hosted tree while a compiler fix is not yet synced to ~/.metascript).
set -e
cd "$(dirname "$0")/.."
MSC="${MSC:-msc}"
rm -rf out
$MSC build test/layout.test.ms
./out/debug/layout.test
