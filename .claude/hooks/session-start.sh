#!/bin/bash
set -euo pipefail

# Only needed in Claude Code on the web — the devcontainer/local nix setup
# already provides the toolchain there.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install Determinate Nix (idempotent — skips if /nix is already provisioned)
if [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install linux --init none --no-confirm
fi

export PATH="/nix/var/nix/profiles/default/bin:$PATH"
# The remote session routes HTTPS through a local proxy; nix must trust its CA.
export NIX_SSL_CERT_FILE=/root/.ccr/ca-bundle.crt

# --init none means no service manager starts the daemon; start it ourselves.
if [ ! -S /nix/var/nix/daemon-socket/socket ]; then
  nohup nix-daemon >/tmp/nix-daemon.log 2>&1 &
  for _ in $(seq 1 30); do
    [ -S /nix/var/nix/daemon-socket/socket ] && break
    sleep 1
  done
fi

# Persist environment for the rest of the session
{
  echo 'export PATH="/nix/var/nix/profiles/default/bin:$PATH"'
  echo 'export NIX_SSL_CERT_FILE=/root/.ccr/ca-bundle.crt'
} >> "$CLAUDE_ENV_FILE"

# Pre-warm the workshop toolchain so `nix-shell` is instant later
nix-shell "$CLAUDE_PROJECT_DIR/shell.nix" --run 'just --version'
