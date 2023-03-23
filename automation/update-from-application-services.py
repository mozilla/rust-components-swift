#!/usr/bin/python3

from pathlib import Path
from urllib.request import urlopen
import argparse
import fileinput
import gzip
import hashlib
import json
import os
import shutil
import sys
import tarfile
import tempfile

ROOT_DIR = Path(__file__).parent.parent
PACKAGE_SWIFT = ROOT_DIR / "Package.swift"
# Latest nightly nightly.json file from the taskcluster index
NIGHTLY_JSON_URL = "https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/project.application-services.v2.nightly.latest/artifacts/public%2Fbuild%2Fnightly.json"

def main():
    args = parse_args()
    version = calc_version(args)
    print("Updating Package.swift xcframework info", flush=True)
    update_package_swift(version)

    print("Updating swift source files", flush=True)
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_dir = Path(temp_dir)
        extract_tarball(version, temp_dir)
        replace_all_files(temp_dir)

def parse_args():
    parser = argparse.ArgumentParser(prog='build-and-test-swift.py')
    parser.add_argument('version', help="version to use (or `nightly`)")
    return parser.parse_args()

def calc_version(args):
    # release versions are specified dirctly on the command line
    if args.version != "nightly":
        return args.version

    with urlopen(NIGHTLY_JSON_URL) as stream:
        data = json.loads(gzip.decompress(stream.read()))
    return data['version']

def update_package_swift(version):
    url = swift_artifact_url(version, "MozillaRustComponents.xcframework.zip")
    focus_url = swift_artifact_url(version, "FocusRustComponents.xcframework.zip")
    checksum = compute_checksum(url)
    focus_checksum = compute_checksum(focus_url)
    replacements = {
        "let version =": f'let version = "{version}"',
        "let url =": f'let url = "{url}"',
        "let checksum =": f'let checksum = "{checksum}"',
        "let focusUrl =": f'let focusUrl = "{focus_url}"',
        "let focusChecksum =": f'let focusChecksum = "{focus_checksum}"',
    }
    for line in fileinput.input(PACKAGE_SWIFT, inplace=True):
        for (line_start, replacement) in replacements.items():
            if line.strip().startswith(line_start):
                line = f"{replacement}\n"
                break
        sys.stdout.write(line)

def compute_checksum(url):
    with urlopen(url) as stream:
        return hashlib.sha256(stream.read()).hexdigest()

def extract_tarball(version, temp_dir):
    with urlopen(swift_artifact_url(version, "swift-components.tar.xz")) as f:
        with tarfile.open(mode="r|xz", fileobj=f) as tar:
            tar.extractall(temp_dir)

def replace_all_files(temp_dir):
    replace_files(temp_dir / "swift-components/swift-sources", "swift-source/all")
    replace_files(temp_dir / "swift-components/swift-sources", "swift-source/focus")
    replace_files(temp_dir / "swift-components/generated-swift-sources", "swift-source/all/Generated")
    replace_files(temp_dir / "swift-components/generated-swift-sources", "swift-source/focus/Generated")

"""
Replace files in the git repo with files extracted from the tarball

If a file is present in the source dir and also in the repository, then we will
replace the repo file.

Args:
    source_dir: directory to look for sources
    repo_dir: relative directory in the repo to replace files in
"""
def replace_files(source_dir, repo_dir):
    for dirpath, _, files in os.walk(source_dir):
        relative_dir = Path(dirpath).relative_to(source_dir)
        for file in files:
            repo_path = ROOT_DIR / repo_dir / relative_dir / file
            source_path = Path(dirpath) / file
            if repo_path.exists():
                print("updating: {}".format(Path(repo_dir) / relative_dir / file), flush=True)
                shutil.copy2(source_path, repo_path)

def swift_artifact_url(version, filename):
    return ("https://firefox-ci-tc.services.mozilla.com"
            "/api/index/v1/task/project.application-services.v2"
            f".swift.{version}/artifacts/public%2Fbuild%2F{filename}")

if __name__ == '__main__':
    main()
