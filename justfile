# Containers start with USER unset — .devcontainer/setup.sh defaults it to
# root for the same reason. Recipes below shell out to tools that read it,
# so derive it here and they behave the same in and out of the container.
export USER := shell("whoami")

# the first recipe is the default
_default:
    @just --list

# the AoC day library: scaffold and run days, e.g. `just days new 2022-12-01`
mod days

# verify required toolchain + optional tracks (always exits 0; CI: run scripts/self-check.sh)
check:
    -./scripts/self-check.sh

# Language-track setup (Exercise 3 — pick ONE track; see `just check`).
# Required Rust/C toolchain comes from shell.nix, not from these recipes.

# Python track: repo-local venv with cffi
setup-python:
    python3 -m venv .venv
    ./.venv/bin/python -m pip install --upgrade pip cffi
    @echo "Done. Activate with: source .venv/bin/activate — then re-run: just check"

# Run test, not `command -v`: the OS-image xcrun stub at /usr/bin/swiftc
# exists even without the CLT.

# Swift track: toolchain via Xcode CLT
[macos]
setup-swift:
    @swiftc --version >/dev/null 2>&1 && echo "swiftc already installed" || xcode-select --install

# Swift track: no unattended installer on Linux — points at swift.org
[linux]
setup-swift:
    @echo "Install the Swift toolchain from https://www.swift.org/install/"

# Kotlin/JNI track: JDK + kotlinc via brew (keg-only JDK needs the symlink)
[macos]
setup-kotlin:
    brew install openjdk kotlin
    @echo "brew's openjdk is keg-only; link it so 'java' resolves:"
    @echo "  sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk"
    @echo "then re-run: just check"

# Kotlin/JNI track: sdkman is the recommended path on Linux
[linux]
setup-kotlin:
    @echo "Recommended: sdkman — https://sdkman.io/install then:"
    @echo "  sdk install java 17-tem && sdk install kotlin"

# Homebrew ≥6 refuses formulae from untrusted third-party taps, hence the
# `brew trust`; its `-` prefix keeps older brews (no trust subcommand) working.

# Dart track: SDK via the official brew tap
[macos]
setup-dart:
    brew tap dart-lang/dart
    -brew trust dart-lang/dart
    brew install dart

# Dart track: distro installs vary — points at dart.dev
[linux]
setup-dart:
    @echo "Install the Dart SDK (3.0+): https://dart.dev/get-dart"

# list the cheatsheets in .cheat
cheats:
    cheat -l

# run the slide deck
present:
    presenterm slides.md

# deck and speaker notes side by side in tmux
present-with-speaker-notes:
    tmux kill-session -t present 2>/dev/null || true
    tmux new-session -d -s present 'presenterm --listen-speaker-notes slides.md' \; \
        split-window -h 'presenterm --publish-speaker-notes slides.md' \; \
        attach -t present

# render slides.md to out/slides.html
export-presentation:
    presenterm --export-html slides.md --output out/slides.html

# serve the book locally and open a browser
[working-directory: 'book']
book:
    mdbook serve --open

# render the book to book/book
[working-directory: 'book']
build-book:
    mdbook build

# devcontainer only: rebuild the home-manager profile (WORKSHOP_HOME_NIX is
# set by the variant devcontainers so their extra packages survive a rebuild)
_rebuild:
    home-manager switch -b backup -f "${WORKSHOP_HOME_NIX:-.devcontainer/home.nix}"

# CI only: called by .github/workflows/pages.yml. Moves the build output to
# _site for actions/upload-pages-artifact, so don't run it by hand.
[working-directory: 'book']
_build-book-gha:
    just build-book
    mv book ../_site
