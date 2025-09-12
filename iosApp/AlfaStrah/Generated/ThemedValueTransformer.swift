// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ThemedValueTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ThemedValue

    let lightName = "light"
    let darkName = "dark"

    let lightTransformer = CastTransformer<Any, String>()
    let darkTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let lightResult = dictionary[lightName].map(lightTransformer.transform(source:)) ?? .failure(.requirement)
        let darkResult = dictionary[darkName].map(darkTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        lightResult.error.map { errors.append((lightName, $0)) }
        darkResult.error.map { errors.append((darkName, $0)) }

        guard
            let light = lightResult.value,
            let dark = darkResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                light: light,
                dark: dark
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let lightResult = lightTransformer.transform(destination: value.light)
        let darkResult = darkTransformer.transform(destination: value.dark)

        var errors: [(String, TransformerError)] = []
        lightResult.error.map { errors.append((lightName, $0)) }
        darkResult.error.map { errors.append((darkName, $0)) }

        guard
            let light = lightResult.value,
            let dark = darkResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[lightName] = light
        dictionary[darkName] = dark
        return .success(dictionary)
    }
}
