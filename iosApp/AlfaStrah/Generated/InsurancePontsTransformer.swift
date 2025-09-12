// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsurancePontsTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsurancePonts

    let pointsName = "points"

    let pointsTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let pointsResult = dictionary[pointsName].map(pointsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        pointsResult.error.map { errors.append((pointsName, $0)) }

        guard
            let points = pointsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                points: points
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let pointsResult = pointsTransformer.transform(destination: value.points)

        var errors: [(String, TransformerError)] = []
        pointsResult.error.map { errors.append((pointsName, $0)) }

        guard
            let points = pointsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[pointsName] = points
        return .success(dictionary)
    }
}
