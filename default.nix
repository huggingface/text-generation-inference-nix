{ pkgs ? import <nixpkgs> { allowUnfree = true; } }:

rec {
  python3Packages = pkgs.python3Packages.callPackage ./pkgs/python-modules { };
}
