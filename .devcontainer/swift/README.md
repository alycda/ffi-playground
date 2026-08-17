# Swift on Linux, in a container, without the glibc fight

Swift on Linux has a reputation, earned via the official swift.org tarballs:
they're built against one distro's glibc and anything else is a linker fight.
This container sidesteps that entirely — nixpkgs ships Swift built against
Nix's own glibc, and on aarch64-linux (and x86_64-linux) it comes straight
from the binary cache: ~660 MiB download, 3 GiB unpacked, **nothing compiles
from source**.

## Status 2026-08-17: `import Foundation` does not compile here

Read this before the "Verified" section below, which it supersedes. A
two-line hello-world fails in this container:

```sh
printf 'import Foundation\nprint("hi")\n' > /tmp/t.swift && swiftc /tmp/t.swift -o /tmp/t1
# error: no such module 'Foundation'
```

No UniFFI, no bridging header, no repo environment involved — it fails the
same inside the repo's direnv shell and in `/tmp` with direnv unloaded. Three
distinct errors came up while chasing it, in this order. Each one is a
different problem, and the progression is the useful part:

**1. `no such module 'Foundation'`.** nixpkgs installs corelibs Foundation
into the *profile* (`~/.nix-profile/lib/swift/linux/<arch>/Foundation.swiftmodule`),
while `swiftc` — which resolves to
`/nix/store/…-swift-wrapper-5.10.1/bin/swiftc` — searches only its own
toolchain path. The module is on disk and invisible. Passing
`-I ~/.nix-profile/lib/swift/linux/<arch>` gets past it.

**2. `missing required modules: 'CoreFoundation', 'Dispatch'`.** Foundation's
Swift module requires two *clang* modules that live in
swift-corelibs-libdispatch, and `swiftPackages.Foundation` does not pull it
in: the profile held exactly `Foundation`, `FoundationNetworking` and
`FoundationXML` and nothing else. No flag fixes a module that was never
installed, so `home.nix` now installs `swiftPackages.Dispatch` too.

**3. `cannot load underlying module for 'Dispatch'`** — where it stands now.
The Swift `Dispatch` module resolves, but the C library it wraps cannot be
loaded. Adding `-Xcc -I~/.nix-profile/include` (libdispatch's headers carry
their own module map under `include/dispatch/`) did not clear it.

### What this means

The container as shipped cannot build a Swift file that imports Foundation,
which is every non-trivial Swift file. The **"Verified" section below is not
reproducible** — its example could not have compiled with `import Foundation`
present, and caveat 1 there describes a *runtime* libdispatch failure, which
is a strictly later stage than what fails now. Most likely nixpkgs moved
underneath it, which that section already names as the expected trigger.

### Next things worth trying, cheapest first

1. `ls ~/.nix-profile/include` and
   `find ~/.nix-profile/include -name 'module*map'` — if libdispatch's headers
   are not in the profile at all, its module map cannot be found by any flag,
   and the package set is the problem rather than the search paths.
2. Build through nixpkgs' Swift stdenv adapter (`swiftPackages.stdenv`) or
   `swiftpm` rather than calling `swiftc` from a home-manager profile. Those
   wire the corelibs search paths themselves, which is why this only bites a
   hand-rolled `swiftc` invocation.
3. Pin nixpkgs to a revision where this worked, if one can be found.
4. Take this file's own escape hatch (bottom): delete the folder and let the
   justfile's swift.org pointer be the answer again. With the workshop three
   weeks out, that is not a defeat — Swift already has a golden day's harness
   written, and every other track is verified.

### What the day library does about it meanwhile

`days/2024-12-03/uniffi/build-and-test.sh swift` carries the `-I`/`-L` and
`-Xcc` flags from steps 1–3. They are harness-side workarounds for a
container-side problem and should be reconsidered once this is fixed — but
they are not wrong on their own terms: Foundation genuinely is not on
`swiftc`'s default search path in this profile.

## Verified (2026-08, aarch64-linux container, nixpkgs unstable) — SUPERSEDED

See the status section above: this is retained as the record of what was
claimed, not as instructions.

The full workshop FFI shape works:

```sh
cc -shared -fPIC librust.c -o librust_add.so       # stand-in for the Rust cdylib
swiftc -import-objc-header bridge.h main.swift -L. -lrust_add -o ffi_swift
LD_LIBRARY_PATH="$PWD" ./ffi_swift                  # → ffi says 42
```

## Known caveats — read before filing "it's broken"

1. **`import Foundation` is load-bearing.** A Swift file that only uses the
   bridging header links fine but dies at runtime with
   `libdispatch.so: cannot open shared object file`. libdispatch is pulled in
   transitively (via libswift_Concurrency), and the Nix swift wrapper only
   embeds the rpath to it when Foundation is actually imported. Add
   `import Foundation` to your main file and it resolves.
2. **`LD_LIBRARY_PATH="$PWD"` to run.** Your own freshly built dylib isn't on
   any rpath; the Swift runtime libs are, so only the current directory needs
   adding.
3. **It's Swift 5.10.1.** Current Swift is 6.x; nixpkgs lags. Fine for the
   FFI exercise (C interop hasn't moved), not fine if you want Swift 6
   concurrency-mode anything.
4. The `glibc not found for 'aarch64-unknown-linux-gnu'` warning from swiftc
   is cosmetic — binaries build and run.

If any of this rots (nixpkgs bumping swift is the likely trigger), and fixing
it isn't fun: delete this folder and let the justfile's swift.org pointer be
the answer again. This README doubles as the tombstone inscription.
