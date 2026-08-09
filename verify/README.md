# verify/ — the verifier seam

One script, one contract. `verify.sh` classifies `step*/` dirs by shape and
verifies each: plain crates get `cargo test`; uniffi steps (those shipping
`src/bin/uniffi-bindgen.rs`) get build → bindgen → compile-and-run the binding
test for every `tests/<lang>/` present.

```
verify/verify.sh discover      # what would be verified, as JSON
verify/verify.sh all           # verify everything found (local entrypoint)
verify/verify.sh crate  step4-c-qsort
verify/verify.sh python step6-uniffi
verify/verify.sh kotlin step7-uniffi-kotlin
verify/verify.sh swift  step8-uniffi-swift
```

## The layering plan

1. **Now — CI** (`.github/workflows/verify.yml`): provisions toolchains, fans
   out over `discover`, calls the script. Branch-agnostic: no steps → all jobs
   skip → green.
2. **Next — nix + justfile** (Alyssa's): recipes wrap the same script
   (`just verify` → `verify/verify.sh all`); nix supplies what the script
   assumes on PATH (kotlinc, JVM, swiftc). CI unchanged.
3. **Later — CLI**: replaces the script behind the same argv interface.
   CI and justfile call the CLI the way they called the script. Nothing else
   moves.

Discovery-by-shape means a new step dir is verified by existing, not by being
registered anywhere.
