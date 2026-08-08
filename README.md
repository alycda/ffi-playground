# Step -1: Get Your Environment Working

Before the workshop can start, your machine needs to be able to run it. That's
this whole step — nothing else happens until this works.

Everything the workshop uses (`just`, `presenterm`, `mdbook`, `cheat`,
`asciinema`, `tmux`) is declared in one file: [`shell.nix`](./shell.nix).
How you get those tools onto your machine is up to you. Pick one:

## Option 1: macOS / Linux — Nix

1. Install Nix. The [Determinate installer](https://install.determinate.systems)
   is the least fuss:

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   (The [upstream installer](https://nixos.org/download) works too.)

2. Open a new shell, `cd` into this repo, and run:

   ```sh
   nix-shell
   ```

   First run downloads the toolchain; after that it's instant.

3. **Optional, recommended:** install [direnv](https://direnv.net) (plus
   [nix-direnv](https://github.com/nix-community/nix-direnv)) and run
   `direnv allow` once in this directory. That's what [`.envrc`](./.envrc)
   is for — the environment then loads automatically every time you enter
   the repo, no `nix-shell` needed.

## Option 2: Windows — WSL2

Nix doesn't run natively on Windows, but WSL2 is Linux, and Linux is fine.

1. In an admin PowerShell: `wsl --install` (Ubuntu by default), then reboot
   and open your distro.
2. Follow **Option 1** from inside WSL. If the Nix installer complains about
   systemd, enable it: add `[boot]` / `systemd=true` to `/etc/wsl.conf`,
   then `wsl --shutdown` and reopen.
3. Clone the repo *inside* WSL (e.g. `~/ffi-playground`), not on `/mnt/c` —
   the Windows filesystem bridge is slow enough to hurt.

## Option 3: Docker — VS Code devcontainer

Don't want Nix (or anything) installed on your machine? The container does it
all for you.

1. Install [Docker](https://docs.docker.com/get-docker/) and
   [VS Code](https://code.visualstudio.com) with the
   [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Open this repo in VS Code and choose **"Reopen in Container"** when
   prompted.
3. Wait. The first build installs Nix and
   [home-manager](https://github.com/nix-community/home-manager) inside the
   container ([`.devcontainer/`](./.devcontainer) has the details) — it takes
   a few minutes. Subsequent opens are fast.

## Option 4: 💀 Entirely Manual

No Nix. No Docker. Just you, your package manager, and consequences.

Install each tool yourself — this is exactly what `shell.nix` would have
given you:

| Tool | What it's for | Where to get it |
|------|---------------|-----------------|
| [just](https://github.com/casey/just) | task runner (`just <recipe>`) | `cargo install just`, brew, apt, … |
| [presenterm](https://github.com/mfontanini/presenterm) | the slide deck, in your terminal | `cargo install presenterm`, brew |
| [mdbook](https://rust-lang.github.io/mdBook/) | the workshop book | `cargo install mdbook`, brew |
| [cheat](https://github.com/cheat/cheat) | cheatsheets | brew, go install, release binaries |
| [asciinema](https://asciinema.org) | terminal session recordings | `cargo install asciinema`, brew, pipx |
| [tmux](https://github.com/tmux/tmux) | speaker-notes split layout | brew, apt, … |

You won't get version pinning, and when your versions drift from everyone
else's, the skull emoji becomes self-explanatory. But it works.

## Did it work?

From the repo root (inside `nix-shell`, direnv, the container, or your
hand-rolled environment):

```sh
just
```

If you see a list of recipes, your environment works and step -1 is done.
Bonus points:

```sh
just present   # the slide deck should take over your terminal (q to quit)
just book      # the workshop book should open in your browser
```

See you at step 0.
