#!/usr/bin/env bash
#
# Script to generate any artifacts required when building the Swift packages.
#
# Swift packages can't run arbitrary comments at build time (well, not in a well-supported manner anyway)
# so we need to have everything required to build the swift code checked in to the repo and included
# in the release tag. This is a little ad-hoc script for doing so, at least until we find a better
# way.

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

UNIFFI_BINDGEN=(cargo run --manifest-path "$THIS_DIR/external/application-services/tools/embedded-uniffi-bindgen/Cargo.toml")
GLEAN_GENERATOR="$THIS_DIR/external/application-services/components/external/glean/glean-core/ios/sdk_generator.sh"

set -euvx

###
#
# Nimbus
#
###

NIMBUS_DIR="$THIS_DIR/generated/nimbus"
rm -rf "$NIMBUS_DIR" && mkdir -p "$NIMBUS_DIR"
# Glean metrics.
# Run this first, because it appears to delete any other .swift files in the output directory.
# Also, it wants to be run from inside Xcode, so we set some env vars to fake it out.
SOURCE_ROOT="$THIS_DIR" PROJECT="nimbus" "$GLEAN_GENERATOR" -o "$NIMBUS_DIR/Generated" "$THIS_DIR/external/application-services/components/nimbus/metrics.yaml"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$NIMBUS_DIR/Generated" "$THIS_DIR/external/application-services/components/nimbus/src/nimbus.udl"
# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$THIS_DIR/external/application-services/components/nimbus/ios/Nimbus" "$NIMBUS_DIR/Nimbus"

###
#
# CrashTest
#
###

CRASHTEST_DIR="$THIS_DIR/generated/crashtest"
rm -rf "$CRASHTEST_DIR" && mkdir -p "$CRASHTEST_DIR"
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$CRASHTEST_DIR" "$THIS_DIR/external/application-services/components/crashtest/src/crashtest.udl"
