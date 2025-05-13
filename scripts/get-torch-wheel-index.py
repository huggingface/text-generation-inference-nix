#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 python3Packages.packaging python3Packages.requests python3Packages.beautifulsoup4

from bs4 import BeautifulSoup
from dataclasses import dataclass
from packaging.utils import parse_wheel_filename
import requests
import sys
import os
import re
from urllib.parse import urlparse, urlunparse
import argparse


def parse_pytorch_index_to_nix(base_index_url: str) -> str:
    """
    Parses the PyTorch simple index by extracting the SHA-256 hash from the URL's anchor fragment
    and generates Nix code.

    Args:
        base_index_url: The base URL of the PyTorch simple index (e.g., for PyTorch wheels).

    Returns:
        A string containing the Nix attribute set for the wheels.
    """
    try:
        print(f"Fetching index page from: {base_index_url}", file=sys.stderr)
        response = requests.get(base_index_url, timeout=30)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching the index page: {e}", file=sys.stderr)
        sys.exit(1)

    soup = BeautifulSoup(response.text, "html.parser")

    nix_output_parts = ["["]

    for a_tag in soup.find_all("a"):
        href = a_tag.get("href")

        if href and (".whl#sha256" in href or "sha256=" in a_tag.get("data-core-metadata", "")):
            parsed_href = urlparse(href)

            # Reconstruct the URL without the fragment for the 'url' attribute in Nix
            wheel_url_no_hash = urlunparse(parsed_href._replace(fragment=""))

            # Extract the hash from the fragment (e.g., 'sha256=<hash>')
            hash_fragment = parsed_href.fragment
            data_core_metadata = a_tag.get("data-core-metadata")
            sha256_hash = None
            if hash_fragment and hash_fragment.startswith("sha256="):
                sha256_hash = hash_fragment.split("sha256=", 1)[1]
            elif data_core_metadata is not None:
                sha256_hash = data_core_metadata.removeprefix("sha256=")

            if not sha256_hash:
                print(
                    f"Warning: Could not find SHA-256 hash for {href}. Skipping.",
                    file=sys.stderr,
                )
                continue

            # Use the filename as the Nix attribute name for clear identification
            wheel_filename = os.path.basename(wheel_url_no_hash).replace("%2B", "+")

            # Construct the full URL for the Nix attribute, ensuring it's absolute
            full_wheel_url = f"{base_index_url}{wheel_url_no_hash}"

            name, version, build, tags = parse_wheel_filename(wheel_filename)
            tag = next(iter(tags))

            # We currently only support Linux.
            if not tag.platform.startswith("linux"):
                continue

            system = tag.platform.replace("linux_", "linux-")
            if version.local.startswith("cu"):
                compute = "cuda"
                compute_version = version.local[len("cu"):]
                compute_version = f"{compute_version[:-1]}.{compute_version[-1:]}"
            elif version.local.startswith("rocm"):
                compute = "rocm"
                compute_version = version.local[len("rocm"):]
            else:
                print(f"skipping {wheel_filename}", file=sys.stderr)
                continue

            nix_entry = f"""  {{
    version = "{version.public}";
    url = "{full_wheel_url}";
    sha256 = "{sha256_hash}";
    system = "{system}";
    compute = "{compute}";
    compute_version = "{compute_version}";
  }};"""
            nix_output_parts.append(nix_entry)

    nix_output_parts.append("]")
    return "\n".join(nix_output_parts)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Parses PyTorch wheel indexes and generates Nix code for wheel URLs and SHA-256 hashes."
    )
    parser.add_argument(
        "--nightly",
        action="store_true",
        help="Use the nightly PyTorch wheel index (https://download.pytorch.org/whl/nightly/torch/) instead of the stable one.",
    )

    args = parser.parse_args()

    default_stable_url = "https://download.pytorch.org/whl/torch/"
    nightly_url = "https://download.pytorch.org/whl/nightly/torch/"

    if args.nightly:
        pytorch_index_url = nightly_url
        print("Using nightly PyTorch wheel index.", file=sys.stderr)
    else:
        pytorch_index_url = default_stable_url
        print("Using stable PyTorch wheel index.", file=sys.stderr)

    nix_code = parse_pytorch_index_to_nix(pytorch_index_url)
    print("\n" + nix_code)
    print("\nDone.", file=sys.stderr)
