// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfflineAppointmentDateTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OfflineAppointmentDate

    let dateName = "date"
    let startTimeName = "start_time"
    let endTimeName = "end_time"

    let dateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let startTimeTransformer = CastTransformer<Any, String>()
    let endTimeTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let startTimeResult = dictionary[startTimeName].map(startTimeTransformer.transform(source:)) ?? .failure(.requirement)
        let endTimeResult = dictionary[endTimeName].map(endTimeTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        dateResult.error.map { errors.append((dateName, $0)) }
        startTimeResult.error.map { errors.append((startTimeName, $0)) }
        endTimeResult.error.map { errors.append((endTimeName, $0)) }

        guard
            let date = dateResult.value,
            let startTime = startTimeResult.value,
            let endTime = endTimeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                date: date,
                startTime: startTime,
                endTime: endTime
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let dateResult = dateTransformer.transform(destination: value.date)
        let startTimeResult = startTimeTransformer.transform(destination: value.startTime)
        let endTimeResult = endTimeTransformer.transform(destination: value.endTime)

        var errors: [(String, TransformerError)] = []
        dateResult.error.map { errors.append((dateName, $0)) }
        startTimeResult.error.map { errors.append((startTimeName, $0)) }
        endTimeResult.error.map { errors.append((endTimeName, $0)) }

        guard
            let date = dateResult.value,
            let startTime = startTimeResult.value,
            let endTime = endTimeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[dateName] = date
        dictionary[startTimeName] = startTime
        dictionary[endTimeName] = endTime
        return .success(dictionary)
    }
}
