{ callPackage }:

rec {
  torch-bin = callPackage ./torch/bin.nix { };

  marlin-kernels = callPackage ./marlin-kernels {
    torch = torch-bin;
  };
}
