#!/usr/bin/env bash
# Workshop environment self-check.
#
# Verifies the REQUIRED toolchain (Rust + C + git + cbindgen) and reports on
# OPTIONAL language tracks (Swift, Kotlin/JNI, Python/cffi, Dart).
# Exit code is non-zero only when a REQUIRED tool is missing or broken —
# pick ONE optional track; you do not need them all.
#
# Usage: ./scripts/self-check.sh   (or: just check)

set -u

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[0;33m'; DIM=$'\033[2m'; NC=$'\033[0m'
PASS="${GREEN}✅${NC}"; FAIL="${RED}❌${NC}"; SKIP="${YELLOW}○${NC}"

required_failures=0

check_required() { # name, command, fix hint
  local name="$1" cmd="$2" hint="$3"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf ' %s %-10s missing — %s\n' "$FAIL" "$name" "$hint"
    required_failures=$((required_failures + 1))
    return
  fi
  # Capture before piping: a `| head` on the same line would report head's
  # exit status, not the tool's. A rustup shim with no default toolchain is
  # the classic "installed but not runnable" case this catches.
  local version
  if version=$("$cmd" --version 2>&1); then
    printf ' %s %-10s %s\n' "$PASS" "$name" "${DIM}$(printf '%s' "$version" | head -1)${NC}"
  else
    printf ' %s %-10s present but not runnable — %s\n' "$FAIL" "$name" "$hint"
    printf '%s\n' "$version" | head -3 | sed 's/^/      /'
    required_failures=$((required_failures + 1))
  fi
}

check_optional() { # track, command, install hint
  local track="$1" cmd="$2" hint="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf ' %s %-12s ready\n' "$PASS" "$track"
    return 0
  else
    printf ' %s %-12s not installed %s(only needed for this track — %s)%s\n' "$SKIP" "$track" "$DIM" "$hint" "$NC"
    return 1
  fi
}

echo "Workshop self-check — Using Advent of Code as an FFI Playground"
echo
echo "Required toolchain:"
check_required "rustc"    "rustc"    "nix shell provides it: direnv allow (no nix: https://rustup.rs)"
check_required "cargo"    "cargo"    "nix shell provides it: direnv allow (no nix: comes with rustup)"
check_required "cbindgen" "cbindgen" "nix shell provides it: direnv allow (no nix: cargo install cbindgen)"

# C compiler: accept cc, clang, or gcc.
c_compiler=""
for candidate in cc clang gcc; do
  if command -v "$candidate" >/dev/null 2>&1; then c_compiler="$candidate"; break; fi
done
if [ -n "$c_compiler" ]; then
  printf ' %s %-10s %s\n' "$PASS" "C compiler" "${DIM}$($c_compiler --version 2>/dev/null | head -1)${NC}"
else
  printf ' %s %-10s missing — macOS: xcode-select --install · Linux: apt/dnf install gcc · Windows: use WSL2\n' "$FAIL" "C compiler"
  required_failures=$((required_failures + 1))
fi

# Functional smoke test: compile AND link a real executable, since a broken
# SDK path (common after macOS upgrades) passes `command -v` but fails here —
# and this workshop is about linking, so the linker is the part worth proving.
if [ -n "$c_compiler" ]; then
  if tmpdir=$(mktemp -d 2>/dev/null) && [ -n "$tmpdir" ]; then
    trap 'rm -rf "$tmpdir"' EXIT
    cat > "$tmpdir/smoke.c" <<'EOF'
#include <stdio.h>
int main(void) { printf("%d\n", 1 + 1); return 0; }
EOF
    if "$c_compiler" "$tmpdir/smoke.c" -o "$tmpdir/smoke" 2>"$tmpdir/err"; then
      printf ' %s %-10s compiles and links a C executable\n' "$PASS" "linker"
    else
      printf ' %s %-10s C compiler present but cannot build an executable:\n' "$FAIL" "linker"
      sed 's/^/      /' "$tmpdir/err" | head -3
      echo "      macOS fix: xcode-select --install (or: sudo xcode-select -r)"
      required_failures=$((required_failures + 1))
    fi
  else
    printf ' %s %-10s cannot create a temp dir — check TMPDIR and disk space (smoke test not run)\n' "$FAIL" "linker"
    required_failures=$((required_failures + 1))
  fi
fi

tracks_ready=0

echo
echo "Optional language tracks (pick ONE for Exercise 3):"
if check_optional "Swift"   "swiftc"  "run: just setup-swift"; then tracks_ready=$((tracks_ready + 1)); fi
if command -v kotlinc >/dev/null 2>&1 && command -v java >/dev/null 2>&1; then
  printf ' %s %-12s ready\n' "$PASS" "Kotlin/JNI"
  tracks_ready=$((tracks_ready + 1))
else
  printf ' %s %-12s not installed %s(needs JDK 17+ and kotlinc — run: just setup-kotlin)%s\n' "$SKIP" "Kotlin/JNI" "$DIM" "$NC"
fi
if command -v python3 >/dev/null 2>&1; then
  if python3 -c 'import cffi' 2>/dev/null; then
    printf ' %s %-12s ready (cffi installed)\n' "$PASS" "Python"
    tracks_ready=$((tracks_ready + 1))
  else
    printf ' %s %-12s python3 found, cffi missing %s(run: just setup-python, then: source .venv/bin/activate)%s\n' "$SKIP" "Python" "$DIM" "$NC"
  fi
else
  printf ' %s %-12s not installed %s(python.org, 3.10+, then: just setup-python)%s\n' "$SKIP" "Python" "$DIM" "$NC"
fi
if check_optional "Dart"    "dart"    "run: just setup-dart"; then tracks_ready=$((tracks_ready + 1)); fi

# Track readiness shapes the banner only, never the exit code: one ready
# track is plenty, and an attendee with one track must never be blocked.
echo
if [ "$required_failures" -eq 0 ]; then
  if [ "$tracks_ready" -gt 0 ]; then
    echo "${GREEN}✅ You're ready for the workshop!${NC} (One ready track is plenty — the other ○ rows can stay grey.)"
  else
    echo "${GREEN}✅ Required toolchain ready (step -1 done).${NC} Step 0: pick ONE language track above and run its setup recipe, e.g. just setup-python"
  fi
  exit 0
else
  echo "${RED}❌ $required_failures required tool(s) missing.${NC} Fix the items above, then re-run: ./scripts/self-check.sh"
  exit 1
fi

