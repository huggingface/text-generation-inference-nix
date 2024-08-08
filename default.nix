{
  pkgs ? import <nixpkgs> {
    allowUnfree = true;
    cudaSupport = true;
  },
}:

rec {
  python3Packages = pkgs.python3Packages.callPackage ./pkgs/python-modules { };
}
