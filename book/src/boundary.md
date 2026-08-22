# Failure Is Not an Option — It's Mandatory

**Not required reading.** The book is not the workshop — not yet, anyway. It is
supporting material, gathered in advance for the kind of person who likes to
research a thing before turning up. I am that kind of person, which is why it
exists. If you arrive having read none of it, you are not behind.

This chapter in particular is a record of things going wrong, written after
they went wrong. Reading it first will not stop them happening to you, and it
is not meant to. Take it now if that is how you prepare, or leave it and come
back when something breaks and you want the diagnosis. It is also published
ahead of the code it describes: the caught-panic transcript, the three language
harnesses, and the break-it-on-purpose exercises at the end all refer to material
that is not in the repo yet. The Rust half of the golden days is; the FFI half is
not.

> Every error in this chapter is one we hit, in the order we hit it. None of
> them are here as warnings to help you avoid them. They're here because
> meeting them *is* the exercise.

The day is the easy part. You solved it in Rust, the tests are green, and the
answer is right. Now something written in another language has to call it, and
the interesting problems start — almost none of them in your puzzle logic.

This chapter is the record of getting one day (2024-12-03) across five
boundaries: a hand-written C ABI, hand-written `dart:ffi`, and UniFFI-generated
Python, Kotlin and Swift. Everything below actually happened, in that order,
on the machines this repo ships.

## The same two functions, five ways

| Track | How it calls Rust | What an error looks like | Can the caller ignore it? |
|---|---|---|---|
| C | `extern "C"`, raw pointers | `-1` / `-2` folded into the return value | Yes, trivially |
| Dart | `dart:ffi` typedef pairs against the C header | the same `-1` / `-2` | Yes |
| Python | UniFFI-generated | an exception | Only by catching and dropping it |
| Kotlin | UniFFI-generated, over JNA | an exception | Same |
| Swift | UniFFI-generated | `throws` | **No** — the compiler makes you write `try` |

That last column is the real difference between the hand-written and generated
paths. A C caller who forgets to check gets `-1` and treats it as an answer.

## Errors: C has no `Result`

The C boundary folds failure into the return value, which only works because
the answers are non-negative — so `-1` and `-2` can't collide with a real one.
Two sentinels rather than one, because these are different problems with
different owners:

- `-1` — the boundary refused your input (NULL pointer, or not valid UTF-8).
- `-2` — the input was fine and the solver failed on it.

Collapsing them would tell a caller to check their encoding when the real
answer is "your input is corrupt in a way this code can't survive."

UniFFI replaces both with a real error type. But note what crosses: **the
variant and its fields, not your `#[error("…")]` text**. A Rust error whose
message is its only content arrives with an empty message on the other side.
Anything the caller must *read* goes in a field.

## Panics don't cross — they detonate

An unwind crossing an `extern "C"` frame aborts the process. The caller
doesn't get an exception, it gets a corpse: with Kotlin, the JVM goes down.

So the boundary catches it. `catch_unwind` on the Rust side turns a panic into
whatever that boundary's failure looks like — `-2` in C and Dart, a typed error
in the generated tracks. This day earns it: its scanner panics on `mul(`
followed by a non-digit, and a downloaded input for the *other* golden day (the
two days worked all the way through every track — see [The Day
Library](./days.md)) panics on a trailing blank line. Both are one keystroke
away from real.

Swift, receiving a caught Rust panic:

```
ok   panicking input threw Unsolvable(detail: "Error: Digit")
```

The panic message crossed a language boundary and became a value. Comment out
the `catch_unwind` and run it again — that is the demo.

## Every language has its own front door

Three harnesses, three unrelated ways to say "start here", none of them FFI:

- **Python** — `if __name__ == "__main__":`.
- **Kotlin** — top-level code compiles into a class named after the *file*:
  `test_bindings.kt` becomes `Test_bindingsKt`, first letter capitalized,
  underscores kept. Guess `TestBindingsKt` and you get `ClassNotFoundException`.
  `@file:JvmName("TestBindings")` pins it.
- **Swift** — top-level statements are legal in exactly one file per module,
  and it must be called `main.swift`. Anywhere else, you need `@main` on a type
  with a `static func main()`.

You will meet all three in one afternoon, and none of them will be the thing
you thought you were learning.

## The toolchain is the other half of the exercise

**Kotlin is JNA, not JNI.** UniFFI's Kotlin backend calls the shared library
through JNA, so `jna.jar` must be on the classpath at compile *and* run time,
and the directory holding the library must be on `jna.library.path`. A JDK and
`kotlinc` alone will compile a harness that can never run — and that is exactly
what `just check` calls ready, so it will not catch this for you. The Kotlin
devcontainer is the one setup path that supplies the jar and exports `JNA_JAR`;
on the brew and sdkman paths you fetch it yourself.

**A module resolving is not the same as its library loading.** Getting Swift to
work on this repo's Nix toolchain took four failures that all named `Dispatch`
or `Foundation`, and each was a different problem:

1. `no such module 'Foundation'` — installed in the profile, but `swiftc`
   searches only its own toolchain path.
2. `missing required modules: 'CoreFoundation', 'Dispatch'` — the package
   providing them was never installed.
3. `cannot load underlying module for 'Dispatch'` — installed, but its C
   headers live in a *separate output* that wasn't.
4. `cannot find -ldispatch` — headers found; the shared objects live in a
   different directory of the same package than the Swift module does.

The lesson generalizes past Nix: **compiling and linking want different
directories, and the error text will name the same module for both.** Failure
2 looks like failure 1 not being fixed. It isn't.

**Where the library is at run time is a third question again.** Dart resolves
it per platform (`libfoo.so` / `libfoo.dylib` / `foo.dll`), JNA wants
`jna.library.path`, and a Swift binary wants `LD_LIBRARY_PATH` — for your
freshly built library *and* for the runtime libraries it depends on.

## Failure is the curriculum

A workshop where everything works teaches you that everything works. You would
leave able to follow a recipe, and stuck the first time your input has a
trailing newline.

So the failures are not obstacles between you and the exercise — they are the
exercise. The days are deliberately uneven and two of them panic on input you
will actually feed them. The C boundary hands back `-1` and lets you ignore it.
The toolchain will tell you a module is missing when the truth is that a
*different* directory of the same package is missing. Every one of those is a
question you now know to ask, and you only know it because it broke in front of
you.

If you get to the end of a track and nothing went wrong, you were lucky, not
finished. Break it on purpose: comment out the `catch_unwind` and watch the
process die; feed the C entry point a NULL; hand a Kotlin caller `mul(`
followed by a non-digit. Then you have actually seen the boundary.

Your Rust being correct buys you less than you'd think. The boundary is where
the ownership rules, the error conventions, the encoding assumptions and the
toolchain's opinions all have to be made explicit — and every one of them is a
decision someone makes, not a fact you discover.

That is why the days are deliberately uneven, and why two of them panic on
input you will actually feed them. A tidy day and a scruffy day teach different
things at the boundary, and the scruffy one teaches more.
