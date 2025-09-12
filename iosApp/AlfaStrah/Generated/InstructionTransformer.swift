// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InstructionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Instruction

    let idName = "id"
    let insuranceCategoryIdName = "insurance_category_id"
    let lastModifiedName = "last_modified"
    let titleName = "title"
    let shortDescriptionName = "short_description"
    let fullDescriptionName = "full_description"
    let stepsName = "steps"

    let idTransformer = IdTransformer<Any>()
    let insuranceCategoryIdTransformer = IdTransformer<Any>()
    let lastModifiedTransformer = TimestampTransformer<Any>(scale: 1)
    let titleTransformer = CastTransformer<Any, String>()
    let shortDescriptionTransformer = CastTransformer<Any, String>()
    let fullDescriptionTransformer = CastTransformer<Any, String>()
    let stepsTransformer = ArrayTransformer(from: Any.self, transformer: InstructionStepTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceCategoryIdResult = dictionary[insuranceCategoryIdName].map(insuranceCategoryIdTransformer.transform(source:)) ?? .failure(.requirement)
        let lastModifiedResult = dictionary[lastModifiedName].map(lastModifiedTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let shortDescriptionResult = dictionary[shortDescriptionName].map(shortDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let fullDescriptionResult = dictionary[fullDescriptionName].map(fullDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let stepsResult = dictionary[stepsName].map(stepsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        insuranceCategoryIdResult.error.map { errors.append((insuranceCategoryIdName, $0)) }
        lastModifiedResult.error.map { errors.append((lastModifiedName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        shortDescriptionResult.error.map { errors.append((shortDescriptionName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        stepsResult.error.map { errors.append((stepsName, $0)) }

        guard
            let id = idResult.value,
            let insuranceCategoryId = insuranceCategoryIdResult.value,
            let lastModified = lastModifiedResult.value,
            let title = titleResult.value,
            let shortDescription = shortDescriptionResult.value,
            let fullDescription = fullDescriptionResult.value,
            let steps = stepsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                insuranceCategoryId: insuranceCategoryId,
                lastModified: lastModified,
                title: title,
                shortDescription: shortDescription,
                fullDescription: fullDescription,
                steps: steps
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let insuranceCategoryIdResult = insuranceCategoryIdTransformer.transform(destination: value.insuranceCategoryId)
        let lastModifiedResult = lastModifiedTransformer.transform(destination: value.lastModified)
        let titleResult = titleTransformer.transform(destination: value.title)
        let shortDescriptionResult = shortDescriptionTransformer.transform(destination: value.shortDescription)
        let fullDescriptionResult = fullDescriptionTransformer.transform(destination: value.fullDescription)
        let stepsResult = stepsTransformer.transform(destination: value.steps)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        insuranceCategoryIdResult.error.map { errors.append((insuranceCategoryIdName, $0)) }
        lastModifiedResult.error.map { errors.append((lastModifiedName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        shortDescriptionResult.error.map { errors.append((shortDescriptionName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        stepsResult.error.map { errors.append((stepsName, $0)) }

        guard
            let id = idResult.value,
            let insuranceCategoryId = insuranceCategoryIdResult.value,
            let lastModified = lastModifiedResult.value,
            let title = titleResult.value,
            let shortDescription = shortDescriptionResult.value,
            let fullDescription = fullDescriptionResult.value,
            let steps = stepsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[insuranceCategoryIdName] = insuranceCategoryId
        dictionary[lastModifiedName] = lastModified
        dictionary[titleName] = title
        dictionary[shortDescriptionName] = shortDescription
        dictionary[fullDescriptionName] = fullDescription
        dictionary[stepsName] = steps
        return .success(dictionary)
    }
}
