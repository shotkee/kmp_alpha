// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceSearchPolicyProductTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceSearchPolicyProduct

    let idName = "id"
    let titleName = "title"
    let suggestName = "suggest"
    let exampleName = "example"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let suggestTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let exampleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let suggestResult = suggestTransformer.transform(source: dictionary[suggestName])
        let exampleResult = exampleTransformer.transform(source: dictionary[exampleName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        suggestResult.error.map { errors.append((suggestName, $0)) }
        exampleResult.error.map { errors.append((exampleName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let suggest = suggestResult.value,
            let example = exampleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                suggest: suggest,
                example: example
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let suggestResult = suggestTransformer.transform(destination: value.suggest)
        let exampleResult = exampleTransformer.transform(destination: value.example)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        suggestResult.error.map { errors.append((suggestName, $0)) }
        exampleResult.error.map { errors.append((exampleName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let suggest = suggestResult.value,
            let example = exampleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[suggestName] = suggest
        dictionary[exampleName] = example
        return .success(dictionary)
    }
}
