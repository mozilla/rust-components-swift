#!/usr/bin/env bash
#
# Script to generate any artifacts required when building the Swift packages.
#
# Swift packages can't run arbitrary comments at build time (well, not in a well-supported manner anyway)
# so we need to have everything required to build the swift code checked in to the repo and included
# in the release tag. This is a little ad-hoc script for doing so, at least until we find a better
# way.

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Allow the option to use a local copy of application-services
if [ -n "$1" ]; then
APP_SERVICES_DIR=$1
else
APP_SERVICES_DIR="$THIS_DIR/external/application-services"
fi

UNIFFI_BINDGEN=(cargo run --manifest-path "$APP_SERVICES_DIR/tools/embedded-uniffi-bindgen/Cargo.toml")
GLEAN_GENERATOR="$APP_SERVICES_DIR/components/external/glean/glean-core/ios/sdk_generator.sh"

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
SOURCE_ROOT="$THIS_DIR" PROJECT="nimbus" "$GLEAN_GENERATOR" -o "$NIMBUS_DIR/Generated" "$APP_SERVICES_DIR/components/nimbus/metrics.yaml"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$NIMBUS_DIR/Generated" "$APP_SERVICES_DIR/components/nimbus/src/nimbus.udl"
# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$APP_SERVICES_DIR/components/nimbus/ios/Nimbus" "$NIMBUS_DIR/Nimbus"

###
#
# CrashTest
#
###

CRASHTEST_DIR="$THIS_DIR/generated/crashtest"
rm -rf "$CRASHTEST_DIR" && mkdir -p "$CRASHTEST_DIR"
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$CRASHTEST_DIR" "$APP_SERVICES_DIR/components/crashtest/src/crashtest.udl"

###
#
# FxaClient
#
###

FXA_CLIENT_DIR="$THIS_DIR/generated/fxa-client"
rm -rf "$FXA_CLIENT_DIR" && mkdir -p "$FXA_CLIENT_DIR"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$FXA_CLIENT_DIR/Generated" "$APP_SERVICES_DIR/components/fxa-client/src/fxa_client.udl"
# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$APP_SERVICES_DIR/components/fxa-client/ios/FxAClient" "$FXA_CLIENT_DIR/FxAClient"

###
#
# Logins
#
###

LOGINS_DIR="$THIS_DIR/generated/logins"
rm -rf "$LOGINS_DIR" && mkdir -p "$LOGINS_DIR"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$LOGINS_DIR/Generated" "$APP_SERVICES_DIR/components/logins/src/logins.udl"
# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$APP_SERVICES_DIR/components/logins/ios/Logins" "$LOGINS_DIR/Logins"

###
#
# Autofill
#
###

AUTOFILL_DIR="generated/autofill"
rm -rf "$AUTOFILL_DIR" && mkdir -p "$AUTOFILL_DIR"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$AUTOFILL_DIR/Generated" "$APP_SERVICES_DIR/components/autofill/src/autofill.udl"

###
#
# Push
#
###

PUSH_DIR="$THIS_DIR/generated/push"
rm -rf "$PUSH_DIR" && mkdir -p "$PUSH_DIR"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$PUSH_DIR/Generated" "$APP_SERVICES_DIR/components/push/src/push.udl"

###
#
# Tabs
#
###

TABS_DIR="$THIS_DIR/generated/tabs"
rm -rf "$TABS_DIR" && mkdir -p "$TABS_DIR"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$TABS_DIR/Generated" "$APP_SERVICES_DIR/components/tabs/src/tabs.udl"

###
#
# Places
#
###

PLACES_DIR="$THIS_DIR/generated/places"
rm -rf "$PLACES_DIR" && mkdir -p "$PLACES_DIR"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$PLACES_DIR/Generated" "$APP_SERVICES_DIR/components/places/src/places.udl"

## We need to build the protobuf files and copy them over to the places generated section
protoc --proto_path="$APP_SERVICES_DIR/components/places/src" --swift_out="$PLACES_DIR/Generated" "places_msg_types.proto"

# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$APP_SERVICES_DIR/components/places/ios/Places" "$PLACES_DIR/Places"
