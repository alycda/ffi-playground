# Swift on Linux, in a container, without the glibc fight

Swift on Linux has a reputation, earned via the official swift.org tarballs:
they're built against one distro's glibc and anything else is a linker fight.
This container sidesteps that entirely — nixpkgs ships Swift built against
Nix's own glibc, and on aarch64-linux (and x86_64-linux) it comes straight
from the binary cache: ~660 MiB download, 3 GiB unpacked, **nothing compiles
from source**.

## Verified (2026-08, aarch64-linux container, nixpkgs unstable)

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
