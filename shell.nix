{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [ just cheat asciinema_3 presenterm tmux mdbook ];
}