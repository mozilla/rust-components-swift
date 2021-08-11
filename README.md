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
* The [`ios-rust` crate](https://github.com/mozilla/application-services/tree/main/megazords/ios) which is currently
  responsible for publishing the pre-built `MozillaRustComponents.xcframework.zip` bundle on which this
  repository depends.

## Overview

Here's a diagram of how this repository relates to the application-services repository
and its release artifacts:

<!--
  N.B. you can edit this image in Google Docs and changes will be reflected automatically:

    https://docs.google.com/drawings/d/1tX05I-e6hNBQxch7PescDH7k4G7ddAJwXDPoIqp1RYk/edit
-->
<img src="https://docs.google.com/drawings/d/e/2PACX-1vRnyxy7VjdD3bYTso8V3AL5FpIQ4_S54dOCDI6fxfZEbG3_CVBwZZP1uLYbUVE9M54GSXUkNgewzOQm/pub?w=720&h=540" width="720" height="540" alt="A box diagram describing how the rust-components-swift repo, applicaiton-services repo, and MozillaRustComponents XCFramework interact">

Key points:

* The `rust-components-swift` repo includes the `application-services` repo as a git submodule.
* The `application-services` repo publishes a binary artifact `MozillaRustComponents.xcframework.zip` containing
  the Rust code and FFI definitions for all components, compiled together into a single library.
* The `Package.swift` file references `MozillaRustComponents.xcframework.zip` as a Swift binary target.
* The `Package.swift` file defines an individual module for the Swift wrapper code of each component.
    * Each module references its Swift source code directly as files in the repo.
    * Each module depends on `MozillaRustComponents` to provide the pre-compiled Rust code.

## Cutting a new release

Whenever a new release of the underlying components is availble, we need to tag a new release
in this repo to make them available to Swift components. To do so:

* Update the git submodule under `./external` to the new release of the underlying components.
* Edit `Package.swift` to update the URL and checksum of `MozillaRustComponents.xcframework.zip`.
* Run `./make_tag.sh X.Y.Z` to create the new tag.
* Run `git push origin X.Y.Z` to publish it to GitHub.

## Adding a new component

To add a new component to be distributed via this repo, you'll need to:

* Add its Rust code and `.h` files to the build for the `MozillaRustComponents.xcframework.zip` bundle,
  following the docs for the [`ios-rust` crate](https://github.com/mozilla/application-services/tree/main/megazords/ios).
* Add the source for the component to this repository as a git submodule under `./external`.
* If the component needs to dynamically generate any Swift code (e.g. for UniFFI bindings, or Glean metrics),
  add logic for doing so to the `./generate.sh` script in this repository.
    * Swift packages can't dynamically generate code at build time, so we use the `./generate.sh` script
      to do it ahead-of-time when publishing a release.
* Edit `./Package.swift` to add the new component.
    * Add a new library product for the component under "products".
    * Add a corresponding target for the component under "targets".
        * Make sure it depends on "MozillaRustComponents" to pull in the pre-compiled Rust code,
          as well as on any third-party Swift packages that it may require.
* Follow the instructions below to test it out locally.

That's it! The component will be included in the next release of this package.

## Testing locally

Swift Packages can only be installed from a git repository, but luckily it is possible to use a
local checkout for a git repository for local testing.

You may also need to follow the instructions for [locally testing the `ios-rust` crate](
https://github.com/mozilla/application-services/blob/f3228cf1295154d144be64fc0945c9b3e93a07de/megazords/ios-rust/README.md#testing-locally)
if you need to test changes in the underlying Rust code.

To test out some local changes to this repo:

* Make your changes in a local checkout and commit them.
* Make a new tag via `./make_tag.sh -f 0.0.1`.
    * (You won't push this tag anywhere, but using a very low version number helps guard against
      any adverse consequences if it does accidentally escape your local machine).
* In a consuming application, delete the Swift Package dependency on `https://github.com/mozilla/rust-components-swift`
  and replace it with a dependency on `file:///path/to/your/local/checkout/rust-components-swift` at the `0.0.` release.

That's it! The consuming application should be able to import the package from your local checkout.

