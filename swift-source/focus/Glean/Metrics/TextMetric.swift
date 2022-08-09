/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/// This implements the developer facing API for recording text metrics.
///
/// Instances of this class type are automatically generated by the parsers at build time,
/// allowing developers to record values that were previously registered in the metrics.yaml file.
///
/// The text API only exposes the `TextMetricType.set(_:)` method, which takes care of validating the input
/// data and making sure that limits are enforced.
public typealias TextMetricType = TextMetric
