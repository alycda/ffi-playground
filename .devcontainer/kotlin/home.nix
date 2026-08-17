{ pkgs, ... }:
{
  imports = [ ../home.nix ];

  # Kotlin track: kotlinc + a JDK on PATH, so `just check` goes green without
  # sdkman. JAVA_HOME points into the JDK so a JNI build can find jni.h under
  # $JAVA_HOME/include.
  #
  # jna is here because the golden day's Kotlin harness does not use JNI at
  # all: UniFFI's Kotlin backend calls the cdylib through JNA, so jna.jar has
  # to be on the classpath at compile time and at run time. Without it,
  # `days/2024-12-03/uniffi/build-and-test.sh kotlin` stops before it starts.
  # (Substitutes from cache on aarch64-linux; nothing compiles.)
  home.packages = with pkgs; [ kotlin jdk17 jna ];
  home.sessionVariables.JAVA_HOME = "${pkgs.jdk17.home}";
  home.sessionVariables.JNA_JAR = "${pkgs.jna}/share/java/jna.jar";
}
