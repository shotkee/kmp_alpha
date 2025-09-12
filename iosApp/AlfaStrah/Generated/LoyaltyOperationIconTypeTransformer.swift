// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct LoyaltyOperationIconTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = LoyaltyOperation.IconType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.points)
            case 2:
                return .success(.friend)
            case 3:
                return .success(.phone)
            case 4:
                return .success(.car)
            case 5:
                return .success(.fly)
            case 6:
                return .success(.brush)
            case 7:
                return .success(.sofa)
            case 8:
                return .success(.trane)
            default:
                return .success(.points)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .points:
                return transformer.transform(destination: 1)
            case .friend:
                return transformer.transform(destination: 2)
            case .phone:
                return transformer.transform(destination: 3)
            case .car:
                return transformer.transform(destination: 4)
            case .fly:
                return transformer.transform(destination: 5)
            case .brush:
                return transformer.transform(destination: 6)
            case .sofa:
                return transformer.transform(destination: 7)
            case .trane:
                return transformer.transform(destination: 8)
        }
    }
}
