# Git

Git needs no introduction—it's the ubiquitous version control system you already know. This chapter isn't about teaching Git itself, but about why the very first commit matters more than you might think.

## The Initial Commit

This repository started with a single commit ([821861c](https://github.com/alyssa-e/dev/commit/821861c9bc14679aa12fd1b7c8833219ce0a1616)) containing only a `.gitignore`:

```gitignore
# Ignore build outputs from performing a nix-build or `nix build` command
result
result-*

# Ignore automatically generated direnv output
.direnv
```

That's it. No code, no configuration—just ignore rules.

## Why This Matters

This template is a Nix-based development environment, but the principle applies universally: **get your `.gitignore` right from the very beginning**.

### Step Zero, Not Step One

Most tutorials treat `.gitignore` as an afterthought—something you add when you notice unwanted files sneaking into your commits. This is a mistake, especially if you plan to use advanced version control tools.

### The Jujutsu Problem

Later in this book, we'll cover [Jujutsu](https://martinvonz.github.io/jj/), a Git-compatible VCS that makes time-travel through your repository history trivially easy. Want to go back to an earlier commit, make a change, and have it propagate forward? Jujutsu handles this elegantly.

But here's the catch: if your early commits contain files that *should* have been ignored—build artifacts, editor configs, generated files—walking backwards in time becomes messy. You'll encounter merge conflicts with files that shouldn't exist. You'll have to deal with noise that obscures the actual changes you care about.

By establishing ignore patterns in the literal first commit, you ensure that:

1. **No garbage ever enters the repository** - Build outputs, cache directories, and environment-specific files are excluded from day one
2. **History stays clean** - Time-travel operations (rebasing, evolving, etc.) work smoothly
3. **The pattern is established** - Contributors see immediately that this project takes repository hygiene seriously

## For Any Project

> Use https://github.com/github/gitignore as a starting point.

While this template uses Nix, the same principle applies everywhere:

- **Node.js**: Ignore `node_modules/`, `.next/`, `dist/`
- **Python**: Ignore `__pycache__/`, `*.pyc`, `.venv/`, `*.egg-info/`
- **Rust**: Ignore `target/`
- **Go**: Ignore binaries, `vendor/` (if not vendoring)

The specific patterns vary; the principle doesn't. Start clean, stay clean.

---

- https://git-scm.com/docs/gitignore
- https://www.kernel.org/pub/software/scm/git/docs/gitignore.html