{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # presenter/infrastructure tools
    just cheat asciinema presenterm tmux mdbook
    # required workshop toolchain (verified by `just check`); mkShell's stdenv
    # already provides the C compiler and linker
    rustc cargo rust-cbindgen
    # Python track (Exercise 3): interpreter for `just setup-python`
    python3
  ];
}