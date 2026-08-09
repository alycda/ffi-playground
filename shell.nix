{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # presenter/infrastructure tools
    just cheat asciinema presenterm tmux mdbook
    # required workshop toolchain (verified by `just check`); mkShell's stdenv
    # already provides the C compiler and linker
    rustc cargo rust-cbindgen
    # safety net: python3 for the Python track; git so pure/minimal shells
    # (and jj colocated clones) get a current git without verifying it —
    # anyone running this already cloned the repo
    python3 git
  ];
}