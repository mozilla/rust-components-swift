import os
from github import Github

GITHUB_REPO = "mozilla/rust-components-swift"
github_access_token = os.getenv("GITHUB_TOKEN")
as_version = os.getenv("AS_VERSION")
PACKAGE_SWIFT = "Package.swift"

def is_already_at_version():
    with open(PACKAGE_SWIFT) as fp:
        line = fp.readline()
        while line:
            line = fp.readline()
            
            # If this is the line that has version
            # of the xcframework
            if "let version =" in line:
                return line.strip() == f"let version = \"{as_version}\""
    return False

def is_branch_created():
    g = Github(github_access_token)
    repo = g.get_repo(GITHUB_REPO)
    
    for branch in repo.get_branches():
        if f"update-as-to-{as_version}" in branch.name:
            return True
    return False

def main():
    '''
    Prints to stdout if rust-components-swift has already
    been updated to latest application services or
    if a PR has already been created
    '''
    if not github_access_token or not as_version:
        exit(1)
    if is_already_at_version() or is_branch_created():
        print("true")
    else:
        print("false")

if __name__ == '__main__':
    main()
