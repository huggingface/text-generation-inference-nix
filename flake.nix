{
  description = "tgi development";

  inputs.nixpkgs.url = "github:danieldk/nixpkgs/cudnn-9.3";

  outputs =
    { self, nixpkgs }:
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
        in
        {
          python3Packages = with pkgs.python3.pkgs; {
            inherit
              fbgemm-gpu
              flash-attn
              flash-attn-layer-norm
              flash-attn-rotary
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
