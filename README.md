## Hugging Flake

This Nix flake contains packages that are used within Hugging Face. These
are typically packages that are not in nixpkgs or where we need a different
version/build.

The flake is normally used as an overlay (`overlays.default`).

### Binary cache

If you use this overlay's nixpkgs version, you can also get prebuilt outputs
from our binary cache. Set your `nixpkgs` input to follow this flake:

```nix
{
  inputs = {
    tgi-nix.url = "github:huggingface/text-generation-inference-nix";
    nixpkgs.follows = "tgi-nix/nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      tgi-nix,
    }:

    # ...
}
```

Then follow the instructions to [install Cachix and enable the TGI cache](https://app.cachix.org/cache/text-generation-inference).
