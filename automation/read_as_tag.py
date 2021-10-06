import os
from github import Github

GITHUB_REPO = "mozilla/application-services"
github_access_token = os.getenv("GITHUB_TOKEN")

def get_latest_as_version():
    g = Github(github_access_token)
    repo = g.get_repo(GITHUB_REPO)
    
    latest_tag = repo.get_tags()[0].name
    return (str(latest_tag))

def main():
    '''
    Gets the latest application services
    version and prints it to stdout
    '''
    if not github_access_token:
        exit(1)
    as_repo_tag = get_latest_as_version()
    print(as_repo_tag)

if __name__ == '__main__':
    main()
