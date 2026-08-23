/*
 * Exercise 2 C harness — provided. You fill in the expected values.
 *
 * This is the moment of truth: a C program, including a header you did not
 * write, calling your Rust. Nothing in this file knows Rust is involved,
 * which is the entire point.
 *
 * Built and run by ../../build-and-test.sh.
 */

#include <stdio.h>

#include "ex2_c_glue.h"

static int failures = 0;

/* int64_t has no portable printf specifier, so cast to long long. */
static void check(const char *label, int64_t got, int64_t expect) {
    if (got == expect) {
        printf("ok   %-32s = %lld\n", label, (long long)got);
    } else {
        printf("FAIL %-32s = %lld (expected %lld)\n", label, (long long)got,
               (long long)expect);
        failures++;
    }
}

int main(void) {
    /* TODO: paste your day's EXAMPLE input from the puzzle statement — never
     * your real input.
     *
     * Encoding reality bites here: C string literals do not span lines, so a
     * multi-line example needs explicit \n escapes, like
     *
     *     "3   4\n4   3\n2   5"
     *
     * Getting this wrong is the single most common way to spend ten minutes
     * debugging your Rust when the bug was in your C. */
    const char *example = "PASTE EXAMPLE INPUT HERE";

    /* TODO: replace these with the expected answers from the puzzle
     * statement, then delete this comment. */
    const int64_t expected_part1 = 0;
    const int64_t expected_part2 = 0;

    check("part1(example)", ex_part1(example), expected_part1);
    check("part2(example)", ex_part2(example), expected_part2);

    /* The hostile-input contract. These need no edits — they pass as soon as
     * your null check and your UTF-8 check are in, and they are the reason
     * both checks exist. C is under no obligation to hand you anything sane. */
    check("part1(NULL)", ex_part1(NULL), INVALID_INPUT);
    check("part2(NULL)", ex_part2(NULL), INVALID_INPUT);

    {
        /* 0xFF can never appear in well-formed UTF-8. C has no opinion about
         * that, which is exactly why Rust has to check. */
        const char invalid_utf8[] = {'n', 'o', 'p', 'e', (char)0xFF, '\0'};
        check("part1(<invalid utf-8>)", ex_part1(invalid_utf8), INVALID_INPUT);
        check("part2(<invalid utf-8>)", ex_part2(invalid_utf8), INVALID_INPUT);
    }

    if (failures == 0) {
        printf("\nAll Ex 2 checks passed.\n");
        return 0;
    }
    printf("\n%d check(s) FAILED.\n", failures);
    return 1;
}
