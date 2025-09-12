// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EventDecisionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventDecision

    let idName = "id"
    let sumName = "sum"
    let numberName = "number"
    let decisionUrlName = "url"
    let resolutionName = "resolution"

    let idTransformer = IdTransformer<Any>()
    let sumTransformer = OptionalTransformer(transformer: MoneyTransformer())
    let numberTransformer = IdTransformer<Any>()
    let decisionUrlTransformer = UrlTransformer<Any>()
    let resolutionTransformer = EventDecisionResolutionTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let sumResult = sumTransformer.transform(source: dictionary[sumName])
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let decisionUrlResult = dictionary[decisionUrlName].map(decisionUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let resolutionResult = dictionary[resolutionName].map(resolutionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        sumResult.error.map { errors.append((sumName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        decisionUrlResult.error.map { errors.append((decisionUrlName, $0)) }
        resolutionResult.error.map { errors.append((resolutionName, $0)) }

        guard
            let id = idResult.value,
            let sum = sumResult.value,
            let number = numberResult.value,
            let decisionUrl = decisionUrlResult.value,
            let resolution = resolutionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                sum: sum,
                number: number,
                decisionUrl: decisionUrl,
                resolution: resolution
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let sumResult = sumTransformer.transform(destination: value.sum)
        let numberResult = numberTransformer.transform(destination: value.number)
        let decisionUrlResult = decisionUrlTransformer.transform(destination: value.decisionUrl)
        let resolutionResult = resolutionTransformer.transform(destination: value.resolution)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        sumResult.error.map { errors.append((sumName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        decisionUrlResult.error.map { errors.append((decisionUrlName, $0)) }
        resolutionResult.error.map { errors.append((resolutionName, $0)) }

        guard
            let id = idResult.value,
            let sum = sumResult.value,
            let number = numberResult.value,
            let decisionUrl = decisionUrlResult.value,
            let resolution = resolutionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[sumName] = sum
        dictionary[numberName] = number
        dictionary[decisionUrlName] = decisionUrl
        dictionary[resolutionName] = resolution
        return .success(dictionary)
    }
}
