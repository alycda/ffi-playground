{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [ just cheat asciinema presenterm tmux mdbook ];
}