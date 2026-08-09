//! Step 0: Minimal Rust Library
//!
//! This is the starting point for the workshop. We have:
//! - A library crate configured for FFI (cdylib)
//! - A simple function to verify the setup works
//!
//! ## Your Task
//!
//! 1. Run `cargo build` to compile the library
//! 2. Run `cargo test` to verify the tests pass
//! 3. Check `target/debug/` to see the generated library file

/// Adds two numbers together.
///
/// This simple function will be our first export for FFI.
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
        assert_eq!(add(-1, 1), 0);
        assert_eq!(add(0, 0), 0);
    }
}
