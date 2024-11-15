{
  description = "tgi development";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    {
      self,
      flake-compat,
      flake-utils,
      nixpkgs,
    }:
    let
      config = {
        allowUnfree = true;
        cudaSupport = true;
        cudaCapabilities = [
          "7.5"
          "8.0"
          "8.6"
          "8.9"
          "9.0"
          "9.0a"
        ];
      };

      overlay = import ./overlay.nix;
    in
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit config system;
          overlays = [ overlay ];
        };
      in
      rec {
        formatter = pkgs.nixfmt-rfc-style;
        packages = rec {
          all = pkgs.symlinkJoin {
            name = "all";
            paths = pkgs.lib.attrsets.attrValues python3Packages;
          };
          python3Packages = with pkgs.python3.pkgs; {
            inherit

              attention-kernels
              awq-inference-engine
              causal-conv1d
              compressed-tensors
              eetq
              exllamav2
              fbgemm-gpu
              flash-attn
              flash-attn-layer-norm
              flash-attn-rotary
              flash-attn-v1
              flashinfer
              hf-transfer
              mamba-ssm
              marlin-kernels
              moe-kernels
              opentelemetry-instrumentation-grpc
              punica-kernels
              torch
              vllm
              ;
          };
        };
      }
    )
    // {

      # Cheating a bit to conform to the schema.
      lib.config = config;
      overlays.default = overlay;
    };
}
