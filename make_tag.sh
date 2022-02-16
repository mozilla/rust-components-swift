#!/usr/bin/env bash
#
# Make a new tag for this package.
#
# The Swift Package Manager can only import packages from git tags
# named precisely as a semver version number `MAJOR.MINOR.PATCH`.
# This script is a convenient way to generate such a tag and make
# sure that it is well-formed.

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

AS_VERSION=main
TAG=
FORCE=
AS_PATH=
IS_LOCAL="false"

while [[ "$#" -gt 0 ]]; do case $1 in
  -f|--force) FORCE="-f"; shift;;
  -a|--as-version) AS_VERSION=$2; shift; shift;;
  -l|--local-as) AS_PATH=$2; IS_LOCAL="true"; shift; shift;;
  --) shift; break;;
  -*) echo "Unknown parameter: $1"; exit 1;;
  *) break;;
esac; done

TAG="$1"

if [ -z "$TAG" ]; then
    echo "Missing tag"
    exit 1;
fi
if [ $# -gt 1 ]; then
    echo "Too many arguments";
    exit 1;
fi
if echo "$TAG" | grep '^[0-9]\+\.[0-9]\+\.[0-9]\+$'; then true; else
    echo "Invalid tag: $TAG"
    exit 1;
fi

# Re-generate any generated files, to make sure they're fresh.


if [ "true" = $IS_LOCAL ]; then
    echo "Running against a local Application services, with path: $AS_PATH"
else
    echo "Running against Application Services version: $AS_VERSION";
    echo "Cloning Application Services"
    git clone --branch $AS_VERSION --recurse-submodules https://github.com/mozilla/application-services.git
    AS_PATH="$THIS_DIR/application-services"
fi

"$THIS_DIR/generate.sh" $AS_PATH || exit 1
git add "$THIS_DIR/swift-source"

if [ "false" = $IS_LOCAL ]; then
    echo "Removing application services repository after generating bindings"
    rm -rf application-services/
fi
# Create the tag
git commit -a -m "Version $TAG"
git tag $FORCE "$TAG"