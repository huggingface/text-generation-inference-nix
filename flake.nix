{
  description = "TGI development";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:danieldk/nixpkgs/outlines-v0.1.4-tgi";
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

              paged-attention
              attention-kernels
              awq-inference-engine
              causal-conv1d
              compressed-tensors
              eetq
              exllamav2
              flash-attn
              flash-attn-layer-norm
              flash-attn-rotary
              flash-attn-v1
              flashinfer
              hf-kernels
              hf-transfer
              mamba-ssm
              marlin-kernels
              moe
              moe-kernels
              opentelemetry-instrumentation-grpc
              outlines
              punica-kernels
              quantization
              quantization-eetq
              rotary
              torch
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
