// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryApplicationSubmitResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryApplicationSubmitResponse

    let isApplicationAcceptedName = "success"
    let titleName = "title"
    let descriptionName = "description"

    let isApplicationAcceptedTransformer = NumberTransformer<Any, Bool>()
    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let isApplicationAcceptedResult = dictionary[isApplicationAcceptedName].map(isApplicationAcceptedTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        isApplicationAcceptedResult.error.map { errors.append((isApplicationAcceptedName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }

        guard
            let isApplicationAccepted = isApplicationAcceptedResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                isApplicationAccepted: isApplicationAccepted,
                title: title,
                description: description
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let isApplicationAcceptedResult = isApplicationAcceptedTransformer.transform(destination: value.isApplicationAccepted)
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)

        var errors: [(String, TransformerError)] = []
        isApplicationAcceptedResult.error.map { errors.append((isApplicationAcceptedName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }

        guard
            let isApplicationAccepted = isApplicationAcceptedResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[isApplicationAcceptedName] = isApplicationAccepted
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        return .success(dictionary)
    }
}
