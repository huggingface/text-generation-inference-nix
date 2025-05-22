{
  description = "TGI development";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:danieldk/nixpkgs/cudatoolkit-12.9-kernel-builder";
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
      cudaConfig = {
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

      rocmConfig = {
        allowUnfree = true;
        rocmSupport = true;
      };

      overlay = import ./overlay.nix;
    in
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (
      system:
      let
        pkgsCuda = import nixpkgs {
          inherit system;
          config = cudaConfig;
          overlays = [ overlay ];
        };
        pkgsRocm = import nixpkgs {
          inherit system;
          config = rocmConfig;
          overlays = [ overlay ];
        };
      in
      rec {
        formatter = pkgsCuda.nixfmt-tree;
        packages = rec {
          all = pkgsCuda.symlinkJoin {
            name = "all";
            paths = pkgsCuda.lib.attrsets.attrValues python3Packages;
          };
          python3Packages = with pkgsCuda.python3.pkgs; {
            inherit

              awq-inference-engine
              causal-conv1d
              compressed-tensors
              exllamav2
              flash-attn
              flash-attn-layer-norm
              flash-attn-rotary
              flash-attn-v1
              flashinfer
              hf-transfer
              hf-xet
              kernels
              mamba-ssm
              moe
              opentelemetry-instrumentation-grpc
              outlines
              paged-attention
              punica-sgmv
              quantization
              quantization-eetq
              rotary
              torch
              ;
          };

          rocm = {
            python3Packages = with pkgsRocm.python3.pkgs; {
              inherit torch;
            };
          };
        };
      }
    )
    // {

      # Cheating a bit to conform to the schema.
      lib.config = cudaConfig;
      overlays.default = overlay;
    };
}
