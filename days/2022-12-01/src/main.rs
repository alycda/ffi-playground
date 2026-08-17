use std::str::FromStr;

use aoc_2022_12_01::Day;
use aoc_ornaments::{Part, Solution};

/// Run Part 1 and Part 2 against your own puzzle input.
///
/// Puzzle inputs are never committed (see `days/.gitignore`) — drop yours at
/// `inputs/2022-12-01.txt` alongside this crate. Read at runtime rather than
/// with `include_str!` so the crate still builds and tests without one.
fn main() -> miette::Result<()> {
    let path = "../inputs/2022-12-01.txt";
    let input = std::fs::read_to_string(path)
        .map_err(|e| miette::miette!("could not read {}: {}", path, e))?;

    let mut day = Day::from_str(&input)?;
    let part1 = day.solve(Part::One)?;
    let part2 = day.solve(Part::Two)?;

    println!("Part 1: {}", part1);
    println!("Part 2: {}", part2);

    Ok(())
}
