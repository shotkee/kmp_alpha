// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct LoyaltyOperationLoyaltyTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = LoyaltyOperation.LoyaltyType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.spending)
            case 2:
                return .success(.addition)
            default:
                return .success(.spending)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .spending:
                return transformer.transform(destination: 1)
            case .addition:
                return transformer.transform(destination: 2)
        }
    }
}
