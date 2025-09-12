// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfficeTimetableTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OfficeTimetable

    let dayName = "day"
    let isWorkingName = "is_working"
    let officeHoursName = "office_hours"

    let dayTransformer = WeekdayTransformer()
    let isWorkingTransformer = NumberTransformer<Any, Bool>()
    let officeHoursTransformer = OptionalTransformer(transformer: OfficeTimetableHoursTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let dayResult = dictionary[dayName].map(dayTransformer.transform(source:)) ?? .failure(.requirement)
        let isWorkingResult = dictionary[isWorkingName].map(isWorkingTransformer.transform(source:)) ?? .failure(.requirement)
        let officeHoursResult = officeHoursTransformer.transform(source: dictionary[officeHoursName])

        var errors: [(String, TransformerError)] = []
        dayResult.error.map { errors.append((dayName, $0)) }
        isWorkingResult.error.map { errors.append((isWorkingName, $0)) }
        officeHoursResult.error.map { errors.append((officeHoursName, $0)) }

        guard
            let day = dayResult.value,
            let isWorking = isWorkingResult.value,
            let officeHours = officeHoursResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                day: day,
                isWorking: isWorking,
                officeHours: officeHours
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let dayResult = dayTransformer.transform(destination: value.day)
        let isWorkingResult = isWorkingTransformer.transform(destination: value.isWorking)
        let officeHoursResult = officeHoursTransformer.transform(destination: value.officeHours)

        var errors: [(String, TransformerError)] = []
        dayResult.error.map { errors.append((dayName, $0)) }
        isWorkingResult.error.map { errors.append((isWorkingName, $0)) }
        officeHoursResult.error.map { errors.append((officeHoursName, $0)) }

        guard
            let day = dayResult.value,
            let isWorking = isWorkingResult.value,
            let officeHours = officeHoursResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[dayName] = day
        dictionary[isWorkingName] = isWorking
        dictionary[officeHoursName] = officeHours
        return .success(dictionary)
    }
}
