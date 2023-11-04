// swift-tools-version:5.4
import PackageDescription

let checksum = "f8dfb5b75b501ab59a41102c80e802874cceb23025a7e8571664a971de961368"
let version = "121.0.20231104050329"
let url = "https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/project.application-services.v2.swift.121.20231104050329/artifacts/public/build/MozillaRustComponents.xcframework.zip"

// Focus xcframework
let focusChecksum = "c2d4ffad5d759b48a1558fe77c89430faf6246dd586d81c8f53d4b268cf8f871"
let focusUrl = "https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/project.application-services.v2.swift.121.20231104050329/artifacts/public/build/FocusRustComponents.xcframework.zip"
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
