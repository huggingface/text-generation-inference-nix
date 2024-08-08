{ callPackage, pkgs, python }:
let
  torch = callPackage ./torch {
    inherit (pkgs.darwin.apple_sdk.frameworks) Accelerate CoreServices;
    inherit (pkgs.darwin) libobjc;
  };
  # Override torch for all Python packages.
  pkgs = python.pkgs.override {
    overrides = self: super: {
      inherit torch;
    };
  };
  callPackage = pkgs.callPackage;
in {
  inherit (pkgs) torch;

  fbgemm-gpu = callPackage ./fbgemm-gpu {};

  flash-attn = callPackage ./flash-attn {};

  marlin-kernels = callPackage ./marlin-kernels {};

  vllm = callPackage ./vllm {};
}
