// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationParticipantTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationParticipant

    let descriptionName = "description"
    let titleName = "title"
    let detailedName = "detailed"
    let hasErrorName = "has_error"
    let errorTextName = "error_text"

    let descriptionTransformer = CastTransformer<Any, String>()
    let titleTransformer = CastTransformer<Any, String>()
    let detailedTransformer = OptionalTransformer(transformer: OsagoProlongationParticipantDetailedTransformer())
    let hasErrorTransformer = NumberTransformer<Any, Bool>()
    let errorTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let detailedResult = detailedTransformer.transform(source: dictionary[detailedName])
        let hasErrorResult = dictionary[hasErrorName].map(hasErrorTransformer.transform(source:)) ?? .failure(.requirement)
        let errorTextResult = errorTextTransformer.transform(source: dictionary[errorTextName])

        var errors: [(String, TransformerError)] = []
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        detailedResult.error.map { errors.append((detailedName, $0)) }
        hasErrorResult.error.map { errors.append((hasErrorName, $0)) }
        errorTextResult.error.map { errors.append((errorTextName, $0)) }

        guard
            let description = descriptionResult.value,
            let title = titleResult.value,
            let detailed = detailedResult.value,
            let hasError = hasErrorResult.value,
            let errorText = errorTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                description: description,
                title: title,
                detailed: detailed,
                hasError: hasError,
                errorText: errorText
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let titleResult = titleTransformer.transform(destination: value.title)
        let detailedResult = detailedTransformer.transform(destination: value.detailed)
        let hasErrorResult = hasErrorTransformer.transform(destination: value.hasError)
        let errorTextResult = errorTextTransformer.transform(destination: value.errorText)

        var errors: [(String, TransformerError)] = []
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        detailedResult.error.map { errors.append((detailedName, $0)) }
        hasErrorResult.error.map { errors.append((hasErrorName, $0)) }
        errorTextResult.error.map { errors.append((errorTextName, $0)) }

        guard
            let description = descriptionResult.value,
            let title = titleResult.value,
            let detailed = detailedResult.value,
            let hasError = hasErrorResult.value,
            let errorText = errorTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[descriptionName] = description
        dictionary[titleName] = title
        dictionary[detailedName] = detailed
        dictionary[hasErrorName] = hasError
        dictionary[errorTextName] = errorText
        return .success(dictionary)
    }
}
