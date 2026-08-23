// Exercise 3, Swift track — hand-written route.
//
// Compile from this directory. -L points at the workspace target directory,
// shared by both exercise crates; the header is per-crate.
//
//   swiftc main.swift \
//       -import-objc-header ../../ex2-c-glue/include/ex2_c_glue.h \
//       -L ../../target/release -lex2_c_glue -o ex3
//
// Then run it. The loader needs *two* things, not one: your Rust library,
// and Swift's own runtime — the Swift standard library links against
// libdispatch.so whether or not your code ever mentions Dispatch. On
// nixpkgs those runtime libraries live in the profile rather than beside
// swiftc, so leaving them out gets you a binary that compiles, links, and
// then dies at startup with:
//
//   error while loading shared libraries: libdispatch.so
//
// which reads like your Rust is broken and is not about your Rust at all.
//
//   SWIFT_RT="$HOME/.nix-profile/lib:$HOME/.nix-profile/lib/swift/linux/$(uname -m)"
//   LD_LIBRARY_PATH="../../target/release:$SWIFT_RT" \
//   DYLD_LIBRARY_PATH="../../target/release:$SWIFT_RT" ./ex3
//
// On macOS the toolchain ships its own runtime and SWIFT_RT is simply
// empty, which is why it is written as a separate variable — the line then
// works unchanged on both. This is the same dance
// days/2024-12-03/uniffi/build-and-test.sh does for the generated route;
// read its swift) branch if you want the fully defensive version.
//
// Why is this file named main.swift? Because top-level code is only
// allowed there — a rule most Swift developers learn the hard way, and
// one worth knowing before you rename anything.
//
// Prerequisite: Exercise 2 has to have been built, so the library exists.
// `cd ../../ex2-c-glue && ./build-and-test.sh` does that.

#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

// TODO 1: your day's example input and expected answer, from the puzzle
// statement. Never your real input.
//
// Swift strings are UTF-16 internally. What happens on the way to
// `const char *`? Module 3 answered it; this is where you watch it happen.
let example = "PASTE YOUR DAY'S EXAMPLE INPUT HERE"
let expectedPart1: Int64 = 0

// TODO 2: call ex_part1.
//
// Swift auto-bridges String to UnsafePointer<CChar> for C functions taking
// `const char *` — it allocates, converts, calls, and frees, all invisibly,
// and the borrow is only valid for the duration of the call. That is
// exactly the work Exercise 2 made you do by hand, and exactly the work the
// Dart track still makes you do by hand.
//
// Free lunch, or hidden cost? You now know enough to have an opinion, and
// it is the debrief question in its sharpest form: the header said nothing
// about any of this.
let got: Int64 = -999  // replace with the real call

guard got != -999 else {
    print("TODO 2 not done yet — replace `got` with the real call.")
    exit(1)
}

guard got == expectedPart1 else {
    print("part1 = \(got), expected \(expectedPart1)")
    exit(1)
}

// TODO 3: the hostile-input contract. How do you pass NULL from Swift?
// The imported signature takes an Optional pointer, so `nil` is spelled
// exactly the way you would hope — which is more than the other three
// tracks can say.

print("Ex 3 (Swift) passed.")
