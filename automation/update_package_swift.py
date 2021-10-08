import os
from github import Github
import hashlib
import requests

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

def update_package_swift(xc_framework_url, checksum):
    old_url = ''
    old_checksum = ''
    with open(PACKAGE_SWIFT) as fp:
        line = fp.readline()
        while line:
            line = fp.readline()
            
            # If this is the line that has the URL to
            # the xcframework
            if XC_FRAMEWORK_NAME in line:
                url_start = line.find('"') + 1
                url_end = line.find('"', url_start)
                old_url = line[url_start:url_end]
                # NOTE: We assume that the next line is the 
                # checksum, there is a note in Package.swift
                # to make sure we don't change that
                line = fp.readline()
                checksum_start = line.find('"') + 1
                checksum_end = line.find('"', checksum_start)
                old_checksum = line[checksum_start:checksum_end]
                break
    file = open(PACKAGE_SWIFT, "r+")
    data = file.read()
    data = data.replace(old_url, xc_framework_url)
    data = data.replace(old_checksum, checksum)
    file.close()
    file = open(PACKAGE_SWIFT, "wt")
    file.write(data)
    file.close()


def main():
    '''
    Updates `Package.swift` with the latest
    xcframework
    '''
    if not github_access_token or not as_version:
        exit(1)
    xc_framework_url = get_xcframework_artifact()
    checksum = compute_checksum(xc_framework_url)
    update_package_swift(xc_framework_url, checksum)



if __name__ == '__main__':
    main()
