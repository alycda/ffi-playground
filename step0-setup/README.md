# Step 0: Setup

## Goal

Verify your Rust environment is working and understand the library structure.

## What's Here

- `Cargo.toml` - Project configuration with `cdylib` crate type for FFI
- `src/lib.rs` - A minimal library with one function

## Tasks

### 1. Build the library

```bash
cd step0-setup
cargo build
```

### 2. Run the tests

```bash
cargo test
```

### 3. Find the output

After building, check `target/debug/` for your library:
- macOS: `libffi_playground.dylib`
- Linux: `libffi_playground.so`
- Windows (WSL2): `libffi_playground.so`

```bash
ls -la target/debug/*.dylib 2>/dev/null || ls -la target/debug/*.so 2>/dev/null
```

## Key Concepts

### Crate Types

```toml
[lib]
crate-type = ["cdylib", "rlib"]
```

- **cdylib**: C-compatible dynamic library. This is what other languages load.
- **rlib**: Rust library format. Needed for `cargo test` to work.

### Why Both?

You need `cdylib` for FFI consumers (Python, Kotlin, Swift, C).
You need `rlib` for Rust consumers (tests, benchmarks, other Rust code).

## Checkpoint

- [ ] `cargo build` succeeds
- [ ] `cargo test` passes
- [ ] You can find the `.dylib` or `.so` file

## Next Step

Step 1 — your first `extern "C"` symbol across the boundary — arrives with
the workshop. This checkpoint is everything you need before then.
