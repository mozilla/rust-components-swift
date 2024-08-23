// swift-tools-version:5.5
import PackageDescription

let checksum = "0830da14106bd3068c8beb68cf6b4a5e0ce6251d40f31446c812ab18dc244de0"
let version = "131.0.20240821050323"
let url = "https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/project.application-services.v2.swift.131.20240821050323/artifacts/public/build/MozillaRustComponents.xcframework.zip"

let package = Package(
    name: "MozillaRustComponentsSwift",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MozillaAppServices", targets: ["MozillaAppServices"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mozilla/glean-swift", from: "61.0.0")
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
                .target(name: "MozillaRustComponents", condition: .when(platforms: [.iOS])),
                .product(name: "Glean", package: "glean-swift")
            ],
            path: "MozillaRustComponentsWrapper"
        ),
        .binaryTarget(
            name: "MozillaRustComponents",
            //
            // For release artifacts, reference the MozillaRustComponents as a URL with checksum.
            // IMPORTANT: The checksum has to be on the line directly after the `url`
            // this is important for our release script so that all values are updated correctly
            path: "./MozillaRustComponents.xcframework"

            // For local testing, you can point at an (unzipped) XCFramework that's part of the repo.
            // Note that you have to actually check it in and make a tag for it to work correctly.
            //
            //path: "./MozillaRustComponents.xcframework"
        ),
        .target(
            name: "MozillaAppServices",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "swift-source/all"
        ),
    ]
)
