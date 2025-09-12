// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BackendVisitDateTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendVisitDate

    let dateName = "date"
    let dateStringName = "show_date"

    let dateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let dateStringTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let dateStringResult = dictionary[dateStringName].map(dateStringTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        dateResult.error.map { errors.append((dateName, $0)) }
        dateStringResult.error.map { errors.append((dateStringName, $0)) }

        guard
            let date = dateResult.value,
            let dateString = dateStringResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                date: date,
                dateString: dateString
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let dateResult = dateTransformer.transform(destination: value.date)
        let dateStringResult = dateStringTransformer.transform(destination: value.dateString)

        var errors: [(String, TransformerError)] = []
        dateResult.error.map { errors.append((dateName, $0)) }
        dateStringResult.error.map { errors.append((dateStringName, $0)) }

        guard
            let date = dateResult.value,
            let dateString = dateStringResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[dateName] = date
        dictionary[dateStringName] = dateString
        return .success(dictionary)
    }
}
