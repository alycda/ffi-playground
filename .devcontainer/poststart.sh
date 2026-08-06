#!/usr/bin/env bash
set -e

# Mark repo as safe, see: https://code.visualstudio.com/docs/sourcecontrol/faq#_why-is-vs-code-warning-me-that-the-git-repository-is-potentially-unsafe (because of nix)
git config --global --add safe.directory $(dirname "$PWD")

jj config set --user user.name "$(git config --get user.name)" 
jj config set --user user.email "$(git config --get user.email)"
jj config set --user ui.pager :builtin
jj config set --user ui.editor "hx"