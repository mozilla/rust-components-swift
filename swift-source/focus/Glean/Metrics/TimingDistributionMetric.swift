/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/// This implements the developer facing API for recording timing distribution metrics.
///
/// Instances of this class type are automatically generated by the parsers at build time,
/// allowing developers to record values that were previously registered in the metrics.yaml file.
///
/// The timing distribution API only exposes the `TimingDistributionMetricType.start()`,
/// `TimingDistributionMetricType.stopAndAccumulate(_:)` and `TimingDistributionMetricType.cancel(_:)`  methods.
public typealias TimingDistributionMetricType = TimingDistributionMetric

extension TimingDistributionMetricType {
    /// Convenience method to simplify measuring a function or block of code
    ///
    /// - parameters:
    ///     * funcToMeasure: Accepts a function or closure to measure that can return a value
    public func measure<U>(funcToMeasure: () -> U) -> U {
        let timerId = start()
        // Putting `stopAndAccumulate` in a `defer` block guarantees it will execute at the end
        // of the scope, after the return value is pushed onto the stack.
        // Reference: https://docs.swift.org/swift-book/LanguageGuide/ErrorHandling.html under
        // the "Specifying Cleanup Actions" section.
        defer {
            stopAndAccumulate(timerId)
        }
        return funcToMeasure()
    }

    /// Convenience method to simplify measuring a function or block of code
    ///
    /// If the measured function throws, the measurement is canceled and the exception rethrown.
    ///
    /// - parameters:
    ///     * funcToMeasure: Accepts a function or closure to measure that can return a value
    public func measure<U>(funcToMeasure: () throws -> U) throws -> U {
        let timerId = start()

        do {
            let returnValue = try funcToMeasure()
            stopAndAccumulate(timerId)
            return returnValue
        } catch {
            cancel(timerId)
            throw error
        }
    }
}
