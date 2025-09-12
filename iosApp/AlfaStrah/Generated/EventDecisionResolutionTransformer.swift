// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct EventDecisionResolutionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventDecision.Resolution

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.toTheServiceStation)
            case 2:
                return .success(.cashCompensation)
            case 3:
                return .success(.reject)
            default:
                return .success(.toTheServiceStation)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .toTheServiceStation:
                return transformer.transform(destination: 1)
            case .cashCompensation:
                return transformer.transform(destination: 2)
            case .reject:
                return transformer.transform(destination: 3)
        }
    }
}
