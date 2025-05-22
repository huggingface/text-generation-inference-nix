{
  lib,
  fetchgit,
}:

{
  repo_id,
  hash ? "",
  rev ? null,
  version ? null,
}:

assert (
  lib.assertMsg (lib.xor (rev == null) (
    version == null
  )) "fetchKernel requires one of either `rev` or `version` to be provided (not both)."
);

let
  effectiveRev = if rev == null then "refs/tags/v${version}" else rev;
in
fetchgit {
  url = "https://huggingface.co/${repo_id}";
  rev = effectiveRev;
  inherit hash;
}
