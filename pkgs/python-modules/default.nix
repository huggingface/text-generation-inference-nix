{ callPackage, pkgs }:

rec {
  flash-attn = callPackage ./flash-attn {
    torch = torch-bin;
  };

  torch-bin = callPackage ./torch/bin.nix { };

  marlin-kernels = callPackage ./marlin-kernels {
    inherit torch;
  };

  torch = callPackage ./torch {
    inherit (pkgs.darwin.apple_sdk.frameworks) Accelerate CoreServices;
    inherit (pkgs.darwin) libobjc;
  };
}
