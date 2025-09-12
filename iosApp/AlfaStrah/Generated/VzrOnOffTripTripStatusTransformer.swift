// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct VzrOnOffTripTripStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VzrOnOffTrip.TripStatus

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.planned)
            case 2:
                return .success(.active)
            case 3:
                return .success(.passed)
            default:
                return .success(.planned)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .planned:
                return transformer.transform(destination: 1)
            case .active:
                return transformer.transform(destination: 2)
            case .passed:
                return transformer.transform(destination: 3)
        }
    }
}
