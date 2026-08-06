_default: 
    @just --list

rebuild:
    home-manager switch -b backup -f .devcontainer/home.nix

export USER := shell("whoami")

cheats:
    cheat -l

present:
    presenterm slides.md

present-with-speaker-notes:
    tmux kill-session -t present 2>/dev/null || true
    tmux new-session -d -s present 'presenterm --listen-speaker-notes slides.md' \; \
        split-window -h 'presenterm --publish-speaker-notes slides.md' \; \
        attach -t present

export-presentation:
    presenterm --export-html slides.md --output out/slides.html

[working-directory: 'book']
book:
    mdbook serve --open

[working-directory: 'book']
build-book:
    mdbook build

[working-directory: 'book']
build-book-gha:
    just build-book
    mv book ../_site