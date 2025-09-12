// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct AppAvailableAvailabilityStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AppAvailable.AvailabilityStatus

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.fullyAvailable)
            case 1:
                return .success(.partlyBlocked)
            case 2:
                return .success(.totalyBlocked)
            default:
                return .success(.partlyBlocked)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .fullyAvailable:
                return transformer.transform(destination: 0)
            case .partlyBlocked:
                return transformer.transform(destination: 1)
            case .totalyBlocked:
                return transformer.transform(destination: 2)
        }
    }
}
