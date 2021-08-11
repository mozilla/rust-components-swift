#!/usr/bin/env bash
#
# Make a new tag for this package.
#
# The Swift Package Manager can only import packages from git tags
# named precisely as a semver version number `MAJOR.MINOR.PATCH`.
# This script is a convenient way to generate such a tag and make
# sure that it is well-formed.

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

TAG=
FORCE=

while [[ "$#" -gt 0 ]]; do case $1 in
  -f|--force) FORCE="-f"; shift;;
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

"$THIS_DIR/generate.sh"
git add "$THIS_DIR/generated"

# Create the tag

git commit -a -m "Version $TAG"
git tag $FORCE "$TAG"