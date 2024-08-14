{ lib, stdenv, buildGoModule, cmake, fetchFromGitHub, ninja, testers, aws-lc }:

buildGoModule rec {
  pname = "aws-lc";
  version = "1.33.0";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-YTvKpTaZnmYlEiKS/W5FlmiEMY7MDxgplXIENxRjI3Q=";
  };

  vendorHash = "sha256-hHWsEXOOxJttX+k0gy/QXvR+yhQLBjE40QIOpwCNpFU=";

  proxyVendor = true;

  outputs = [ "out" "bin" "dev" ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  preBuild = ''
    # hack to get both go and cmake configure phase
    # (if we use postConfigure then cmake will loop runHook postConfigure)
    cmakeConfigurePhase
  '';

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-GNinja"
  ];

  env.NIX_CFLAGS_COMPILE = toString (lib.optionals stdenv.cc.isGNU [
    # Needed with GCC 12 but breaks on darwin (with clang)
    "-Wno-error=stringop-overflow"
  ]);

  buildPhase = "ninjaBuildPhase";

  installPhase = "ninjaInstallPhase";

  postFixup = ''
    for f in $out/lib/crypto/cmake/*/crypto-targets.cmake; do
      substituteInPlace "$f" \
        --replace-fail 'INTERFACE_INCLUDE_DIRECTORIES "''${_IMPORT_PREFIX}/include"' 'INTERFACE_INCLUDE_DIRECTORIES ""'
    done
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = aws-lc;
      command = "bssl version";
    };
    pkg-config = testers.hasPkgConfigModules {
      package = aws-lc;
      moduleNames = [ "libcrypto" "libssl" "openssl" ];
    };
  };

  meta = with lib; {
    description = "General-purpose cryptographic library maintained by the AWS Cryptography team for AWS and their customers";
    homepage = "https://github.com/aws/aws-lc";
    license = [ licenses.asl20 /* or */ licenses.isc ];
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "bssl";
  };
}
