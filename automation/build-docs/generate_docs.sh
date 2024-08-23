#!/bin/bash

# Define variables
OUTPUT_DIR="./docs_output"

SCHEME="MozillaRustComponentsSwift"
DESTINATION="generic/platform=iOS"
DOCC_NAME="MozillaAppServices"
DOCC_ARCHIVE_PATH="$OUTPUT_DIR/Build/Products/Debug-iphoneos/$DOCC_NAME.doccarchive"
STATIC_FILES_FOLDER="./docs-website"

# Run xcodebuild to build documentation
echo "Running xcodebuild for documentation generation..."
xcodebuild docbuild -scheme $SCHEME -destination $DESTINATION -derivedDataPath $OUTPUT_DIR

# Run xcrun to generate the final DocC archive
echo "Running xcrun to generate DocC archive..."
xcrun docc process-archive transform-for-static-hosting $DOCC_ARCHIVE_PATH --output-path $STATIC_FILES_FOLDER --hosting-base-path DOCC_NAME

# Cleanup
echo "Cleaning up..."
rm -rf "swift-source"
rm -rf "MozillaRustComponents.xcframework"

echo "Documentation generation completed. Output available in $STATIC_FILES_FOLDER"
