//! Exercise 2: wrap your Exercise 1 solution in a C ABI.
//!
//! This is where Rust stops being polite. Your job: get a `*const c_char`
//! safely across the boundary, into a `&str`, through your solver, and back
//! out as an `i64` — without undefined behaviour on hostile input.
//!
//! The worked version of this exact shape, smallest first:
//!
//! - `../../days/2015-12-01/c-glue/src/lib.rs` — the live demo
//! - `../../days/2024-12-01/c-glue/src/lib.rs` — the same thing on a harder day
//! - `../../days/2024-12-03/c-glue/src/lib.rs` — and again, with the parts
//!   that differ being the parts that are about the day rather than about C
//!
//! Read one when you're stuck. Reading all three afterwards is the debrief.

// `CStr` is not imported yet, on purpose — step 2 below is where you reach
// for it, and adding the import is part of reaching.
use std::ffi::c_char;

/// Returned when the input is null or not valid UTF-8.
///
/// In-band error values are the simplest convention that can work: one
/// return value, one line for C to check. Module 4 covers what production
/// code does instead (status code plus out-param, error codes, last-error).
///
/// # Check this against your day before you trust it
///
/// `-1` is only usable as a sentinel if your day's answers can never *be*
/// `-1`. For most days on the menu they can't — the answer is a count or a
/// sum, so it's non-negative, and the worked examples in
/// `../../days/2024-12-01/c-glue/` and `../../days/2024-12-03/c-glue/` say so
/// in their headers.
///
/// But `2015-12-01` answers with a floor, and floors are signed:
/// `part1("())")` is `-1`, straight out of the puzzle statement. If you
/// picked that day — or any day that can answer negatively — this constant
/// will report a correct answer as a rejected input, and nothing in C will
/// catch it for you. Move it somewhere the puzzle can't reach (see
/// `../../days/2015-12-01/c-glue/src/lib.rs`, which uses `i64::MIN`).
///
/// Picking an in-band sentinel means *proving* no real answer can equal it.
/// That proof is about your puzzle, not about C, which is why it can't be
/// copied along with the rest of this file.
pub const INVALID_INPUT: i64 = -1;

/// Solve part 1 of your day, called from C.
///
/// Returns -1 if `input` is NULL or not valid UTF-8.
///
/// # Safety
///
/// `input` must be either NULL or a valid NUL-terminated C string that stays
/// alive for the duration of the call. Rust cannot check that last part — it
/// is the caller's promise, and the whole reason this boundary needs care.
#[unsafe(no_mangle)]
pub extern "C" fn ex_part1(input: *const c_char) -> i64 {
    // TODO — four steps, in this order:
    //
    //   1. NULL CHECK. If `input.is_null()`, return INVALID_INPUT. Do this
    //      first and never dereference a null pointer. C will hand you one.
    //
    //   2. BORROW IT. `unsafe { CStr::from_ptr(input) }` wraps the pointer
    //      without copying or taking ownership. (You will need to add `CStr`
    //      to the `use std::ffi::...` line above.) This needs an `unsafe` block
    //      because you are asserting the caller's promise from the `# Safety`
    //      note above holds — write a `// SAFETY:` comment saying which parts
    //      you checked (not null: you just did) and which you are trusting
    //      (NUL-terminated, outlives the call). The worked days all have one;
    //      compare yours to theirs.
    //
    //   3. VALIDATE THE ENCODING. `.to_str()` returns `Ok(&str)` only for
    //      valid UTF-8. Return INVALID_INPUT on `Err`. A C string promises
    //      nothing about encoding, so this is the boundary's job, not the
    //      solver's — and doing it here is what lets your Exercise 1 code
    //      keep a real `&str` and never learn any of this happened.
    //
    //   4. CALL YOUR SOLVER. `ex1_pure_rust::part1(s)`.
    //
    // Then read the generated header, and check INVALID_INPUT against your
    // day's actual answers — see the doc comment on it above.
    //
    // Heads up on what happens if you run the harness before finishing: the
    // `todo!()` below panics, that panic tries to unwind across an
    // `extern "C"` frame, and Rust aborts the whole process rather than let
    // it (this has been the behaviour since 1.81). You will see "fatal
    // runtime error", not a stack trace and not a test failure. That is the
    // lesson, so run it once on purpose. Containing it is `catch_unwind`, and
    // every worked day in ../../days/ does exactly that.
    let _ = input;
    todo!("cross the boundary: null check -> CStr -> UTF-8 -> ex1_pure_rust::part1")
}

/// Solve part 2 of your day, called from C.
///
/// Returns -1 if `input` is NULL or not valid UTF-8.
///
/// # Safety
///
/// Same contract as [`ex_part1`].
#[unsafe(no_mangle)]
pub extern "C" fn ex_part2(input: *const c_char) -> i64 {
    // Same four steps. If you find yourself copy-pasting them, that is a
    // signal worth following: the worked days factor the shared dance into
    // one private helper that takes the solver as a `fn(&str) -> _`, so the
    // two exported functions are one line each and the boundary logic exists
    // exactly once.
    let _ = input;
    todo!("same dance, part 2")
}
