// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DoctorScheduleIntervalTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorScheduleInterval

    let idName = "id"
    let dateName = "date"
    let startName = "start_time"
    let endName = "end_time"
    let statusName = "is_free"

    let idTransformer = IdTransformer<Any>()
    let dateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let startTransformer = NumberTransformer<Any, TimeInterval>()
    let endTransformer = NumberTransformer<Any, TimeInterval>()
    let statusTransformer = DoctorScheduleIntervalStatusTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let startResult = dictionary[startName].map(startTransformer.transform(source:)) ?? .failure(.requirement)
        let endResult = dictionary[endName].map(endTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        startResult.error.map { errors.append((startName, $0)) }
        endResult.error.map { errors.append((endName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let date = dateResult.value,
            let start = startResult.value,
            let end = endResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                date: date,
                start: start,
                end: end,
                status: status
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let dateResult = dateTransformer.transform(destination: value.date)
        let startResult = startTransformer.transform(destination: value.start)
        let endResult = endTransformer.transform(destination: value.end)
        let statusResult = statusTransformer.transform(destination: value.status)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        startResult.error.map { errors.append((startName, $0)) }
        endResult.error.map { errors.append((endName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let date = dateResult.value,
            let start = startResult.value,
            let end = endResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[dateName] = date
        dictionary[startName] = start
        dictionary[endName] = end
        dictionary[statusName] = status
        return .success(dictionary)
    }
}
