// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InstructionStepTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InstructionStep

    let sortNumberName = "sort_number"
    let titleName = "title"
    let fullDescriptionName = "full_description"

    let sortNumberTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let fullDescriptionTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let sortNumberResult = dictionary[sortNumberName].map(sortNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let fullDescriptionResult = dictionary[fullDescriptionName].map(fullDescriptionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        sortNumberResult.error.map { errors.append((sortNumberName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }

        guard
            let sortNumber = sortNumberResult.value,
            let title = titleResult.value,
            let fullDescription = fullDescriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                sortNumber: sortNumber,
                title: title,
                fullDescription: fullDescription
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let sortNumberResult = sortNumberTransformer.transform(destination: value.sortNumber)
        let titleResult = titleTransformer.transform(destination: value.title)
        let fullDescriptionResult = fullDescriptionTransformer.transform(destination: value.fullDescription)

        var errors: [(String, TransformerError)] = []
        sortNumberResult.error.map { errors.append((sortNumberName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }

        guard
            let sortNumber = sortNumberResult.value,
            let title = titleResult.value,
            let fullDescription = fullDescriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[sortNumberName] = sortNumber
        dictionary[titleName] = title
        dictionary[fullDescriptionName] = fullDescription
        return .success(dictionary)
    }
}
