#!/usr/bin/env bash
# Exercise 2: build the Rust cdylib, generate the C header, compile the C
# harness against it, and run it. The same four beats as the Module 2 demo
# (../../days/2015-12-01/c-glue/demo.sh), which is the point.
#
# Usage: ./build-and-test.sh    (from exercises/ex2-c-glue/)
#
# Expect this to ABORT the first time you run it, before you have implemented
# anything: `todo!()` panics, the panic tries to unwind across an `extern "C"`
# frame, and Rust kills the process instead of allowing that. "fatal runtime
# error: Rust cannot catch foreign exceptions" or a plain abort is what
# success looks like at that stage. Run it once on purpose.
set -euo pipefail
cd "$(dirname "$0")"

# Where cargo actually puts the library. exercises/ is a cargo workspace, so
# the target directory is shared at exercises/target — there is no
# ./target/release in this crate, and hardcoding one breaks on the first
# machine that isn't yours. `cargo locate-project` rather than
# `cargo metadata | jq`, because a script attendees run cannot assume a JSON
# processor is installed.
WORKSPACE_ROOT="$(dirname "$(cargo locate-project --workspace --message-format plain)")"
RELEASE_DIR="${CARGO_TARGET_DIR:-$WORKSPACE_ROOT/target}/release"

# 1. Rust -> shared library
echo "==> cargo build --release"
cargo build --release

# 2. Rust -> C header. This is the artifact worth reading — open it.
echo "==> cbindgen --output include/ex2_c_glue.h"
mkdir -p include
cbindgen --output include/ex2_c_glue.h

# 3. Compile the C harness against your header and link it to your library.
#    -Werror on purpose: if the generated header cannot satisfy a C compiler
#    in its strictest ordinary mode, that is worth knowing now.
echo "==> cc tests/c/test_glue.c"
mkdir -p target/c-tests
cc -Wall -Wextra -Werror -std=c99 \
    -Iinclude \
    tests/c/test_glue.c \
    -L"$RELEASE_DIR" -lex2_c_glue \
    -o target/c-tests/test_glue

# 4. Run it. The cdylib is resolved at run time rather than baked in, so the
#    loader has to be told where cargo left it: DYLD_LIBRARY_PATH on macOS,
#    LD_LIBRARY_PATH on Linux. Setting both keeps this portable. If you ever
#    see "library not found" or "cannot open shared object file", this line is
#    the reason — it is the most common failure of the whole day.
echo "==> running the C harness"
DYLD_LIBRARY_PATH="$RELEASE_DIR" LD_LIBRARY_PATH="$RELEASE_DIR" \
    ./target/c-tests/test_glue
