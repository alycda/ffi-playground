//! Exercise 1: solve your chosen AoC day in pure, idiomatic Rust.
//!
//! Don't think about FFI yet — write the Rust you'd want to write. We break
//! it at the boundary in Exercise 2, and the less this file knows about that,
//! the better the lesson works.
//!
//! Signature guidance: `&str` in, `i64` out covers every day on the menu
//! (`../../days/README.md`). Keep the solve functions **pure** — no file I/O
//! in the library. That is what makes the Exercise 2 wrap clean: reading the
//! input stays on the caller's side of the boundary, which is exactly how the
//! reference days do it.

/// Solve part 1 of your chosen day.
pub fn part1(input: &str) -> i64 {
    let _ = input;
    todo!("solve part 1 of your chosen day — the menu is ../../days/README.md")
}

/// Solve part 2 of your chosen day.
pub fn part2(input: &str) -> i64 {
    let _ = input;
    todo!("solve part 2")
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Paste the EXAMPLE input from your day's puzzle statement here.
    ///
    /// Statement examples are fine to keep in the repo. Your real puzzle
    /// input is not — don't paste that anywhere, here or in Exercise 2's C
    /// harness. (This is [AoC's own
    /// request](https://adventofcode.com/about#faq_copying), and nothing in
    /// this repo enforces it automatically.)
    ///
    /// Multi-line examples go in as `"first line\nsecond line"`, or with a
    /// raw string if you'd rather see the shape.
    const EXAMPLE: &str = "PASTE YOUR DAY'S EXAMPLE INPUT HERE";

    /// Green out of the box, before you have written anything. If this fails,
    /// the problem is your toolchain and not your puzzle — run
    /// `./scripts/self-check.sh` from the repo root.
    #[test]
    fn environment_works() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    #[ignore = "remove this line once you've pasted your example input and expected answer"]
    fn part1_example() {
        // Replace 0 with the expected answer from the puzzle statement.
        assert_eq!(part1(EXAMPLE), 0);
    }

    #[test]
    #[ignore = "remove this line when you reach part 2"]
    fn part2_example() {
        assert_eq!(part2(EXAMPLE), 0);
    }
}
