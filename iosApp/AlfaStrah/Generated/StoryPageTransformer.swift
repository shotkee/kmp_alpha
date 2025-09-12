// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct StoryPageTransformer: Transformer {
    typealias Source = Any
    typealias Destination = StoryPage

    let idName = "page_id"
    let timeName = "time"
    let bodyTypeName = "body_type"
    let bodyName = "body"
    let crossColorName = "cross_color"
    let stripeColorName = "stripe_color"
    let buttonName = "button"

    let idTransformer = NumberTransformer<Any, Int64>()
    let timeTransformer = NumberTransformer<Any, Float>()
    let bodyTypeTransformer = StoryPageBodyTypeTransformer()
    let bodyTransformer = OptionalTransformer(transformer: StoryPageBodyTransformer())
    let crossColorTransformer = CastTransformer<Any, String>()
    let stripeColorTransformer = CastTransformer<Any, String>()
    let buttonTransformer = OptionalTransformer(transformer: BackendButtonTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let timeResult = dictionary[timeName].map(timeTransformer.transform(source:)) ?? .failure(.requirement)
        let bodyTypeResult = dictionary[bodyTypeName].map(bodyTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let bodyResult = bodyTransformer.transform(source: dictionary[bodyName])
        let crossColorResult = dictionary[crossColorName].map(crossColorTransformer.transform(source:)) ?? .failure(.requirement)
        let stripeColorResult = dictionary[stripeColorName].map(stripeColorTransformer.transform(source:)) ?? .failure(.requirement)
        let buttonResult = buttonTransformer.transform(source: dictionary[buttonName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        timeResult.error.map { errors.append((timeName, $0)) }
        bodyTypeResult.error.map { errors.append((bodyTypeName, $0)) }
        bodyResult.error.map { errors.append((bodyName, $0)) }
        crossColorResult.error.map { errors.append((crossColorName, $0)) }
        stripeColorResult.error.map { errors.append((stripeColorName, $0)) }
        buttonResult.error.map { errors.append((buttonName, $0)) }

        guard
            let id = idResult.value,
            let time = timeResult.value,
            let bodyType = bodyTypeResult.value,
            let body = bodyResult.value,
            let crossColor = crossColorResult.value,
            let stripeColor = stripeColorResult.value,
            let button = buttonResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                time: time,
                bodyType: bodyType,
                body: body,
                crossColor: crossColor,
                stripeColor: stripeColor,
                button: button
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let timeResult = timeTransformer.transform(destination: value.time)
        let bodyTypeResult = bodyTypeTransformer.transform(destination: value.bodyType)
        let bodyResult = bodyTransformer.transform(destination: value.body)
        let crossColorResult = crossColorTransformer.transform(destination: value.crossColor)
        let stripeColorResult = stripeColorTransformer.transform(destination: value.stripeColor)
        let buttonResult = buttonTransformer.transform(destination: value.button)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        timeResult.error.map { errors.append((timeName, $0)) }
        bodyTypeResult.error.map { errors.append((bodyTypeName, $0)) }
        bodyResult.error.map { errors.append((bodyName, $0)) }
        crossColorResult.error.map { errors.append((crossColorName, $0)) }
        stripeColorResult.error.map { errors.append((stripeColorName, $0)) }
        buttonResult.error.map { errors.append((buttonName, $0)) }

        guard
            let id = idResult.value,
            let time = timeResult.value,
            let bodyType = bodyTypeResult.value,
            let body = bodyResult.value,
            let crossColor = crossColorResult.value,
            let stripeColor = stripeColorResult.value,
            let button = buttonResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[timeName] = time
        dictionary[bodyTypeName] = bodyType
        dictionary[bodyName] = body
        dictionary[crossColorName] = crossColor
        dictionary[stripeColorName] = stripeColor
        dictionary[buttonName] = button
        return .success(dictionary)
    }
}
