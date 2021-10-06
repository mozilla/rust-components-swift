import os
from github import Github

GITHUB_REPO = "mozilla/rust-components-swift"
github_access_token = os.getenv("GITHUB_TOKEN")
as_version = os.getenv("AS_VERSION")

def is_branch_created():
    g = Github(github_access_token)
    repo = g.get_repo(GITHUB_REPO)
    
    for branch in repo.get_branches():
        if f"update-as-to-{as_version}" in branch.name:
            return True
    return False

def main():
    '''
    Prints to stdout if a branch has already
    been created for this version upgrade
    '''
    if not github_access_token or not as_version:
        exit(1)
    # Not printing directly here
    # so the output is lowercase "true" and
    # not uppercase "True"
    if is_branch_created():
        print("true")
    else:
        print("false")

if __name__ == '__main__':
    main()
