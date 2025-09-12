// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SeriesAndNumberDocumentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SeriesAndNumberDocument

    let seriesName = "seria"
    let numberName = "number"

    let seriesTransformer = CastTransformer<Any, String>()
    let numberTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let seriesResult = dictionary[seriesName].map(seriesTransformer.transform(source:)) ?? .failure(.requirement)
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        seriesResult.error.map { errors.append((seriesName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }

        guard
            let series = seriesResult.value,
            let number = numberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                series: series,
                number: number
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let seriesResult = seriesTransformer.transform(destination: value.series)
        let numberResult = numberTransformer.transform(destination: value.number)

        var errors: [(String, TransformerError)] = []
        seriesResult.error.map { errors.append((seriesName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }

        guard
            let series = seriesResult.value,
            let number = numberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[seriesName] = series
        dictionary[numberName] = number
        return .success(dictionary)
    }
}
