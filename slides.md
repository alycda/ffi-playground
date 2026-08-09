---
title: Using Advent of Code as an FFI Playground
sub_title: RustConf 2026 - Montreal
author: Alyssa Evans
---

Who Am I?
===

Staff Software Engineer, SDKs at [Ditto](https://ditto.com) 

<!-- speaker_note: |

    Last year I joined Ditto as a Staff Software Engineer. FFI is literally my day job. 
    


    Before Ditto, I spent 6 years in Free Ad-Supported Streaming TV (FAST) 

        building Web Applications for Connected TVs and game consoles. 

        Then I became _that engineer_ who kept pushing to adopt Rust.

    -->

<!-- end_slide -->

Why Are We Here?
===

To break things, on purpose

<!-- speaker_note: |

    ## Description

    Using Advent of Code (AoC) puzzles as the substrate, participants build a working Rust FFI library from scratch, wrapping a real AoC solution in a C glue layer and calling it from multiple different target languages. By the end of the workshop, attendees leave with a working multi-language project, a replicable methodology, and hands-on intuition for the pitfalls that make production FFI hard.

    AoC problems are uniquely well-suited for FFI practice because they have diverse input/output types (primitives, strings, iterators), a motivating narrative that makes repetition feel worthwhile, no production baggage — you can break things freely — and progressively increasing complexity across 12-25 days of problems each year. Unlike algorithm-focused competitive programming, this approach uses AoC’s rich problem variety to stress-test real cross-platform FFI patterns: string encoding mismatches between Java and Swift, async model incompatibilities, and the lowest-common-denominator constraints that make production FFI viable.

    ## Learning Outcomes

    After this workshop, attendees will be able to:

    - Use Advent of Code as a structured, low-stakes FFI practice environment — progressing from primitives to strings to async across multiple target languages.
    - Design a C glue layer that accommodates the lowest-common-denominator constraints of diverse language runtimes, using cbindgen or UniFFI.
    - Avoid common FFI pitfalls: string encoding mismatches between Swift/Java, async model incompatibilities, over-exposing Rust idioms that don’t translate across language boundaries.
    - Evaluate whether FFI is the right architectural choice for a given situation, including honest assessment of the maintenance burden, onboarding cost, and performance trade-offs.
    - Replicate the AoC-as-FFI-playground methodology in their own learning or team onboarding — with a structured progression and a working starter template to build from.

    -->
