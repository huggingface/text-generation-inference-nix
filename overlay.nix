final: prev:
rec {
  blas = prev.blas.override { blasProvider = prev.mkl; };

  fetchKernel = final.callPackage ./pkgs/fetch-kernel { };

  lapack = prev.lapack.override { lapackProvider = prev.mkl; };

  magma-cuda-static = prev.magma-cuda-static.overrideAttrs (
    _: prevAttrs: { buildInputs = prevAttrs.buildInputs ++ [ (prev.lib.getLib prev.gfortran.cc) ]; }
  );

  toml2cmake = final.callPackage ./pkgs/toml2cmake { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (
      python-self: python-super: with python-self; {
        paged-attention = buildKernel rec {
          pname = "paged-attention";
          version = "0.0.2";
          src = fetchKernel {
            repo_id = "kernels-community/${pname}";
            inherit version;
            hash = "sha256-cfxFC6s5Dtzg+6ia6SJ3nSjzM+cWYbJG5z5yxF19KuE=";
          };
        };

        attention-kernels = callPackage ./pkgs/python-modules/attention-kernels { };

        awq-inference-engine = callPackage ./pkgs/python-modules/awq-inference-engine { };

        buildKernel = callPackage ./pkgs/python-modules/build-kernel { };

        causal-conv1d = callPackage ./pkgs/python-modules/causal-conv1d { };

        compressed-tensors = callPackage ./pkgs/python-modules/compressed-tensors { };

        eetq = callPackage ./pkgs/python-modules/eetq { };

        exllamav2 = callPackage ./pkgs/python-modules/exllamav2 { };

        flash-attn = callPackage ./pkgs/python-modules/flash-attn { };

        flash-attn-layer-norm = callPackage ./pkgs/python-modules/flash-attn-layer-norm { };

        flash-attn-rotary = callPackage ./pkgs/python-modules/flash-attn-rotary { };

        flash-attn-v1 = callPackage ./pkgs/python-modules/flash-attn-v1 { };

        flashinfer = callPackage ./pkgs/python-modules/flashinfer { };

        hf-kernels = callPackage ./pkgs/python-modules/hf-kernels { };

        hf-transfer = callPackage ./pkgs/python-modules/hf-transfer { };

        marlin-kernels = callPackage ./pkgs/python-modules/marlin-kernels { };

        moe = buildKernel rec {
          pname = "moe";
          version = "0.1.2";
          src = fetchKernel {
            repo_id = "kernels-community/${pname}";
            inherit version;
            hash = "sha256-73iDgJEvdTko1MNUVtfLlBlKk9hccAT47B1sYmIxM9w=";
          };
        };

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

        mamba-ssm = callPackage ./pkgs/python-modules/mamba-ssm { };

        punica-kernels = callPackage ./pkgs/python-modules/punica-kernels { };

        quantization = buildKernel rec {
          pname = "quantization";
          version = "0.0.3";
          src = fetchKernel {
            repo_id = "kernels-community/${pname}";
            inherit version;
            hash = "sha256-50eTtzNYjfEvCoANE/1ln5TeWhEnGqpEDfOBMIkBV6U=";
          };
          cutlass = final.cutlass_3_6;
        };

        quantization-eetq = buildKernel rec {
          pname = "quantization-eetq";
          version = "0.0.1";
          src = fetchKernel {
            repo_id = "kernels-community/${pname}";
            inherit version;
            hash = "sha256-yy71PMrvzpfp3A7Pbm2Lerh5EKl3tDwC6OusBnuxM1A=";
          };
          cutlass = final.cutlass_2_10;
        };

        torch = callPackage ./pkgs/python-modules/torch { };
      }
    )
  ];
}
// (import ./pkgs/cutlass { pkgs = final; })
