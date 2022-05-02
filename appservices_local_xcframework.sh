#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Uses a local version of application services xcframework

# This script allows switches the usage of application services to a local xcframework
# built from a local checkout of application services

set -e

# CMDNAME is used in the usage text below
CMDNAME=$(basename "$0")
USAGE=$(cat <<EOT
${CMDNAME}
Tarik Eshaq <teshaq@mozilla.com>

Uses a local version of application services xcframework

This script allows switches the usage of application services to a local xcframework
built from a local checkout of application services


USAGE:
    ${CMDNAME} [OPTIONS] <LOCAL_APP_SERVICES_PATH>

OPTIONS:
    -d, --disable           Disables local development on application services
    -h, --help              Display this help message.
EOT
)

msg () {
  printf "\033[0;34m> %s\033[0m\n" "${1}"
}

helptext() {
    echo "$USAGE"
}



THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PACKAGE_FILE="$THIS_DIR/Package.swift"
SWIFT_SOURCE="$THIS_DIR/swift-source"
FRAMEWORK_PATH="./MozillaRustComponents.xcframework"
FRAMEWORK_PATH_ESCAPED=$( echo $FRAMEWORK_PATH |  sed 's/\//\\\//g' )
APP_SERVICES_REMOTE="https://github.com/mozilla/application-services"

DISABLE="false"
APP_SERVICES_DIR=
while (( "$#" )); do
    case "$1" in
        -d|--disable)
            DISABLE="true"
            shift
            ;;
        -h|--help)
            helptext
            exit 0
            ;;
        --) # end argument parsing
            shift
            break
            ;;
        --*=|-*) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
        *) # preserve positional arguments
            APP_SERVICES_DIR=$1
            shift
            ;;
    esac
done

if [ "true" = $DISABLE ]; then
  msg "Resetting $PACKAGE_FILE to use remote xcframework"
  # We disable the local development and revert back
  # ideally, users should just use git reset.
  #
  # This exist so local development can be easy to enable/disable
  # and we trust that once developers are ready to push changes
  # they will clean the files to make sure they are in the same
  # state they were in before any of the changes happened.
  perl -0777 -pi -e "s/            path: \"$FRAMEWORK_PATH_ESCAPED\"/            url: url,
            checksum: checksum/igs" $PACKAGE_FILE

  msg "Done reseting $PACKAGE_FILE"
  git add $PACKAGE_FILE
  msg "$PACKAGE_FILE changes staged"

  if [ -d $FRAMEWORK_PATH ]; then
    msg "Detected local framework, deleting it.."
    rm -rf $FRAMEWORK_PATH
    git add $FRAMEWORK_PATH
    msg "Deleted and staged the deletion of the local framework"
  fi
  msg "IMPORTANT: reminder that changes to this repository are not visable to consumers until
      commited"
  exit 0
fi

if [ -z $APP_SERVICES_DIR ]; then
    msg "Please set the application-services path."
    msg "This is a path to a local checkout of the application services repository"
    msg "You can find the repository on $APP_SERVICES_REMOTE"
    exit 1
fi

## First we build the xcframework in the application services repository
msg "Building the xcframework in $APP_SERVICES_DIR"
msg "This might take a few minutes"
pushd $APP_SERVICES_DIR/megazords/ios-rust/
./build-xcframework.sh
popd

## Once built, we want to move the frameowork to this repository, then unzip it
mv $APP_SERVICES_DIR/megazords/ios-rust/MozillaRustComponents.xcframework $THIS_DIR/MozillaRustComponents.xcframework

## We replace the url and checksum in the Package.swift with a refernce to the local
## framework path
perl -0777 -pi -e "s/            url: url,
            checksum: checksum/            path: \"$FRAMEWORK_PATH_ESCAPED\"/igs" $PACKAGE_FILE

## We also add the xcframework to git, and remind the user that it **needs** to be committed
## for it to be used
msg "Staging the xcframework and package.swift changes to git"
git add $FRAMEWORK_PATH
git add $PACKAGE_FILE


## We should also get the swift-source code copied and staged as well
msg "Generating swift source code..."
./generate.sh $APP_SERVICES_DIR
msg "Swift source code also generated, staging it now"
git add $SWIFT_SOURCE

msg "Done setting up rust-components-swift to use $APP_SERVICES_DIR"
msg "IMPORTANT: Reminder that changes to this repository
    MUST be commited before they can be used by consumers"
