// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FranchiseTransitionResultInsuredPersonTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FranchiseTransitionResultInsuredPerson

    let idName = "id"
    let firstNameName = "first_name"
    let lastNameName = "last_name"
    let patronymicName = "patronymic"
    let isTransitionSuccessfulName = "is_successful"
    let transitionStatusDescriptionName = "result_message"

    let idTransformer = NumberTransformer<Any, Int>()
    let firstNameTransformer = CastTransformer<Any, String>()
    let lastNameTransformer = CastTransformer<Any, String>()
    let patronymicTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let isTransitionSuccessfulTransformer = NumberTransformer<Any, Bool>()
    let transitionStatusDescriptionTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let firstNameResult = dictionary[firstNameName].map(firstNameTransformer.transform(source:)) ?? .failure(.requirement)
        let lastNameResult = dictionary[lastNameName].map(lastNameTransformer.transform(source:)) ?? .failure(.requirement)
        let patronymicResult = patronymicTransformer.transform(source: dictionary[patronymicName])
        let isTransitionSuccessfulResult = dictionary[isTransitionSuccessfulName].map(isTransitionSuccessfulTransformer.transform(source:)) ?? .failure(.requirement)
        let transitionStatusDescriptionResult = dictionary[transitionStatusDescriptionName].map(transitionStatusDescriptionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        isTransitionSuccessfulResult.error.map { errors.append((isTransitionSuccessfulName, $0)) }
        transitionStatusDescriptionResult.error.map { errors.append((transitionStatusDescriptionName, $0)) }

        guard
            let id = idResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let patronymic = patronymicResult.value,
            let isTransitionSuccessful = isTransitionSuccessfulResult.value,
            let transitionStatusDescription = transitionStatusDescriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                firstName: firstName,
                lastName: lastName,
                patronymic: patronymic,
                isTransitionSuccessful: isTransitionSuccessful,
                transitionStatusDescription: transitionStatusDescription
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let firstNameResult = firstNameTransformer.transform(destination: value.firstName)
        let lastNameResult = lastNameTransformer.transform(destination: value.lastName)
        let patronymicResult = patronymicTransformer.transform(destination: value.patronymic)
        let isTransitionSuccessfulResult = isTransitionSuccessfulTransformer.transform(destination: value.isTransitionSuccessful)
        let transitionStatusDescriptionResult = transitionStatusDescriptionTransformer.transform(destination: value.transitionStatusDescription)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        isTransitionSuccessfulResult.error.map { errors.append((isTransitionSuccessfulName, $0)) }
        transitionStatusDescriptionResult.error.map { errors.append((transitionStatusDescriptionName, $0)) }

        guard
            let id = idResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let patronymic = patronymicResult.value,
            let isTransitionSuccessful = isTransitionSuccessfulResult.value,
            let transitionStatusDescription = transitionStatusDescriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[firstNameName] = firstName
        dictionary[lastNameName] = lastName
        dictionary[patronymicName] = patronymic
        dictionary[isTransitionSuccessfulName] = isTransitionSuccessful
        dictionary[transitionStatusDescriptionName] = transitionStatusDescription
        return .success(dictionary)
    }
}
