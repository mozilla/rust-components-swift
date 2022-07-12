// -*- mode: Swift -*-

// AUTOGENERATED BY glean_parser v6.1.1. DO NOT EDIT. DO NOT COMMIT.

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */



import Glean

// swiftlint:disable superfluous_disable_command
// swiftlint:disable nesting
// swiftlint:disable line_length
// swiftlint:disable identifier_name
// swiftlint:disable force_try

extension GleanMetrics {
    class GleanBuild {
        private init() {
            // Intentionally left private, no external user can instantiate a new global object.
        }

        public static let info = BuildInfo(buildDate: DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "UTC"), year: 2022, month: 7, day: 12, hour: 15, minute: 10, second: 30))
    }

    enum NimbusEvents {
        struct EnrollmentExtra: EventExtras {
            var branch: String?
            var enrollmentId: String?
            var experiment: String?

            func toExtraRecord() -> [String: String] {
                var record = [String: String]()

                if let branch = self.branch {
                    record["branch"] = String(branch)
                }
                if let enrollmentId = self.enrollmentId {
                    record["enrollment_id"] = String(enrollmentId)
                }
                if let experiment = self.experiment {
                    record["experiment"] = String(experiment)
                }

                return record
            }
        }

        struct UnenrollmentExtra: EventExtras {
            var branch: String?
            var enrollmentId: String?
            var experiment: String?

            func toExtraRecord() -> [String: String] {
                var record = [String: String]()

                if let branch = self.branch {
                    record["branch"] = String(branch)
                }
                if let enrollmentId = self.enrollmentId {
                    record["enrollment_id"] = String(enrollmentId)
                }
                if let experiment = self.experiment {
                    record["experiment"] = String(experiment)
                }

                return record
            }
        }

        struct DisqualificationExtra: EventExtras {
            var branch: String?
            var enrollmentId: String?
            var experiment: String?

            func toExtraRecord() -> [String: String] {
                var record = [String: String]()

                if let branch = self.branch {
                    record["branch"] = String(branch)
                }
                if let enrollmentId = self.enrollmentId {
                    record["enrollment_id"] = String(enrollmentId)
                }
                if let experiment = self.experiment {
                    record["experiment"] = String(experiment)
                }

                return record
            }
        }

        struct ExposureExtra: EventExtras {
            var branch: String?
            var enrollmentId: String?
            var experiment: String?

            func toExtraRecord() -> [String: String] {
                var record = [String: String]()

                if let branch = self.branch {
                    record["branch"] = String(branch)
                }
                if let enrollmentId = self.enrollmentId {
                    record["enrollment_id"] = String(enrollmentId)
                }
                if let experiment = self.experiment {
                    record["experiment"] = String(experiment)
                }

                return record
            }
        }

        /// Recorded when a user has met the conditions and is first bucketed into an
        /// experiment (i.e. targeting matched and they were randomized into a bucket and
        /// branch of the experiment). Expected a maximum of once per experiment per user.
        static let enrollment = EventMetricType<NoExtraKeys, EnrollmentExtra>( // generated from nimbus_events.enrollment
            CommonMetricData(
                category: "nimbus_events",
                name: "enrollment",
                sendInPings: ["events"],
                lifetime: .ping,
                disabled: false
            )
            , ["branch", "enrollment_id", "experiment"]
        )

        /// Recorded when either telemetry is disabled, or the experiment has run for its
        /// designed duration (i.e. it is no longer present in the Nimbus Remote Settings
        /// collection)
        static let unenrollment = EventMetricType<NoExtraKeys, UnenrollmentExtra>( // generated from nimbus_events.unenrollment
            CommonMetricData(
                category: "nimbus_events",
                name: "unenrollment",
                sendInPings: ["events"],
                lifetime: .ping,
                disabled: false
            )
            , ["branch", "enrollment_id", "experiment"]
        )

        /// Recorded when a user becomes ineligible to continue receiving the treatment for
        /// an enrolled experiment, for reasons such as the user opting out of the
        /// experiment or no longer matching targeting for the experiment.
        static let disqualification = EventMetricType<NoExtraKeys, DisqualificationExtra>( // generated from nimbus_events.disqualification
            CommonMetricData(
                category: "nimbus_events",
                name: "disqualification",
                sendInPings: ["events"],
                lifetime: .ping,
                disabled: false
            )
            , ["branch", "enrollment_id", "experiment"]
        )

        /// Recorded when a user actually observes an experimental treatment, or would have
        /// observed an experimental treatment if they had been in a branch that would have
        /// shown one.
        static let exposure = EventMetricType<NoExtraKeys, ExposureExtra>( // generated from nimbus_events.exposure
            CommonMetricData(
                category: "nimbus_events",
                name: "exposure",
                sendInPings: ["events"],
                lifetime: .ping,
                disabled: false
            )
            , ["branch", "enrollment_id", "experiment"]
        )

    }

}
