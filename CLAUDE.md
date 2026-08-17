This file provides context and guidance for Claude Code sessions

## What this repo is

Workshop materials for "Using Advent of Code as an FFI Playground" (RustConf
2026). It is not an application: it is a *teaching substrate* — a sequence of 
Rust crates that attendees build, plus the machinery that proves an attendee's 
machine (and CI) can build them.

## Commands

```sh
just                    # list recipes (default)
just check              # attendee self-check: required toolchain + optional tracks
./scripts/self-check.sh # same, but exits non-zero on failure (just check swallows it)

just days verify        # the day library's gate: tests + fmt + clippy (run before pushing)
just days test 2023-12-01   # one day
just days run  2023-12-01   # one day, against days/inputs/2023-12-01.txt
just days new  2019-12-04   # scaffold a day from days/_template

just present            # presenterm deck (slides.md)
just book               # mdbook serve --open, port 3000
just build-book         # render to book/book (untracked)
```

`days` is a `just` module (`mod days` in the root justfile), so its recipes are
`just days <recipe>` from the root and plain `just <recipe>` from inside `days/`.

## The day library (`days/`)

Eight solved Advent of Code days, one crate each, pure Rust — the reference
solutions attendees read and later break at an FFI boundary. Things that are not
obvious from the tree:

- `days/Cargo.toml` is a **virtual manifest with `members = ["*"]`**. That glob
  is why rust-analyzer and CI pick up a new day with nothing to register — and
  why a directory in `days/` that isn't a crate breaks *every* cargo command in
  the workspace, including one run from inside a healthy day. `target` and
  `inputs` are excluded by name; anything else that lands there belongs beside
  them.
- One shared `days/Cargo.lock` and one `days/target`, so a shared-dependency
  change can break a day nobody touched. `--locked` everywhere means the
  lockfile is under test too.
- **`days/README.md` is the menu and the authority.** Adding a day means adding
  a row. It also records the dependency policy (days are *not* std-only — the
  template bakes in `aoc-ornaments` + `miette` + `rstest`) so that decision
  isn't re-litigated per day.
- Each day reads its input from a path anchored to the crate
  (`CARGO_MANIFEST_DIR`), never `include_str!`, so a day builds and tests with
  no input present.

## CI

`.github/workflows/rust.yml` is the gate: `cargo test --workspace --locked` on
ubuntu + macos, `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`,
and a `cargo check` pinned to **rustc 1.85** (the edition-2024 floor the crates
declare and `scripts/self-check.sh` promises). `just days verify` runs the first
three locally; it does *not* cover the 1.85 job. `pages.yml` publishes the book.

## Environment

`shell.nix` is unpinned (`import <nixpkgs> {}`); versions follow the caller's
channel. Enter with `nix-shell`, or `direnv allow` once (`.envrc`). The
devcontainer in `.devcontainer/` installs Nix + home-manager inside the image;
`just _rebuild` reapplies `.devcontainer/home.nix` there. `USER` is exported at
the top of the justfile because containers start with it unset.

Recipes prefixed `_` are not for hand-running: `_build-book-gha` moves output
to `_site` for the Pages workflow.

## Book and deck

`book/` (mdbook) is the durable reference: chapters are ordered by workshop step
and written to the attendee, with the standing intent that they eventually carry
enough for the workshop to be re-taught by someone else. When a step's mechanics
change in the repo, its chapter is the thing that must not drift.

`slides.md` is still the presenterm **demo stub** — it is not the deck and not a
source of truth. Don't treat it as one, and don't "fix" it into agreement with
the book.

## Rules for agents working in this repo

- **Never commit AoC puzzle inputs or full puzzle text.** Only the small
  example inputs from problem statements may appear in tests
  ([AoC's request](https://adventofcode.com/about#faq_copying)). This covers doc
  comments too: paraphrase the puzzle, don't paste it. Two ported days had
  copied their headers from the puzzle pages, and it took a review to notice —
  nothing automated enforces this.