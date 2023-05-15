# Swift Package for Mozilla's Rust Components

This repository is a Swift Package for distributing releases of Mozilla's various
Rust-based application components. It provides the Swift source code packaged in
a format understood by the Swift package manager, and depends on a pre-compiled
binary release of the underlying Rust code published from [mozilla/application-services](
https://github.com/mozilla/application-service).

For more information, please consult:

* [application-services ADR-0003](https://github.com/mozilla/application-services/blob/main/docs/adr/0003-swift-packaging.md),
  which describes the overall plan for distributing Rust-based components as Swift packages.
* The [Swift Package Manager docs](https://swift.org/package-manager/) and [GitHub repo](https://github.com/apple/swift-package-manager),
  which explain the details of how Swift Packages work (and hence why this repo is set up the way it is).
* The [`ios-rust` crate](https://github.com/mozilla/application-services/tree/main/megazords/ios-rust) which is currently
  responsible for publishing the pre-built `MozillaRustComponents.xcframework.zip` and `FocusRustComponents.xcframework.zip` bundles on which this repository depends.

## Overview

Here's a diagram of how this repository relates to the application-services repository
and its release artifacts:

<!--
  N.B. you can edit this image in Google Docs and changes will be reflected automatically:

    https://docs.google.com/drawings/d/1tX05I-e6hNBQxch7PescDH7k4G7ddAJwXDPoIqp1RYk/edit
-->
<img src="https://docs.google.com/drawings/d/e/2PACX-1vRnyxy7VjdD3bYTso8V3AL5FpIQ4_S54dOCDI6fxfZEbG3_CVBwZZP1uLYbUVE9M54GSXUkNgewzOQm/pub?w=720&h=540" width="720" height="540" alt="A box diagram describing how the rust-components-swift repo, applicaiton-services repo, and MozillaRustComponents XCFramework interact">

Key points:

* The `application-services` repo publishes two binary artifacts `MozillaRustComponents.xcframework.zip` and `FocusRustComponents.xcframework.zip` containing
  the Rust code and FFI definitions for all components, compiled together into a single library.
* The `Package.swift` file refrences the xcframeworks as Swift binary targets.
* The `Package.swift` file defines a library per target (one for all the components used by `firefox-ios` and one for `focus-ios`)
    * Each library references its Swift source code directly as files in the repo. All components used by a target are copied into the same directory. For example, all the `firefox-ios` files are in the `swift-source/all` directory.
    * Each library depends on wrapper which wraps the binary to provide the pre-compiled Rust code. For example, [`FocusRustComponentWrapper`](./FocusRustComponentsWrapper/) wraps the Focus xcframework.

## Cutting a new release

Whenever a new release of the underlying components is availble, we need to tag a new release
in this repo to make them available to Swift components. To do so:

* Edit `Package.swift` to update the URL and checksum of `MozillaRustComponents.xcframework.zip`.
* Run `./make_tag.sh --as-version {APP_SERVICES_VERSION} X.Y.Z` to create the new tag.
* Run `git push origin X.Y.Z` to publish it to GitHub.

## Adding a new component

Check out the instructions in the [docs in `application-services` for adding a new component and publishing it for iOS](https://github.com/mozilla/application-services/blob/main/docs/howtos/adding-a-new-component.md#distribute-your-component-with-rust-components-swift). The docs are also published for convenience in <https://mozilla.github.io/application-services/book/index.html>.


## Testing
For testing instructions, you can checkout the [docs in the `application-services`](https://github.com/mozilla/application-services/tree/main/docs/howtos) which are published for convenience in <https://mozilla.github.io/application-services/book/index.html>

## Filing issues with rust-components-swift
Please open a ticket in https://github.com/mozilla/application-services/issues for any rust-component-swift related issues.
