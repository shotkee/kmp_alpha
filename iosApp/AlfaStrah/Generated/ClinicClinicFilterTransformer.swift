// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicClinicFilterTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Clinic.ClinicFilter

    let titleName = "title"
    let valuesName = "values"

    let titleTransformer = CastTransformer<Any, String>()
    let valuesTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let valuesResult = dictionary[valuesName].map(valuesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        valuesResult.error.map { errors.append((valuesName, $0)) }

        guard
            let title = titleResult.value,
            let values = valuesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                values: values
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let valuesResult = valuesTransformer.transform(destination: value.values)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        valuesResult.error.map { errors.append((valuesName, $0)) }

        guard
            let title = titleResult.value,
            let values = valuesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[valuesName] = values
        return .success(dictionary)
    }
}
