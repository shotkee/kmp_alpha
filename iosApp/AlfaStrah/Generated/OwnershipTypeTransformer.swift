// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct OwnershipTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OwnershipType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.house)
            case 2:
                return .success(.apartment)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .house:
                return transformer.transform(destination: 1)
            case .apartment:
                return transformer.transform(destination: 2)
        }
    }
}
