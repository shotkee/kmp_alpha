// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfficeTimetableHoursTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OfficeTimetableHours

    let startTimeName = "start_time"
    let closeTimeName = "close_time"
    let breakStartTimeName = "break_start_time"
    let breakEndTimeName = "break_end_time"

    let startTimeTransformer = CastTransformer<Any, String>()
    let closeTimeTransformer = CastTransformer<Any, String>()
    let breakStartTimeTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let breakEndTimeTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let startTimeResult = dictionary[startTimeName].map(startTimeTransformer.transform(source:)) ?? .failure(.requirement)
        let closeTimeResult = dictionary[closeTimeName].map(closeTimeTransformer.transform(source:)) ?? .failure(.requirement)
        let breakStartTimeResult = breakStartTimeTransformer.transform(source: dictionary[breakStartTimeName])
        let breakEndTimeResult = breakEndTimeTransformer.transform(source: dictionary[breakEndTimeName])

        var errors: [(String, TransformerError)] = []
        startTimeResult.error.map { errors.append((startTimeName, $0)) }
        closeTimeResult.error.map { errors.append((closeTimeName, $0)) }
        breakStartTimeResult.error.map { errors.append((breakStartTimeName, $0)) }
        breakEndTimeResult.error.map { errors.append((breakEndTimeName, $0)) }

        guard
            let startTime = startTimeResult.value,
            let closeTime = closeTimeResult.value,
            let breakStartTime = breakStartTimeResult.value,
            let breakEndTime = breakEndTimeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                startTime: startTime,
                closeTime: closeTime,
                breakStartTime: breakStartTime,
                breakEndTime: breakEndTime
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let startTimeResult = startTimeTransformer.transform(destination: value.startTime)
        let closeTimeResult = closeTimeTransformer.transform(destination: value.closeTime)
        let breakStartTimeResult = breakStartTimeTransformer.transform(destination: value.breakStartTime)
        let breakEndTimeResult = breakEndTimeTransformer.transform(destination: value.breakEndTime)

        var errors: [(String, TransformerError)] = []
        startTimeResult.error.map { errors.append((startTimeName, $0)) }
        closeTimeResult.error.map { errors.append((closeTimeName, $0)) }
        breakStartTimeResult.error.map { errors.append((breakStartTimeName, $0)) }
        breakEndTimeResult.error.map { errors.append((breakEndTimeName, $0)) }

        guard
            let startTime = startTimeResult.value,
            let closeTime = closeTimeResult.value,
            let breakStartTime = breakStartTimeResult.value,
            let breakEndTime = breakEndTimeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[startTimeName] = startTime
        dictionary[closeTimeName] = closeTime
        dictionary[breakStartTimeName] = breakStartTime
        dictionary[breakEndTimeName] = breakEndTime
        return .success(dictionary)
    }
}
