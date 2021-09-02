// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "MozillaRustComponentsSwift",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "RustLog", targets: ["RustLog"]),
        .library(name: "Viaduct", targets: ["Viaduct"]),
        .library(name: "Nimbus", targets: ["Nimbus"]),
        .library(name: "CrashTest", targets: ["CrashTest"]),
        // TODO: more of our components here, once they support M1 builds.
        //.library(name: "Logins", targets: ["Logins"]),
        //.library(name: "FxAClient", targets: ["FxAClient"]),
    ],
    dependencies: [
        // TODO: ship Glean via this same bundle?
        .package(name: "Glean", url: "https://github.com/mozilla/glean-swift", from: "39.0.4"),
        // TODO: this external dependency is required for FxAClient,
        // leaving it here as an example for now.
        //.package(name: "SwiftKeychainWrapper", url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1")
    ],
    targets: [
        /*
        * A placeholder wrapper for our binaryTarget so that XCode will ensure this is
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
            url: "https://112912-129966583-gh.circle-artifacts.com/0/dist/MozillaRustComponents.xcframework.zip",
            checksum: "a67cfdab5e9a52eeb93435b20a4fc2813fe0486113c6eab5d7fa77fcbcb4fa07"
            //
            // For local testing, you can point at an (unzipped) XCFramework that's part of the repo.
            // Note that you have to actually check it in and make a tag for it to work correctly.
            //
            //path: "./MozillaRustComponents.xcframework"
        ),
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
        )
        // TODO: other components will go here over time.
        //.target(
        //    name: "Logins",
        //    dependencies: ["MozillaRustComponents", "Sync15"],
        //    path: "external/application-services/components/logins/ios"
        //),
        //.target(
        //    name: "FxAClient",
        //    dependencies: ["MozillaRustComponents", "SwiftKeychainWrapper"],
        //    path: "external/application-services/components/fxa-client/ios"
        //),
    ]
)
