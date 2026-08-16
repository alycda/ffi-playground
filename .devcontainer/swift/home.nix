{ pkgs, ... }:
{
  imports = [ ../home.nix ];

  # Swift track. Yes, really — see ./README.md for what works, what's old,
  # and the two runtime gotchas. Foundation is not optional: without
  # `import Foundation` in your Swift file the binary links but can't find
  # libdispatch.so at runtime.
  home.packages = with pkgs; [ swift swiftPackages.Foundation ];
}
