// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VzrOnOffActivateTripResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VzrOnOffActivateTripResponse

    let tripName = "trip"
    let messageName = "message"

    let tripTransformer = VzrOnOffTripTransformer()
    let messageTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let tripResult = dictionary[tripName].map(tripTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = dictionary[messageName].map(messageTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        tripResult.error.map { errors.append((tripName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let trip = tripResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                trip: trip,
                message: message
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let tripResult = tripTransformer.transform(destination: value.trip)
        let messageResult = messageTransformer.transform(destination: value.message)

        var errors: [(String, TransformerError)] = []
        tripResult.error.map { errors.append((tripName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let trip = tripResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[tripName] = trip
        dictionary[messageName] = message
        return .success(dictionary)
    }
}
