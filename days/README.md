# Day Library

The workshop's subject is the **pipeline** — pure Rust → C glue → bindings — not any
particular puzzle. Advent of Code days are plug-in content: pick one from the menu below
and carry it through the stages.

Every day here is a solved reference: `src/lib.rs` with `part1`/`part2` and tests against
the examples published in the problem statement, plus a `main` that runs both parts
against your own input. **Golden days** are the ones that additionally get the whole
pipeline worked through, end to end, so there is always a finished pattern to mirror
rather than a blank file. The FFI half of the golden days is not in this repo yet; the
Rust half is, and it is what the rest of the pipeline will be built on.

This file is the menu. If a day isn't listed here, it isn't part of the workshop's
content — which is the whole reason the file exists: a directory listing tells you eight
days are present and nothing about which to pick or why.

## Menu

| Day | Problem | Boundary shape | Status |
|-----|---------|----------------|--------|
| [2024-12-01](2024-12-01/) 🥇 | Historian Hysteria | two int lists in → `i32` out; sort-and-zip, then a frequency map | Golden — Rust reference here |
| [2024-12-03](2024-12-03/) 🥇 | Mull It Over | raw string scan → `usize`; stateful parse (`do()` / `don't()`) | Golden (in progress) — Rust reference here |
| [2015-12-01](2015-12-01/) | Not Quite Lisp | char stream → `i32`; part 2 returns a position, not a total | Rust reference — the live-demo day |
| [2015-12-05](2015-12-05/) | Doesn't He Have Intern-Elves For This? | lines → `usize` count; one predicate per line, the ruleset swapped by function pointer | Rust reference |
| [2020-12-02](2020-12-02/) | Password Philosophy | `1-3 a: abcde` lines → struct → `usize` count | Rust reference |
| [2021-12-02](2021-12-02/) | Dive! | command lines → enum → `i32`, the product of two accumulators | Rust reference |
| [2022-12-01](2022-12-01/) | Calorie Counting | blank-line groups → `usize`; part 2 is a top-3, i.e. an array at the boundary | Rust reference |
| [2023-12-01](2023-12-01/) | Trebuchet?! | string → `u32`; overlapping spelled-out digits | Rust reference |

The **boundary shape** column is the column that matters when picking. What makes a day
good here is not how clever the puzzle is, it's what has to cross the FFI boundary: a
scalar in and a scalar out is a different exercise from a list of strings, and a
fixed-size array is a different exercise again (out-param or returned struct?). Pick for
the shape you want to teach or learn.

## Running a day

From the repo root, `days` is a `just` module:

```sh
just days test 2023-12-01    # one day
just days run  2023-12-01    # against your own input
just days verify             # every day, exactly what CI gates on
```

`just days verify` is the one to run before pushing. The per-day recipes take one day; CI
never does, because every day is a workspace member sharing one lockfile — so a change to
a shared dependency can break a day you never touched.

## Adding a day

```sh
just days new 2019-12-04     # scaffolds days/2019-12-04 from _template
```

Then fill the three holes the scaffold names (`Day`'s shape and its `FromStr`, the two
parts, and the tests — paste the statement's example input and drop the `#[ignore]`), add
a menu row above, and run `just days verify`.

Commit `days/Cargo.lock` along with the new day: the scaffold updates it (a new member has
to be in the lockfile before anything runs `--locked`, which verify and CI both do), and
CI checks out whatever you push.

Nothing needs registering. `days/Cargo.toml` is a virtual manifest with
`members = ["*"]`, so cargo, rust-analyzer, and CI all pick a new day up by its existing
rather than by its being listed anywhere. The flip side of that glob: a directory in here
that *isn't* a crate breaks every cargo command in the workspace, including ones run from
inside a healthy day. So this tree holds days and nothing else — `target/` and `inputs/`
are excluded by name, and anything else that lands here belongs beside them in the
exclude list.

## Rules

- **Never commit real puzzle inputs or full puzzle text**
  ([AoC's request](https://adventofcode.com/about#faq_copying)). Only the small example
  inputs from the problem statement live in tests; the doc header of each day paraphrases
  the puzzle rather than quoting it. `.gitignore` here ignores `**/inputs/*`, so drop your
  own input at `days/inputs/<YYYY-MM-DD>.txt` — every `main` reads it from there at
  runtime rather than with `include_str!`, so a day still builds and tests without one.
- **Days are named `YYYY-MM-DD`**, the full date, because `2015-01` reads as January to
  everyone who hasn't been told otherwise and sorts wrong the moment a second event year
  shows up.
- **Days are not std-only.** `_template` bakes in `aoc-ornaments` (which owns the
  `Solution` trait and `Part`), `miette` for errors, and `rstest` for table-driven tests;
  individual days reach for `derive_more`, `itertools`, `nom`, or `nom_locate` as the
  puzzle warrants. That is a deliberate reversal of an earlier dependency-light rule: the
  C-glue stage has to strip a real crate's trait and error type at the boundary, which is
  the thing worth watching happen. It is the boundary layer's job to be small, not the
  day's.
- **This tree is the reference library, not scratch space.** These are solved days, read
  as the model to copy — which is also why CI lints them with `-D warnings`. Warnings in
  the sample are warnings in thirty forks of it.
