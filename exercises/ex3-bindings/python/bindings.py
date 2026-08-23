#!/usr/bin/env python3
"""Exercise 3, Python track — hand-written route, using cffi.

Bind the library you built in Exercise 2 and call it from Python. Fill in
the TODOs top to bottom, then run it.

cffi is not in the standard library, and the repo keeps it in a virtualenv
that `just setup-python` creates. Activate that first or the import below
fails before you get anywhere:

    source ../../../.venv/bin/activate    # from this directory
    python3 bindings.py

(`just check` at the repo root reports whether your Python track is ready.)

Prerequisite: Exercise 2 has to have been built, so the shared library
exists. `cd ../../ex2-c-glue && ./build-and-test.sh` does that (it still
aborts at todo!() until you finish Ex 2 — the library is built either way).
"""

import os
import sys
from pathlib import Path

from cffi import FFI

ffi = FFI()

# The value ex_part* returns for hostile input. It is -1 by default, but
# ex2-c-glue/src/lib.rs tells you to move it to i64::MIN when your day can
# legitimately return -1 — 2015-12-01 can. The C harness reads this from the
# generated header and follows you automatically; this hand-maintained
# binding cannot, so it is one more thing nothing keeps in sync but you.
INVALID_INPUT = -1

# The workspace target directory. Both exercise crates share it, which is
# why this is ../../target and not ex2-c-glue/target — and why it honours
# CARGO_TARGET_DIR, exactly as ex2-c-glue/build-and-test.sh does. Hardcoding
# it breaks on the first machine that isn't yours, and it breaks quietly:
# Ex 2 builds and passes, then this exits saying there is no library.
TARGET = Path(
    os.environ.get("CARGO_TARGET_DIR")
    or Path(__file__).resolve().parent.parent.parent / "target"
) / "release"

# Linux ships .so, macOS ships .dylib. Same library, and the fact that the
# name differs per platform is the first thing the C header didn't tell you.
LIB_PATH = next(
    (p for p in (TARGET / "libex2_c_glue.so", TARGET / "libex2_c_glue.dylib") if p.exists()),
    None,
)

if LIB_PATH is None:
    sys.exit(
        f"No Ex 2 library in {TARGET}.\n"
        "Build it first: cd ../../ex2-c-glue && ./build-and-test.sh"
    )

# TODO 1: declare the C interface.
#
# Open ../../ex2-c-glue/include/ex2_c_glue.h and copy the two function
# declarations in here. cffi parses real C, so the header's lines work
# almost verbatim — but only the declarations. cdef() rejects #include
# outright; it tolerates #define and the comments cbindgen carries over,
# which is why the stub below — a comment and nothing else — parses at all.
# Do not mistake that tolerance for a safety net: this is a second,
# hand-maintained copy of the contract, and nothing keeps the two in sync
# but you.
ffi.cdef(
    """
    /* paste the two `int64_t ex_part*(const char *);` declarations here */
    """
)

lib = ffi.dlopen(str(LIB_PATH))

# TODO 2: your day's example input and its expected answer, from the puzzle
# statement. Never your real input.
EXAMPLE = "PASTE YOUR DAY'S EXAMPLE INPUT HERE"
EXPECTED_PART1 = 0

# TODO 3: call it.
#
# Python str is not a C string. `.encode("utf-8")` gives you bytes, and cffi
# appends the NUL terminator when it hands them to `const char *`. Worth
# asking while you are here: what happens if your string contains an
# embedded NUL? Python is perfectly happy with one; C is not, and the
# boundary will silently see a shorter string than you passed.
result = None  # replace with: lib.ex_part1(EXAMPLE.encode("utf-8"))

if result is None:
    sys.exit("TODO 3 not done yet — replace `result` with the real call.")

if result != EXPECTED_PART1:
    sys.exit(f"part1 = {result}, expected {EXPECTED_PART1}")

# TODO 4 (the interesting one): prove the hostile-input contract from
# Python. What Python value even *is* a null pointer here? Hint: ffi.NULL —
# and note that you cannot get there with None, which cffi rejects.
assert lib.ex_part1(ffi.NULL) == INVALID_INPUT, "null should be refused at the boundary"

print("Ex 3 (Python) passed.")
