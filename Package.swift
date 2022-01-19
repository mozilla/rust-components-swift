// swift-tools-version:5.4
import PackageDescription

let checksum = "f23a1eb4bcb2d5493c4a5d445bf35af41b1a78f201f539edaed4cc2ca990a8f6"
let version = "v87.2.0"
let url = "https://github.com/mozilla/application-services/releases/download/\(version)/MozillaRustComponents.xcframework.zip"

let package = Package(
    name: "MozillaRustComponentsSwift",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "RustLog", targets: ["RustLog"]),
        .library(name: "Viaduct", targets: ["Viaduct"]),
        .library(name: "Nimbus", targets: ["Nimbus"]),
        .library(name: "CrashTest", targets: ["CrashTest"]),
        .library(name: "Logins", targets: ["Logins"]),
        .library(name: "FxAClient", targets: ["FxAClient"]),
        .library(name: "Autofill", targets: ["Autofill"]),
        .library(name: "Push", targets: ["Push"]),
        .library(name: "Tabs", targets: ["Tabs"]),
        .library(name: "Places", targets: ["Places"]),
    ],
    dependencies: [
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf", from: "1.18.0")
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
        .binaryTarget(
            name: "MozillaRustComponents",
            //
            // For release artifacts, reference the MozillaRustComponents as a URL with checksum.
            // IMPORTANT: The checksum has to be on the line directly after the `url`
            // this is important for our release script so that all values are updated correctly
            //url: url,
            //checksum: checksum
            url: "https://125966-129966583-gh.circle-artifacts.com/0/dist/MozillaRustComponents.xcframework.zip",
            checksum: "5e94351bcee43c497fa195683e6c613b0c85d874f5a1d0c894afa57163ef4cd6"

            // For local testing, you can point at an (unzipped) XCFramework that's part of the repo.
            // Note that you have to actually check it in and make a tag for it to work correctly.
            //
            //path: "./MozillaRustComponents.xcframework"
        ),
        // .target(
        //     name: "Sync15",
        //     dependencies: ["MozillaRustComponentsWrapper"],
        //     path: "generated/sync15"
        // ),
        .target(
            name: "RustLog",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "generated/rc_log"
        ),
        .target(
            name: "Viaduct",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "generated/viaduct"
        ),
        .target(
            name: "Nimbus",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "generated/nimbus"
        ),
        .target(
            name: "CrashTest",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "generated/crashtest"
        ),
        .target(
           name: "Logins",
           dependencies: ["MozillaRustComponentsWrapper"],
           path: "generated/logins"
        ),
        .target(
           name: "FxAClient",
           dependencies: ["MozillaRustComponentsWrapper"],
           path: "generated/fxa-client"
        ),
        .target(
            name: "Autofill",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "generated/autofill"
        ),
        .target(
            name: "Push",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "generated/push"
        ),
        .target(
            name: "Tabs",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "generated/tabs"
        ),
        .target(
            name: "Places",
            dependencies: ["MozillaRustComponentsWrapper", "SwiftProtobuf"],
            path: "generated/places"
        )
    ]
)
