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
  if command -v "$cmd" >/dev/null 2>&1; then
    local version
    version=$("$cmd" --version 2>/dev/null | head -1)
    printf ' %s %-10s %s\n' "$PASS" "$name" "${DIM}${version}${NC}"
  else
    printf ' %s %-10s missing — %s\n' "$FAIL" "$name" "$hint"
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
check_required "git"      "git"      "https://git-scm.com/downloads (Xcode CLT on macOS: xcode-select --install)"
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

# Functional smoke test: actually compile and link a C object, since a broken
# SDK path (common after macOS upgrades) passes `command -v` but fails here.
if [ -n "$c_compiler" ]; then
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  printf 'int add(int a, int b) { return a + b; }\n' > "$tmpdir/smoke.c"
  if "$c_compiler" -c "$tmpdir/smoke.c" -o "$tmpdir/smoke.o" 2>"$tmpdir/err"; then
    printf ' %s %-10s compiles C objects\n' "$PASS" "linker"
  else
    printf ' %s %-10s C compiler present but cannot compile:\n' "$FAIL" "linker"
    sed 's/^/      /' "$tmpdir/err" | head -3
    echo "      macOS fix: xcode-select --install (or: sudo xcode-select -r)"
    required_failures=$((required_failures + 1))
  fi
fi

echo
echo "Optional language tracks (pick ONE for Exercise 3):"
check_optional "Swift"      "swiftc"  "macOS: xcode-select --install · Linux: swift.org" || true
if command -v kotlinc >/dev/null 2>&1 && command -v java >/dev/null 2>&1; then
  printf ' %s %-12s ready\n' "$PASS" "Kotlin/JNI"
else
  printf ' %s %-12s not installed %s(needs JDK 17+ and kotlinc — sdkman.io recommended; brew needs the openjdk symlink post-step, see SETUP.md)%s\n' "$SKIP" "Kotlin/JNI" "$DIM" "$NC"
fi
if command -v python3 >/dev/null 2>&1; then
  if python3 -c 'import cffi' 2>/dev/null; then
    printf ' %s %-12s ready (cffi installed)\n' "$PASS" "Python"
  else
    printf ' %s %-12s python3 found, cffi missing %s(from repo root: python3 -m venv .venv && source .venv/bin/activate && python -m pip install cffi)%s\n' "$SKIP" "Python" "$DIM" "$NC"
  fi
else
  printf ' %s %-12s not installed %s(python.org, 3.10+, then the venv + cffi steps in SETUP.md)%s\n' "$SKIP" "Python" "$DIM" "$NC"
fi
check_optional "Dart"       "dart"    "dart.dev/get-dart, SDK 3.0+" || true

echo
if [ "$required_failures" -eq 0 ]; then
  echo "${GREEN}✅ You're ready for the workshop!${NC} (Optional tracks above are per-choice — one is plenty.)"
  exit 0
else
  echo "${RED}❌ $required_failures required tool(s) missing.${NC} Fix the items above, then re-run: ./scripts/self-check.sh"
  exit 1
fi

