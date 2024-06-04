// swift-tools-version:5.4
import PackageDescription

let checksum = "915386f7fee802593aad34015b6b46bdb2f4ba3be2dd299311c95d8a0b9fe799"
let version = "128.0.20240604050515"
let url = "https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/project.application-services.v2.swift.128.20240604050515/artifacts/public/build/MozillaRustComponents.xcframework.zip"

// Focus xcframework
let focusChecksum = "04d707abda137b75fb5ebcad705b4cfec5d171ca6380b438e107049203d0a16b"
let focusUrl = "https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/project.application-services.v2.swift.128.20240604050515/artifacts/public/build/FocusRustComponents.xcframework.zip"
let package = Package(
    name: "MozillaRustComponentsSwift",
    platforms: [.iOS(.v14)],
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
