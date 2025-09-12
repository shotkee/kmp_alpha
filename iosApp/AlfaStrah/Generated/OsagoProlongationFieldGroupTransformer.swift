// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationFieldGroupTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationFieldGroup

    let titleName = "title"
    let fieldsName = "fields"

    let titleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let fieldsTransformer = ArrayTransformer(from: Any.self, transformer: OsagoProlongationFieldTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = titleTransformer.transform(source: dictionary[titleName])
        let fieldsResult = dictionary[fieldsName].map(fieldsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        fieldsResult.error.map { errors.append((fieldsName, $0)) }

        guard
            let title = titleResult.value,
            let fields = fieldsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                fields: fields
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let fieldsResult = fieldsTransformer.transform(destination: value.fields)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        fieldsResult.error.map { errors.append((fieldsName, $0)) }

        guard
            let title = titleResult.value,
            let fields = fieldsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[fieldsName] = fields
        return .success(dictionary)
    }
}
