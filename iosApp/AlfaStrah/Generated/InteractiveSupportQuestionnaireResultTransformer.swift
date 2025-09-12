// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InteractiveSupportQuestionnaireResultTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportQuestionnaireResult

    let typeName = "type"
    let phoneName = "phone"
    let contentName = "detailed_content"
    let buttonName = "button"

    let typeTransformer = InteractiveSupportQuestionnaireResultActionTypeTransformer()
    let phoneTransformer = OptionalTransformer(transformer: PhoneTransformer())
    let contentTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: InteractiveSupportQuestionnaireResultContentTransformer(), skipFailures: true))
    let buttonTransformer = OptionalTransformer(transformer: BackendButtonTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = phoneTransformer.transform(source: dictionary[phoneName])
        let contentResult = contentTransformer.transform(source: dictionary[contentName])
        let buttonResult = buttonTransformer.transform(source: dictionary[buttonName])

        var errors: [(String, TransformerError)] = []
        typeResult.error.map { errors.append((typeName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        contentResult.error.map { errors.append((contentName, $0)) }
        buttonResult.error.map { errors.append((buttonName, $0)) }

        guard
            let type = typeResult.value,
            let phone = phoneResult.value,
            let content = contentResult.value,
            let button = buttonResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                type: type,
                phone: phone,
                content: content,
                button: button
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let typeResult = typeTransformer.transform(destination: value.type)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let contentResult = contentTransformer.transform(destination: value.content)
        let buttonResult = buttonTransformer.transform(destination: value.button)

        var errors: [(String, TransformerError)] = []
        typeResult.error.map { errors.append((typeName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        contentResult.error.map { errors.append((contentName, $0)) }
        buttonResult.error.map { errors.append((buttonName, $0)) }

        guard
            let type = typeResult.value,
            let phone = phoneResult.value,
            let content = contentResult.value,
            let button = buttonResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[typeName] = type
        dictionary[phoneName] = phone
        dictionary[contentName] = content
        dictionary[buttonName] = button
        return .success(dictionary)
    }
}
