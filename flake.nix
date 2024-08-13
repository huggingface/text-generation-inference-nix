{
  description = "tgi development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    {
      self,
      flake-compat,
      nixpkgs,
    }:
    with import nixpkgs;
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
    in
    rec {
      overlay = import ./overlay.nix;
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit config system;
            overlays = [ overlay ];
          };
          lib = pkgs.lib;
        in
        rec {
          all = pkgs.symlinkJoin {
            name = "all";
            paths = lib.attrsets.attrValues python3Packages;
          };
          python3Packages = with pkgs.python3.pkgs; {
            inherit

              causal-conv1d
              exllamav2
              fbgemm-gpu
              flash-attn
              flash-attn-layer-norm
              flash-attn-rotary
              flashinfer
              hf-transfer
              mamba-ssm
              marlin-kernels
              opentelemetry-instrumentation-grpc
              torch
              vllm
              ;
          };
        }
      );
    };
}
