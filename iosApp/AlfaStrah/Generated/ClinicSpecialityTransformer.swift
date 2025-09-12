// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicSpecialityTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicSpeciality

    let idName = "id"
    let titleName = "title"
    let userInputRequiredName = "user_input_required"

    let idTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let userInputRequiredTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let userInputRequiredResult = dictionary[userInputRequiredName].map(userInputRequiredTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        userInputRequiredResult.error.map { errors.append((userInputRequiredName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let userInputRequired = userInputRequiredResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                userInputRequired: userInputRequired
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let userInputRequiredResult = userInputRequiredTransformer.transform(destination: value.userInputRequired)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        userInputRequiredResult.error.map { errors.append((userInputRequiredName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let userInputRequired = userInputRequiredResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[userInputRequiredName] = userInputRequired
        return .success(dictionary)
    }
}
