// Exercise 3, Dart track — hand-written route, using dart:ffi.
//
// Needs the Dart SDK. Run it from a package that has `ffi` as a dependency:
//
//     dart pub add ffi
//     dart run ex3.dart
//
// The worked pattern is ../../days/2024-12-01/dart/ — read its pubspec.yaml
// if the package setup is the part that is in your way.
//
// Prerequisite: Exercise 2 has to have been built, so the shared library
// exists. `cd ../../ex2-c-glue && ./build-and-test.sh` does that.
//
// Expect `dart analyze` to complain about this file until you have filled
// in the TODOs: both ffi imports are unused while the typedefs and the
// lookup are still commented out, and package:ffi does not resolve at all
// until you run this from a package that depends on it. Those are the
// starting conditions, not mistakes.

import 'dart:ffi' as ffi;
import 'dart:io' show Platform, File, exit;

import 'package:ffi/ffi.dart';

// The workspace target directory. Both exercise crates share it, which is
// why this is ../../target and not ex2-c-glue/target — and why it honours
// CARGO_TARGET_DIR, exactly as ex2-c-glue/build-and-test.sh does. Hardcoding
// it breaks on the first machine that isn't yours.
String libraryPath() {
  final name = Platform.isMacOS ? 'libex2_c_glue.dylib' : 'libex2_c_glue.so';
  final target = Platform.environment['CARGO_TARGET_DIR'] ?? '../../target';
  return '$target/release/$name';
}

// TODO 1: one typedef pair per function.
//
// The first describes the C signature, the second describes how Dart sees
// it. This duplication IS the binding — nothing generated it, nothing
// checks it against the header, and getting either line wrong is a
// segfault rather than a type error.
//
// typedef ExPart1Native = ffi.Int64 Function(ffi.Pointer<Utf8>);
// typedef ExPart1Dart = int Function(ffi.Pointer<Utf8>);

void main() {
  final path = libraryPath();
  if (!File(path).existsSync()) {
    print('No Ex 2 library at $path.');
    print('Build it first: cd ../../ex2-c-glue && ./build-and-test.sh');
    exit(1);
  }

  // TODO 2: open the library and look up the symbol.
  //
  //   final dylib = ffi.DynamicLibrary.open(path);
  //   final exPart1 = dylib.lookupFunction<ExPart1Native, ExPart1Dart>('ex_part1');
  //
  // The lookup is by the exact exported name — which is what
  // #[unsafe(no_mangle)] in Exercise 2 was for.

  // TODO 3: your day's example input and expected answer, from the puzzle
  // statement. Never your real input.
  final example = "PASTE YOUR DAY'S EXAMPLE INPUT HERE";
  const expectedPart1 = 0;

  // TODO 4: convert, call, and free.
  //
  // `example.toNativeUtf8()` allocates C memory. YOU free it, in a
  // try/finally, with `calloc.free(ptr)`. Dart will not do it for you and
  // will not warn you. Compare that with the Swift track, where the same
  // conversion is invisible — same C function underneath, and the two
  // languages disagree completely about whose job the memory is. Which
  // would you rather maintain, and why?
  //
  // Then the hostile-input contract: `ffi.nullptr` is how you say NULL.

  print('Ex 3 (Dart) — fill in the TODOs, then delete this line.');
  exit(1);
}
