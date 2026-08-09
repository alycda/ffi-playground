#!/usr/bin/env bash
# verify.sh — the verifier seam.
#
# CI calls this script; the justfile will call this script; the future CLI
# replaces this script behind the same interface. The argv contract is the
# stable part:
#
#   verify.sh discover        emit {"crates":[…],"python":[…],"kotlin":[…],"swift":[…]}
#   verify.sh crate  <dir>    cargo test in a plain step crate
#   verify.sh python <dir>    build + uniffi-bindgen + run python binding test
#   verify.sh kotlin <dir>    build + bindgen + kotlinc compile + run .kts test
#   verify.sh swift  <dir>    build + bindgen + swiftc compile + run   (macOS)
#   verify.sh all             discover, then verify everything found
#
# Classification is by shape, not by list: any step*/ with a Cargo.toml is a
# crate; one that also ships src/bin/uniffi-bindgen.rs is a uniffi step, and
# its languages are whichever tests/<lang>/ dirs exist. New steps get
# verified by existing, not by registration.
#
# Toolchain assumptions (CI installs these; nix will supply them locally):
#   crate/python : cargo, python3
#   kotlin       : kotlinc on PATH, JVM; jna.jar is fetched if absent (pinned)
#   swift        : swiftc (macOS)

set -euo pipefail
cd "$(dirname "$0")/.."

JNA_VERSION="${JNA_VERSION:-5.14.0}"

crate_name() { # <dir> → package name with dashes underscored
  sed -n 's/^name *= *"\(.*\)"/\1/p' "$1/Cargo.toml" | head -1 | tr '-' '_'
}

libfile() { # <dir> → platform library filename
  local name; name=$(crate_name "$1")
  case "$(uname -s)" in
    Darwin) echo "lib${name}.dylib" ;;
    *)      echo "lib${name}.so" ;;
  esac
}

json_array() {
  if [ "$#" -eq 0 ]; then printf '[]'; return; fi
  local out="" x
  for x in "$@"; do out+="\"${x}\","; done
  printf '[%s]' "${out%,}"
}

discover() {
  local crates=() python=() kotlin=() swift=() d
  for d in step*/; do
    d="${d%/}"
    [ -f "$d/Cargo.toml" ] || continue
    if [ -f "$d/src/bin/uniffi-bindgen.rs" ]; then
      [ -d "$d/tests/python" ] && python+=("$d")
      [ -d "$d/tests/kotlin" ] && kotlin+=("$d")
      [ -d "$d/tests/swift" ]  && swift+=("$d")
    else
      crates+=("$d")
    fi
  done
  printf '{"crates":%s,"python":%s,"kotlin":%s,"swift":%s}\n' \
    "$(json_array ${crates[@]+"${crates[@]}"})" \
    "$(json_array ${python[@]+"${python[@]}"})" \
    "$(json_array ${kotlin[@]+"${kotlin[@]}"})" \
    "$(json_array ${swift[@]+"${swift[@]}"})"
}

verify_crate() { # <dir>
  echo "==> crate: $1"
  (cd "$1" && cargo test)
}

gen_bindings() { # <dir> <lang> — build release + in-repo bindgen + colocate lib
  local dir=$1 lang=$2 lib
  lib=$(libfile "$dir")
  (cd "$dir" &&
    cargo build --release &&
    mkdir -p "bindings/$lang" &&
    cargo run --release --bin uniffi-bindgen -- generate \
      --library "target/release/$lib" \
      --language "$lang" \
      --out-dir "bindings/$lang" &&
    cp "target/release/$lib" "bindings/$lang/")
}

verify_python() { # <dir>
  echo "==> python: $1"
  gen_bindings "$1" python
  # The test adds bindings/python to sys.path itself.
  (cd "$1" && python3 tests/python/test_bindings.py)
}

verify_kotlin() { # <dir>
  echo "==> kotlin: $1"
  local name; name=$(crate_name "$1")
  gen_bindings "$1" kotlin
  (cd "$1/bindings/kotlin" &&
    { [ -f jna.jar ] || curl -fsSL -o jna.jar \
        "https://repo1.maven.org/maven2/net/java/dev/jna/jna/${JNA_VERSION}/jna-${JNA_VERSION}.jar"; } &&
    kotlinc -classpath jna.jar \
      "uniffi/${name}/${name}.kt" \
      -include-runtime -d "${name}.jar" &&
    # Native.load() resolves the library via jna.library.path — the lib was
    # copied next to the jar by gen_bindings.
    kotlinc -J-Djna.library.path=. \
      -script ../../tests/kotlin/test_bindings.kts \
      -classpath "${name}.jar:jna.jar")
}

verify_swift() { # <dir>
  echo "==> swift: $1"
  local name; name=$(crate_name "$1")
  gen_bindings "$1" swift
  (cd "$1/bindings/swift" &&
    # swiftc only allows top-level statements in a file literally named
    # main.swift when compiling multiple files.
    cp ../../tests/swift/test_bindings.swift main.swift &&
    swiftc -o test_runner main.swift "${name}.swift" \
      -import-objc-header "${name}FFI.h" \
      -L . "-l${name}" &&
    DYLD_LIBRARY_PATH=. ./test_runner)
}

verify_all() {
  local found
  found=$(discover)
  echo "discovered: $found"
  local d
  for d in step*/; do
    d="${d%/}"
    [ -f "$d/Cargo.toml" ] || continue
    if [ -f "$d/src/bin/uniffi-bindgen.rs" ]; then
      [ -d "$d/tests/python" ] && verify_python "$d"
      [ -d "$d/tests/kotlin" ] && command -v kotlinc >/dev/null && verify_kotlin "$d"
      [ -d "$d/tests/swift" ]  && command -v swiftc  >/dev/null && verify_swift "$d"
    else
      verify_crate "$d"
    fi
  done
  echo "verify: done"
}

case "${1:-}" in
  discover) discover ;;
  crate)    verify_crate  "${2:?usage: verify.sh crate <dir>}" ;;
  python)   verify_python "${2:?usage: verify.sh python <dir>}" ;;
  kotlin)   verify_kotlin "${2:?usage: verify.sh kotlin <dir>}" ;;
  swift)    verify_swift  "${2:?usage: verify.sh swift <dir>}" ;;
  all)      verify_all ;;
  *) echo "usage: verify.sh {discover|crate|python|kotlin|swift|all} [dir]" >&2; exit 2 ;;
esac
