This file provides context and guidance for Claude Code sessions

## What this repo is

Workshop materials for "Using Advent of Code as an FFI Playground" (RustConf
2026). It is not an application: it is a *teaching substrate* — a sequence of
`step*/` Rust crates that attendees build, plus the machinery that proves an
attendee's machine (and CI) can build them.

## Commands

```sh
just                    # list recipes (default)
just check              # attendee self-check: required toolchain + optional tracks
./scripts/self-check.sh # same, but exits non-zero on failure (just check swallows it)

verify/verify.sh discover           # what would be verified, as JSON
verify/verify.sh all                # verify every discovered step
verify/verify.sh crate step0-setup  # one plain crate → cargo test
verify/tests/discover_test.sh       # self-test of the classification logic

cd step0-setup && cargo test          # a single step crate
cd step0-setup && cargo test test_add # a single test

just present            # presenterm deck (slides.md)
just book               # mdbook serve --open, port 3000
just build-book         # render to book/book (untracked)
```

## Environment

`shell.nix` is unpinned (`import <nixpkgs> {}`); versions follow the caller's
channel. Enter with `nix-shell`, or `direnv allow` once (`.envrc`). The
devcontainer in `.devcontainer/` installs Nix + home-manager inside the image;
`just _rebuild` reapplies `.devcontainer/home.nix` there. `USER` is exported at
the top of the justfile because containers start with it unset.

Recipes prefixed `_` are not for hand-running: `_build-book-gha` moves output
to `_site` for the Pages workflow.