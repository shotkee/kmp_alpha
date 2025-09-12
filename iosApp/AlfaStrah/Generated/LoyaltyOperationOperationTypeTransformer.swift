// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct LoyaltyOperationOperationTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = LoyaltyOperation.OperationType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 6:
                return .success(.interview)
            case 7:
                return .success(.friendInvited)
            case 8:
                return .success(.registration)
            default:
                return .success(.interview)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .interview:
                return transformer.transform(destination: 6)
            case .friendInvited:
                return transformer.transform(destination: 7)
            case .registration:
                return transformer.transform(destination: 8)
        }
    }
}
