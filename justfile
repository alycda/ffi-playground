# Containers start with USER unset — .devcontainer/setup.sh defaults it to
# root for the same reason. Recipes below shell out to tools that read it,
# so derive it here and they behave the same in and out of the container.
export USER := shell("whoami")

_default:
    @just --list

# list the cheatsheets in .cheat
cheats:
    cheat -l

# run the slide deck
present:
    presenterm slides.md

# deck and speaker notes side by side in tmux
present-with-speaker-notes:
    tmux kill-session -t present 2>/dev/null || true
    tmux new-session -d -s present 'presenterm --listen-speaker-notes slides.md' \; \
        split-window -h 'presenterm --publish-speaker-notes slides.md' \; \
        attach -t present

# render slides.md to out/slides.html
export-presentation:
    presenterm --export-html slides.md --output out/slides.html

# serve the book locally and open a browser
[working-directory: 'book']
book:
    mdbook serve --open

# render the book to book/book
[working-directory: 'book']
build-book:
    mdbook build

# devcontainer only: rebuild the home-manager profile from .devcontainer/home.nix
_rebuild:
    home-manager switch -b backup -f .devcontainer/home.nix

# CI only: called by .github/workflows/pages.yml. Moves the build output to
# _site for actions/upload-pages-artifact, so don't run it by hand.
[working-directory: 'book']
_build-book-gha:
    just build-book
    mv book ../_site
