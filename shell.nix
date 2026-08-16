{ pkgs ? import <nixpkgs> {} }:

let
  # cheat config, dotfiles-style (alycda/dotfiles tools/cheat/conf.nix): the
  # sheets are copied into the nix store and the config points there, so the
  # setup survives fresh containers and nix-direnv's cached-env replay — a
  # shellHook-generated file in /tmp would not. Sheet edits re-copy on the
  # next prompt because .envrc watches .cheat; plain nix-shell users
  # re-enter the shell instead.
  cheatConf = pkgs.writeText "ffi-playground-cheat-conf.yml" ''
    colorize: true
    style: monokai
    formatter: terminal256
    pager: less -FRX
    cheatpaths:
      - name: ffi-playground
        path: ${./.cheat}
        tags: []
        readonly: true
  '';
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # presenter/infrastructure tools
    just cheat asciinema presenterm tmux mdbook
    # required workshop toolchain (verified by `just check`); mkShell's stdenv
    # already provides the C compiler and linker
    rustc cargo rust-cbindgen
    # safety net: python3 for the Python track; git so pure/minimal shells
    # (and jj colocated clones) get a current git (no verification needed)
    python3 git
  ];

  CHEAT_CONFIG_PATH = cheatConf;
}
