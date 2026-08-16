{ pkgs, ... }:
{
  imports = [ ../home.nix ];

  # Kotlin/JNI track: kotlinc + a JDK on PATH, so `just check` goes green
  # without sdkman. JAVA_HOME points into the JDK so JNI builds can find
  # jni.h under $JAVA_HOME/include.
  home.packages = with pkgs; [ kotlin jdk17 ];
  home.sessionVariables.JAVA_HOME = "${pkgs.jdk17.home}";
}
