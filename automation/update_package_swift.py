import os
from github import Github
import hashlib
import requests
import fileinput
import sys

GITHUB_REPO = "mozilla/application-services"
XC_FRAMEWORK_NAME = "MozillaRustComponents.xcframework.zip"
PACKAGE_SWIFT = "Package.swift"
github_access_token = os.getenv("GITHUB_TOKEN")
as_version = os.getenv("AS_VERSION")

def get_xcframework_artifact():
    g = Github(github_access_token)
    repo = g.get_repo(GITHUB_REPO)

    release = repo.get_release(as_version)
    for asset in release.get_assets():
        if asset.name == XC_FRAMEWORK_NAME:
            return asset.browser_download_url

def compute_checksum(xc_framework_url):
    req = requests.get(xc_framework_url)
    return hashlib.sha256(req.content).hexdigest()

def update_package_swift(as_version, checksum):
    version_line = "let version ="
    checksum_line = "let checksum ="

    for line in fileinput.input(PACKAGE_SWIFT, inplace=1):
        if line.strip().startswith(version_line):
            # Replace the line with the new version included
            line = f"{version_line} \"{as_version}\"\n"
        elif line.strip().startswith(checksum_line):
            # Replace the line with the new computed checksum
            line = f"{checksum_line} \"{checksum}\"\n"
        sys.stdout.write(line)
def main():
    '''
    Updates `Package.swift` with the latest
    xcframework
    '''
    if not github_access_token or not as_version:
        exit(1)
    xc_framework_url = get_xcframework_artifact()
    checksum = compute_checksum(xc_framework_url)
    update_package_swift(as_version, checksum)



if __name__ == '__main__':
    main()
