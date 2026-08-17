#!/usr/bin/env bash
set -e

# Mark repo as safe, see: https://code.visualstudio.com/docs/sourcecontrol/faq#_why-is-vs-code-warning-me-that-the-git-repository-is-potentially-unsafe (because of nix)
git config --global --add safe.directory $(dirname "$PWD")

# Pre-allow the .envrc so the direnv extension can load the toolchain into the
# extension host the first time it activates. Without it rust-analyzer comes up
# with no cargo on PATH and stays that way until someone notices the allow
# prompt. direnv arrives with the home-manager profile in postCreate, so this
# guard is for the case where that hasn't landed yet.
if command -v direnv >/dev/null; then
    direnv allow "$PWD"
fi