# Step -1: Machine Provisioning

Before anything else, your machine has to be able to run the workshop.
Everything required — the Rust/C toolchain (`rustc`, `cargo`, `cbindgen`, a
C compiler) and the presenter tools (`just`, `presenterm`, `mdbook`, `cheat`,
`asciinema`, `tmux`) — is declared in a single file at the repo root:
`shell.nix`. How those tools get onto your machine is your choice; the
[repo README](https://github.com/alycda/ffi-playground#readme) walks each
path in detail. In brief:

## The four paths

1. **macOS / Linux — Nix.** Install Nix (the
   [Determinate installer](https://install.determinate.systems) is the least
   fuss), then `nix-shell` in the repo root. Optionally add
   [direnv](https://direnv.net) + nix-direnv so the environment loads
   automatically on `cd` — that's what the repo's `.envrc` is for.

2. **Windows — WSL2.** Nix doesn't run natively on Windows, but WSL2 is
   Linux. `wsl --install`, then follow the Nix path inside your distro.
   Clone the repo inside WSL, not on `/mnt/c`.

3. **Docker — VS Code devcontainer.** Nothing on your machine but Docker.
   "Reopen in Container" builds Nix + home-manager inside; first build takes
   minutes, later opens are fast.

4. **💀 Entirely manual.** Install every tool yourself with your package
   manager of choice. It works, but versions are on you.

## Why a self-check exists

The point of this workshop is FFI, not fighting your linker. The most common
way an environment *looks* fine but isn't: the compiler binary exists, but
the SDK paths behind it are broken (a macOS upgrade is the classic cause).
`command -v cc` passes; actually compiling fails.

So verification isn't "is the tool installed" — it's "does the toolchain do
its job":

```sh
just check
```

This runs `scripts/self-check.sh`, which verifies every required tool *and*
compiles and links a real C executable before declaring your machine ready. Red
rows come with the fix command inline.

## Pick a language track (still step -1)

Exercise 3 calls your Rust library from a higher-level language. Pick
**one** — you don't need them all:

```sh
just setup-python   # repo-local venv with cffi
just setup-swift    # Swift    (installer on macOS; pointers on Linux)
just setup-kotlin   # Kotlin/JNI (JDK 17+ + kotlinc)
just setup-dart     # Dart
```

Then re-run `just check` until your track's row is green. The other `○`
rows can stay grey forever.

Once the required rows *and* your chosen track are green, step -1 is done —
your machine can run the workshop. [Step 0](./step0.md) is where you prove
it: your first cdylib.
