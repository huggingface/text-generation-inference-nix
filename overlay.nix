final: prev: {
  blas = prev.blas.override { blasProvider = prev.mkl; };

  lapack = prev.lapack.override { lapackProvider = prev.mkl; };

  magma-cuda-static = prev.magma-cuda-static.overrideAttrs (
    _: prevAttrs: { buildInputs = prevAttrs.buildInputs ++ [ (prev.lib.getLib prev.gfortran.cc) ]; }
  );

  python3 = prev.python3.override {
    packageOverrides =
      python-self: python-super: with python-self; {
        awq-inference-engine = callPackage ./pkgs/python-modules/awq-inference-engine { };

        causal-conv1d = callPackage ./pkgs/python-modules/causal-conv1d { };

        eetq = callPackage ./pkgs/python-modules/eetq { };

        exllamav2 = callPackage ./pkgs/python-modules/exllamav2 { };

        fbgemm-gpu = callPackage ./pkgs/python-modules/fbgemm-gpu { };

        flash-attn = callPackage ./pkgs/python-modules/flash-attn { };

        flash-attn-layer-norm = callPackage ./pkgs/python-modules/flash-attn-layer-norm { };

        flash-attn-rotary = callPackage ./pkgs/python-modules/flash-attn-rotary { };

        flashinfer = callPackage ./pkgs/python-modules/flashinfer { };

        hf-transfer = callPackage ./pkgs/python-modules/hf-transfer { };

        marlin-kernels = callPackage ./pkgs/python-modules/marlin-kernels { };

        moe-kernels = callPackage ./pkgs/python-modules/moe-kernels { };

        opentelemetry-instrumentation-grpc = python-super.opentelemetry-instrumentation-grpc.overrideAttrs (
          _: prevAttrs: {
            patches = [
              (prev.fetchpatch {
                url = "https://github.com/open-telemetry/opentelemetry-python-contrib/commit/1c8d8ef5368c15d27c0973ce80787fd94c7b3176.diff";
                hash = "sha256-Zc9Q5lCxHP73YErf0TqVAsdmgwibW6LZteycW9zB9a8=";
                stripLen = 2;
                includes = [ "*grpc*" ];
              })
            ];

            meta = prevAttrs.meta // {
              broken = false;
            };
          }
        );

        mamba-ssm = callPackage ./pkgs/python-modules/mamba-ssm { };

        punica-kernels = callPackage ./pkgs/python-modules/punica-kernels { };

        torch = callPackage ./pkgs/python-modules/torch {
          inherit (prev.darwin.apple_sdk.frameworks) Accelerate CoreServices;
          inherit (prev.darwin) libobjc;
        };

        vllm = callPackage ./pkgs/python-modules/vllm { };

        xformers = python-super.xformers.overrideAttrs (
          _: prevAttrs: {
            nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ ninja ];
            preBuild =
              prevAttrs.preBuild
              + ''
                export MAX_JOBS=$NIX_BUILD_CORES
              '';
          }
        );
      };
  };
}
