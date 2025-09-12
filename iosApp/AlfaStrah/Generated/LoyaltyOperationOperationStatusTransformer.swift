// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct LoyaltyOperationOperationStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = LoyaltyOperation.OperationStatus

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.processing)
            case 1:
                return .success(.completed)
            case 2:
                return .success(.canceled)
            default:
                return .success(.processing)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .processing:
                return transformer.transform(destination: 0)
            case .completed:
                return transformer.transform(destination: 1)
            case .canceled:
                return transformer.transform(destination: 2)
        }
    }
}
