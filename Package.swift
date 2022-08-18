// swift-tools-version:5.4
import PackageDescription

let checksum = "b665ab1f5371f5c14874763cfb135b953a58414e678027a5cacfcac81b3b0386"
let version = "v94.1.0"
let url = "https://github.com/mozilla/application-services/releases/download/\(version)/MozillaRustComponents.xcframework.zip"

// Focus xcframework
let focusChecksum = "22a2aaa44d25046fa1f5b5f9834cf4b2cba045e125b998f9f8096cd5ba639358"
let focusUrl = "https://github.com/mozilla/application-services/releases/download/\(version)/FocusRustComponents.xcframework.zip"
let package = Package(
    name: "MozillaRustComponentsSwift",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "MozillaAppServices", targets: ["MozillaAppServices"]),
        .library(name: "FocusAppServices", targets: ["FocusAppServices"]),
    ],
    dependencies: [
    ],
    targets: [
        /*
        * A placeholder wrapper for our binaryTarget so that Xcode will ensure this is
        * downloaded/built before trying to use it in the build process
        * A bit hacky but necessary for now https://github.com/mozilla/application-services/issues/4422
        */
        .target(
            name: "MozillaRustComponentsWrapper",
            dependencies: [
                .target(name: "MozillaRustComponents", condition: .when(platforms: [.iOS]))
            ],
            path: "MozillaRustComponentsWrapper"
        ),
        .target(
            name: "FocusRustComponentsWrapper",
            dependencies: [
                .target(name: "FocusRustComponents", condition: .when(platforms: [.iOS]))
            ],
            path: "FocusRustComponentsWrapper"
        ),
        .binaryTarget(
            name: "MozillaRustComponents",
            //
            // For release artifacts, reference the MozillaRustComponents as a URL with checksum.
            // IMPORTANT: The checksum has to be on the line directly after the `url`
            // this is important for our release script so that all values are updated correctly
            url: url,
            checksum: checksum

            // For local testing, you can point at an (unzipped) XCFramework that's part of the repo.
            // Note that you have to actually check it in and make a tag for it to work correctly.
            //
            //path: "./MozillaRustComponents.xcframework"
        ),
        .binaryTarget(
            name: "FocusRustComponents",
            //
            // For release artifacts, reference the MozillaRustComponents as a URL with checksum.
            // IMPORTANT: The checksum has to be on the line directly after the `url`
            // this is important for our release script so that all values are updated correctly
            url: focusUrl,
            checksum: focusChecksum

            // For local testing, you can point at an (unzipped) XCFramework that's part of the repo.
            // Note that you have to actually check it in and make a tag for it to work correctly.
            //
            //path: "./FocusRustComponents.xcframework"
        ),
        .target(
            name: "MozillaAppServices",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "swift-source/all"
        ),
        .target(
            name: "FocusAppServices",
            dependencies: ["FocusRustComponentsWrapper"],
            path: "swift-source/focus"
        ),
    ]
)
