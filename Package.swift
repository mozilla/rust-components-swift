// swift-tools-version:5.4
import PackageDescription
let gleanChecksum = "b46cc53ca927f9de76ff6da9a9e444ac163b4b0abd4fc8dfd5ac0e612ca19254"
let gleanVersion = "41.1.1"
let gleanUrl = "https://github.com/mozilla/glean/releases/download/v\(gleanVersion)/Glean.xcframework.zip"
let package = Package(
    name: "MozillaRustComponentsSwift",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "Glean", targets: ["Glean"]),
        .library(name: "RustLog", targets: ["RustLog"]),
        .library(name: "Viaduct", targets: ["Viaduct"]),
        .library(name: "Nimbus", targets: ["Nimbus"]),
        .library(name: "CrashTest", targets: ["CrashTest"]),
        .library(name: "Logins", targets: ["Logins"]),
        .library(name: "FxAClient", targets: ["FxAClient"]),
        .library(name: "Autofill", targets: ["Autofill"]),
        .library(name: "Push", targets: ["Push"]),
        .library(name: "Tabs", targets: ["Tabs"]),
    ],
    dependencies: [
        .package(name: "SwiftKeychainWrapper", url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1")
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
            //
            url: "https://116964-129966583-gh.circle-artifacts.com/0/dist/MozillaRustComponents.xcframework.zip",
            checksum: "87c570f0f14055020263a38cf45726bee0b890a77a3359c76499756905ca30cc"

            // For local testing, you can point at an (unzipped) XCFramework that's part of the repo.
            // Note that you have to actually check it in and make a tag for it to work correctly.
            //
            //path: "./MozillaRustComponents.xcframework"
        ),
        .binaryTarget(name: "Glean", url: gleanUrl, checksum: gleanChecksum),
        .target(
            name: "Sync15",
            path: "external/application-services/components/sync15/ios"
        ),
        .target(
            name: "RustLog",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "external/application-services/components/rc_log/ios"
        ),
        .target(
            name: "Viaduct",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "external/application-services/components/viaduct/ios"
        ),
        .target(
            name: "Nimbus",
            dependencies: ["MozillaRustComponentsWrapper", "Glean"],
            path: "generated/nimbus"
        ),
        .target(
            name: "CrashTest",
            dependencies: ["MozillaRustComponentsWrapper"],
            path: "generated/crashtest"
        ),
        .target(
           name: "Logins",
           dependencies: ["MozillaRustComponentsWrapper", "Sync15"],
           path: "generated/logins"
        ),
        .target(
           name: "FxAClient",
           dependencies: ["MozillaRustComponentsWrapper", "SwiftKeychainWrapper"],
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
        )
    ]
)
