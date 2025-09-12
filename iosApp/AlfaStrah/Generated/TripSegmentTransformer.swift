// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct TripSegmentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = TripSegment

    let numberName = "number"
    let departureName = "departure"
    let arrivalName = "arrival"

    let numberTransformer = CastTransformer<Any, String>()
    let departureTransformer = CastTransformer<Any, String>()
    let arrivalTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let departureResult = dictionary[departureName].map(departureTransformer.transform(source:)) ?? .failure(.requirement)
        let arrivalResult = dictionary[arrivalName].map(arrivalTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        numberResult.error.map { errors.append((numberName, $0)) }
        departureResult.error.map { errors.append((departureName, $0)) }
        arrivalResult.error.map { errors.append((arrivalName, $0)) }

        guard
            let number = numberResult.value,
            let departure = departureResult.value,
            let arrival = arrivalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                number: number,
                departure: departure,
                arrival: arrival
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let numberResult = numberTransformer.transform(destination: value.number)
        let departureResult = departureTransformer.transform(destination: value.departure)
        let arrivalResult = arrivalTransformer.transform(destination: value.arrival)

        var errors: [(String, TransformerError)] = []
        numberResult.error.map { errors.append((numberName, $0)) }
        departureResult.error.map { errors.append((departureName, $0)) }
        arrivalResult.error.map { errors.append((arrivalName, $0)) }

        guard
            let number = numberResult.value,
            let departure = departureResult.value,
            let arrival = arrivalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[numberName] = number
        dictionary[departureName] = departure
        dictionary[arrivalName] = arrival
        return .success(dictionary)
    }
}
