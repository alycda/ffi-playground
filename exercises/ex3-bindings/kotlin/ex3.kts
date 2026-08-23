// Exercise 3, Kotlin track — hand-written route, using JNA.
//
// JNA, not JNI. Kotlin reaches Rust through JNA here because that is what
// UniFFI's Kotlin backend uses, and because JNA binds a plain C ABI — the
// one you built in Exercise 2 — with no glue on the Java side. JNI would
// have meant a second, Java-shaped C boundary in front of the first.
//
// Needs JDK 17+, kotlinc, and the JNA jar. The Kotlin devcontainer provides
// all three and exports JNA_JAR pointing at the jar — the same convention
// days/2024-12-03/uniffi/build-and-test.sh uses, so if that script runs for
// you, this will too. Without nix:
//
//   curl -fsSL -o jna.jar \
//     https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.14.0/jna-5.14.0.jar
//   echo "34ed1e1f27fa896bca50dbc4e99cf3732967cec387a7a0d5e3486c09673fe8c6  jna.jar" \
//     | sha256sum -c -          # macOS: shasum -a 256 -c -
//   export JNA_JAR="$PWD/jna.jar"
//
// Check what arrived before putting it on a JVM classpath. The URL pins a
// version, which says nothing about the bytes you got — and this is the one
// step in the whole workshop that asks you to download a binary and then
// execute it. The checksum is the same constant verify.sh pins.
//
// Run from this directory. Note that the jar and the library are found by
// two different mechanisms: -classpath is where the JVM looks for JNA
// itself, and jna.library.path is where JNA then looks for your cdylib.
// Confusing the two is the usual first failure.
//
//   kotlinc -script ex3.kts -classpath "$JNA_JAR" \
//       -J-Djna.library.path=../../target/release
//
// Prerequisite: Exercise 2 has to have been built, so the library exists.
// `cd ../../ex2-c-glue && ./build-and-test.sh` does that.

import com.sun.jna.Library
import com.sun.jna.Native

// TODO 1: declare the interface JNA should bind.
//
// Method names must match the exported symbols in
// ../../ex2-c-glue/include/ex2_c_glue.h exactly — JNA looks them up by
// name at load time, so a typo is a runtime UnsatisfiedLinkError, not a
// compile error.
//
// JNA maps Kotlin String to const char* for you. Using which encoding?
// Check the jna.encoding property before you assume: the default is the
// platform encoding, not UTF-8, and that difference has bitten Android
// teams. This is the modified-UTF-8 story from Module 3, arriving in your
// own code.
//
// Making the parameter String? rather than String is deliberate — it is
// what lets you pass null in TODO 3.
interface Ex2Library : Library {
    // fun ex_part1(input: String?): Long
    // fun ex_part2(input: String?): Long
}

// Python and Dart both check for the library before loading and tell you to
// build Ex 2; without the same check here, JNA throws UnsatisfiedLinkError,
// which reads as a classpath or jna.library.path problem — exactly the
// confusion the note above warns about.
val lib = try {
    Native.load("ex2_c_glue", Ex2Library::class.java)
} catch (e: UnsatisfiedLinkError) {
    System.err.println("No Ex 2 library found.")
    System.err.println("Build it first: cd ../../ex2-c-glue && ./build-and-test.sh")
    kotlin.system.exitProcess(1)
}

// TODO 2: your day's example input and expected answer, from the puzzle
// statement. Never your real input.
val example = "PASTE YOUR DAY'S EXAMPLE INPUT HERE"
val expectedPart1 = 0L

// TODO 3: call it, check it, then prove the null contract.
//
// String? means you can pass null — do it, and see what comes back. You
// wrote the answer in Exercise 2; this is the first time another runtime
// asks for it.

println("Ex 3 (Kotlin) — fill in the TODOs, then delete this line.")
