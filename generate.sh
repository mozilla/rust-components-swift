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
APP_SERVICES_DIR="$THIS_DIR/application-services"
fi

UNIFFI_BINDGEN=(cargo run --manifest-path "$APP_SERVICES_DIR/tools/embedded-uniffi-bindgen/Cargo.toml")
GLEAN_GENERATOR="$APP_SERVICES_DIR/components/external/glean/glean-core/ios/sdk_generator.sh"

set -euvx

OUT_DIR="$THIS_DIR/swift-source"

rm -rf "$OUT_DIR" && mkdir -p "$OUT_DIR"

###
#
# Nimbus
#
###
# Glean metrics.
# Run this first, because it appears to delete any other .swift files in the output directory.
# Also, it wants to be run from inside Xcode, so we set some env vars to fake it out.
SOURCE_ROOT="$THIS_DIR" PROJECT="nimbus" "$GLEAN_GENERATOR" -o "$OUT_DIR/Generated/Metrics" "$APP_SERVICES_DIR/components/nimbus/metrics.yaml"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$OUT_DIR/Generated" "$APP_SERVICES_DIR/components/nimbus/src/nimbus.udl"
# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$APP_SERVICES_DIR/components/nimbus/ios/Nimbus" "$OUT_DIR"



###
#
# CrashTest
#
###

# CRASHTEST_DIR="$THIS_DIR/generated/crashtest"
# rm -rf "$CRASHTEST_DIR" && mkdir -p "$CRASHTEST_DIR"
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$OUT_DIR" "$APP_SERVICES_DIR/components/crashtest/src/crashtest.udl"

###
#
# FxaClient
#
###

# FXA_CLIENT_DIR="$THIS_DIR/generated/fxa-client"
# rm -rf "$FXA_CLIENT_DIR" && mkdir -p "$FXA_CLIENT_DIR"
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$OUT_DIR/Generated" "$APP_SERVICES_DIR/components/fxa-client/src/fxa_client.udl"
# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$APP_SERVICES_DIR/components/fxa-client/ios/FxAClient" "$OUT_DIR"

###
#
# Logins
#
###

# LOGINS_DIR="$THIS_DIR/generated/logins"
# rm -rf "$LOGINS_DIR" && mkdir -p "$LOGINS_DIR"
# Glean metrics.
# Run this first, because it appears to delete any other .swift files in the output directory.
# Also, it wants to be run from inside Xcode, so we set some env vars to fake it out.
# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$OUT_DIR/Generated" "$APP_SERVICES_DIR/components/logins/src/logins.udl"
# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$APP_SERVICES_DIR/components/logins/ios/Logins" "$OUT_DIR"

###
#
# Autofill
#
###
## Not of our consumers currently use autofill, and the swift code has a name conflict with
## another component, so for now, commented out.

# "${UNIFFI_BINDGEN[@]}" generate -l swift -o "$OUT_DIR/Generated" "$APP_SERVICES_DIR/components/autofill/src/autofill.udl"

###
#
# Push
#
###

# UniFFI bindings.
"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$OUT_DIR/Generated" "$APP_SERVICES_DIR/components/push/src/push.udl"

###
#
# Tabs
#
###
## Not of our consumers currently use tabs, and the swift code has a name conflict with
## another component, so for now, commented out.

# "${UNIFFI_BINDGEN[@]}" generate -l swift -o "$OUT_DIR/Generated" "$APP_SERVICES_DIR/components/tabs/src/tabs.udl"

###
#
# Places
#
###

"${UNIFFI_BINDGEN[@]}" generate -l swift -o "$OUT_DIR/Generated" "$APP_SERVICES_DIR/components/places/src/places.udl"

# Copy the hand-written Swift, since it all needs to be together in one directory.
cp -r "$APP_SERVICES_DIR/components/places/ios/Places" "$OUT_DIR"

###
#
# Sync15
#
###

# We only need to copy the hand-written Swift, sync15 does not use `uniffi` yet
cp -r "$APP_SERVICES_DIR/components/sync15/ios/" $OUT_DIR

###
#
# RustLog
#
###

# We only need to copy the hand-written Swift, RustLog does not use `uniffi` yet
cp -r "$APP_SERVICES_DIR/components/rc_log/ios/" $OUT_DIR


###
#
# Viaduct
#
###

# We only need to copy the hand-written Swift, Viaduct does not use `uniffi` yet
cp -r "$APP_SERVICES_DIR/components/viaduct/ios/" $OUT_DIR

echo "Successfully generated uniffi code!"
