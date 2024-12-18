final: prev: {
  blas = prev.blas.override { blasProvider = prev.mkl; };

  lapack = prev.lapack.override { lapackProvider = prev.mkl; };

  magma-cuda-static = prev.magma-cuda-static.overrideAttrs (
    _: prevAttrs: { buildInputs = prevAttrs.buildInputs ++ [ (prev.lib.getLib prev.gfortran.cc) ]; }
  );

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (
      python-self: python-super: with python-self; {
        attention-kernels = callPackage ./pkgs/python-modules/attention-kernels { };

        awq-inference-engine = callPackage ./pkgs/python-modules/awq-inference-engine { };

        causal-conv1d = callPackage ./pkgs/python-modules/causal-conv1d { };

        compressed-tensors = callPackage ./pkgs/python-modules/compressed-tensors { };

        eetq = callPackage ./pkgs/python-modules/eetq { };

        exllamav2 = callPackage ./pkgs/python-modules/exllamav2 { };

        flash-attn = callPackage ./pkgs/python-modules/flash-attn { };

        flash-attn-layer-norm = callPackage ./pkgs/python-modules/flash-attn-layer-norm { };

        flash-attn-rotary = callPackage ./pkgs/python-modules/flash-attn-rotary { };

        flash-attn-v1 = callPackage ./pkgs/python-modules/flash-attn-v1 { };

        flashinfer = callPackage ./pkgs/python-modules/flashinfer { };

        hf-transfer = callPackage ./pkgs/python-modules/hf-transfer { };

        marlin-kernels = callPackage ./pkgs/python-modules/marlin-kernels { };

        moe-kernels = callPackage ./pkgs/python-modules/moe-kernels { };

        #opentelemetry-proto = python-super.opentelemetry-proto.override { protobuf = super.protobuf3_24; };

        opentelemetry-instrumentation-grpc = python-super.opentelemetry-instrumentation-grpc.overrideAttrs (
          _: prevAttrs: {
            patches = [ ];

            # Overwrite old protobuf files which leads to failing.
            preCheck = ''
              python -m grpc_tools.protoc -Itests/protobuf --python_out=tests/protobuf \
               --grpc_python_out=tests/protobuf tests/protobuf/test_server.proto # --mypy_out=text_generation_server/pb 
            '';

            nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ python-super.grpcio-tools ];
          }
        );

        # Temporarily downgrade outlines to work around https://github.com/dottxt-ai/outlines-core/issues/95

        outlines = python-super.outlines.overrideAttrs (
          _: prevAttrs: rec {
            version = "0.1.3";
            name = "${prevAttrs.pname}-${version}";

            src = prev.fetchFromGitHub {
              owner = "dottxt-ai";
              repo = prevAttrs.pname;
              rev = version;
              hash = "sha256-OACSwdkh46TwTtgsy4HNZbx62UPJJ/Lq1JJ0fFPr9mQ=";
            };
          }
        );

        outlines-core = python-super.outlines-core.overrideAttrs (
          _: prevAttrs: rec {
            version = "0.1.14";
            name = "${prevAttrs.pname}-${version}";

            src = prev.fetchFromGitHub {
              owner = "dottxt-ai";
              repo = prevAttrs.pname;
              rev = version;
              hash = "sha256-1S1KCTmHRc/5vviRd2fFFh/Sx1OKWDFlrQusMFBjLck=";
            };
          }
        );

        mamba-ssm = callPackage ./pkgs/python-modules/mamba-ssm { };

        punica-kernels = callPackage ./pkgs/python-modules/punica-kernels { };

        torch = callPackage ./pkgs/python-modules/torch {
          inherit (prev.darwin.apple_sdk.frameworks) Accelerate CoreServices;
          inherit (prev.darwin) libobjc;
        };
      }
    )
  ];
}
