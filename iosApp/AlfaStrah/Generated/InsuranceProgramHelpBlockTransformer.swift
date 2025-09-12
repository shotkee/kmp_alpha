// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceProgramHelpBlockTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceProgramHelpBlock

    let titleName = "title"
    let contentName = "detailed_content"

    let titleTransformer = CastTransformer<Any, String>()
    let contentTransformer = InsuranceProgramContentTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let contentResult = dictionary[contentName].map(contentTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        contentResult.error.map { errors.append((contentName, $0)) }

        guard
            let title = titleResult.value,
            let content = contentResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                content: content
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let contentResult = contentTransformer.transform(destination: value.content)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        contentResult.error.map { errors.append((contentName, $0)) }

        guard
            let title = titleResult.value,
            let content = contentResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[contentName] = content
        return .success(dictionary)
    }
}
