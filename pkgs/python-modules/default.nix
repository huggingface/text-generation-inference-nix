{ callPackage }:

rec {
  flash-attn = callPackage ./flash-attn {
    torch = torch-bin;
  };

  torch-bin = callPackage ./torch/bin.nix { };

  marlin-kernels = callPackage ./marlin-kernels {
    torch = torch-bin;
  };
}
