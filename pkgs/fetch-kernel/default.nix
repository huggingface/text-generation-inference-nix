{
  lib,
  fetchgit,
}:

{
  repo_id,
  hash ? "",
  version,
}:

fetchgit {
  url = "https://huggingface.co/${repo_id}";
  rev = "refs/tags/v${version}";
  inherit hash;
}
