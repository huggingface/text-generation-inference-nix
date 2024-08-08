self: super: {
  python3 = super.python3.override {
    packageOverrides =
      python-self: python-super: with python-self; {
        fbgemm-gpu = callPackage ./pkgs/python-modules/fbgemm-gpu { };

        flash-attn = callPackage ./pkgs/python-modules/flash-attn { };

        flash-attn-layer-norm = callPackage ./pkgs/python-modules/flash-attn-layer-norm { };

        flash-attn-rotary = callPackage ./pkgs/python-modules/flash-attn-rotary { };

        marlin-kernels = callPackage ./pkgs/python-modules/marlin-kernels { };

        torch = callPackage ./pkgs/python-modules/torch {
          inherit (super.darwin.apple_sdk.frameworks) Accelerate CoreServices;
          inherit (super.darwin) libobjc;
        };

        vllm = callPackage ./pkgs/python-modules/vllm { };
      };
  };
}