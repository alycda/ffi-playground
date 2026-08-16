{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # required workshop toolchain (verified by `just check`); mkShell's stdenv
    # already provides the C compiler and linker. `just` is required too — it
    # is how attendees invoke everything.
    rustc cargo rust-cbindgen just
    # recommended: cheatsheets for the FFI patterns (`just cheats`)
    cheat
    # opt-in, presenter-side: running the deck and book locally. Both are
    # published, so no attendee needs these. tmux drives the deck +
    # speaker-notes split (`just present-with-speaker-notes`) — my rig, not
    # something to put in front of the room.
    presenterm mdbook tmux
    # safety net: python3 for the Python track; git so pure/minimal shells
    # (and jj colocated clones) get a current git (no verification needed)
    python3 git
  ];
}