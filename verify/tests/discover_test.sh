#!/usr/bin/env bash
# Self-test for verify.sh's shape classification — the load-bearing seam that
# CI, the justfile, and the future CLI all wrap. It is otherwise only exercised
# against whatever step*/ dirs happen to exist, so a regression in the
# classification logic would surface only when a future step lands. This builds
# a synthetic tree and asserts discover's output directly.
#
# verify.sh cd's to its own repo root ($(dirname $0)/..), so the fixture must
# contain a COPY of the script at <root>/verify/verify.sh — passing a path or a
# cwd is not enough.
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
SCRIPT="$HERE/../verify.sh"
FAILS=0

# A throwaway tree with verify/verify.sh copied in, plus whatever step dirs the
# caller stages, then run `verify.sh <args>` from inside it.
run_in_fixture() { # <tmproot> <args...>
  local root=$1; shift
  mkdir -p "$root/verify"
  cp "$SCRIPT" "$root/verify/verify.sh"
  (cd "$root" && verify/verify.sh "$@")
}

mkstep_crate() { mkdir -p "$1/$2/src"; printf '[package]\nname = "%s"\n' "$2" > "$1/$2/Cargo.toml"; }
mkstep_uniffi() { # <root> <name> <lang...>
  local root=$1 name=$2; shift 2
  mkdir -p "$root/$name/src/bin"
  printf '[package]\nname = "%s"\n' "$name" > "$root/$name/Cargo.toml"
  : > "$root/$name/src/bin/uniffi-bindgen.rs"
  local l; for l in "$@"; do mkdir -p "$root/$name/tests/$l"; done
}

check() { # <label> <expected> <actual>
  if [ "$2" = "$3" ]; then echo "ok   — $1"
  else echo "FAIL — $1"; echo "       expected: $2"; echo "       actual:   $3"; FAILS=$((FAILS+1)); fi
}

# 1. Mixed tree: one plain crate, one uniffi step with two tracks.
t=$(mktemp -d)
mkstep_crate "$t" step0-setup
mkstep_uniffi "$t" step6-uniffi python kotlin
got=$(run_in_fixture "$t" discover)
check "mixed tree classifies crate + uniffi tracks" \
  '{"crates":["step0-setup"],"python":["step6-uniffi"],"kotlin":["step6-uniffi"],"swift":[]}' \
  "$got"
rm -rf "$t"

# 2. Empty tree: no step*/ dirs -> all-empty JSON, exit 0.
t=$(mktemp -d)
got=$(run_in_fixture "$t" discover)
check "empty tree yields empty arrays" \
  '{"crates":[],"python":[],"kotlin":[],"swift":[]}' \
  "$got"
rm -rf "$t"

# 3. Malformed uniffi step (bindgen binary, no tests/<lang>/) -> hard error,
#    not silent invisibility.
t=$(mktemp -d)
mkdir -p "$t/step9-broken/src/bin"
printf '[package]\nname = "step9-broken"\n' > "$t/step9-broken/Cargo.toml"
: > "$t/step9-broken/src/bin/uniffi-bindgen.rs"
if run_in_fixture "$t" discover >/dev/null 2>&1; then
  echo "FAIL — malformed uniffi step (no tests/) should abort discover, but it exited 0"; FAILS=$((FAILS+1))
else
  echo "ok   — malformed uniffi step aborts discover"
fi
rm -rf "$t"

if [ "$FAILS" -gt 0 ]; then echo "discover_test: $FAILS failure(s)"; exit 1; fi
echo "discover_test: all passed"
