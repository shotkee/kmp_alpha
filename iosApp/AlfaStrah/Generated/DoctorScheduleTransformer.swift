// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DoctorScheduleTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorSchedule

    let dateName = "date"
    let scheduleIntervalsName = "intervals"

    let dateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let scheduleIntervalsTransformer = ArrayTransformer(from: Any.self, transformer: DoctorScheduleIntervalTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let scheduleIntervalsResult = dictionary[scheduleIntervalsName].map(scheduleIntervalsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        dateResult.error.map { errors.append((dateName, $0)) }
        scheduleIntervalsResult.error.map { errors.append((scheduleIntervalsName, $0)) }

        guard
            let date = dateResult.value,
            let scheduleIntervals = scheduleIntervalsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                date: date,
                scheduleIntervals: scheduleIntervals
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let dateResult = dateTransformer.transform(destination: value.date)
        let scheduleIntervalsResult = scheduleIntervalsTransformer.transform(destination: value.scheduleIntervals)

        var errors: [(String, TransformerError)] = []
        dateResult.error.map { errors.append((dateName, $0)) }
        scheduleIntervalsResult.error.map { errors.append((scheduleIntervalsName, $0)) }

        guard
            let date = dateResult.value,
            let scheduleIntervals = scheduleIntervalsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[dateName] = date
        dictionary[scheduleIntervalsName] = scheduleIntervals
        return .success(dictionary)
    }
}
