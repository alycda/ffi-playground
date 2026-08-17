{ pkgs, ... }:
{
  imports = [ ../home.nix ];

  # Swift track. Yes, really — see ./README.md for what works, what's old,
  # and the two runtime gotchas. Foundation is not optional: without
  # `import Foundation` in your Swift file the binary links but can't find
  # libdispatch.so at runtime.
  # Dispatch is not optional either, and its absence fails EARLIER than the
  # Foundation caveat above: swiftPackages.Foundation installs the Foundation,
  # FoundationNetworking and FoundationXML Swift modules and nothing else,
  # while the Foundation module itself requires the CoreFoundation and Dispatch
  # *clang* modules. Without them `import Foundation` does not reach the
  # runtime gotcha below — it fails to compile with
  # `missing required modules: 'CoreFoundation', 'Dispatch'`.
  home.packages = with pkgs; [ swift swiftPackages.Foundation swiftPackages.Dispatch ];
}
