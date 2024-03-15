# Swift Package for Mozilla's Rust Components

This repository is a Swift Package for distributing releases of Mozilla's various
Rust-based application components. It provides the Swift source code packaged in
a format understood by the Swift package manager, and depends on a pre-compiled
binary release of the underlying Rust code published from [mozilla/application-services](
https://github.com/mozilla/application-services).

**This repository is mostly updated by automation, all the logic is copied from [mozilla/application-services](
https://github.com/mozilla/application-services)**

## Overview

* The `application-services` repo publishes two binary artifacts `MozillaRustComponents.xcframework.zip` and `FocusRustComponents.xcframework.zip` containing
  the Rust code and FFI definitions for all components, compiled together into a single library.
* The `Package.swift` file refrences the xcframeworks as Swift binary targets.
* The `Package.swift` file defines a library per target (one for all the components used by `firefox-ios` and one for `focus-ios`)
    * Each library references its Swift source code directly as files in the repo. All components used by a target are copied into the same directory. For example, all the `firefox-ios` files are in the `swift-source/all` directory.
    * Each library depends on wrapper which wraps the binary to provide the pre-compiled Rust code. For example, [`FocusRustComponentWrapper`](./FocusRustComponentsWrapper/) wraps the Focus xcframework.

For more information, please consult:

* [application-services ADR-0003](https://github.com/mozilla/application-services/blob/main/docs/adr/0003-swift-packaging.md),
  which describes the overall plan for distributing Rust-based components as Swift packages.
* The [Swift Package Manager docs](https://swift.org/package-manager/) and [GitHub repo](https://github.com/apple/swift-package-manager),
  which explain the details of how Swift Packages work (and hence why this repo is set up the way it is).
* The [`ios-rust` crate](https://github.com/mozilla/application-services/tree/main/megazords/ios-rust) which is currently
  responsible for publishing the pre-built `MozillaRustComponents.xcframework.zip` and `FocusRustComponents.xcframework.zip` bundles on which this repository depends.


## Releases
### Nightly

Nightly releases are automated and run every night as a cron job that pushes directly to the main branch. Nightly releases are tagged with three components (i.e `X.0.Y`) where the first component is the current Firefox release (i.e `117`, etc) and the last component is a timestamp.

Note that we need three components because that's a Swift Package manager requirement.

### Cutting a Release

To cut a release of `rust-components-swift`, you will need to do the following:
- Run `./automation/update-from-application-services.py <X.Y>`, where `X.Y` is the version of application services.
- Open a pull request with the resulting changes
- Once landed on the main branch, cut a release using the GitHub UI and tag it
  - **IMPORTANT**: The release tag must be in the form `X.0.Y`, where `X.Y` is the version of application services

## Testing and Local development
To enable local development of `rust-component-swift` read the instructions [documented in application services](https://mozilla.github.io/application-services/book/howtos/locally-published-components-in-firefox-ios.html)

## Adding a new component

Check out the instructions in the [docs in `application-services` for adding a new component and publishing it for iOS](https://github.com/mozilla/application-services/blob/main/docs/howtos/adding-a-new-component.md#distribute-your-component-with-rust-components-swift). The docs are also published for convenience in <https://mozilla.github.io/application-services/book/index.html>.


## Filing issues with rust-components-swift
Please open a ticket in https://github.com/mozilla/application-services/issues for any rust-component-swift related issues.
