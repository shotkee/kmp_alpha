// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct FranchiseTransitionResultStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FranchiseTransitionResult.Status

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.nothingChanged)
            case 1:
                return .success(.changedAllPrograms)
            case 2:
                return .success(.changedSomePrograms)
            default:
                return .success(.nothingChanged)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .nothingChanged:
                return transformer.transform(destination: 0)
            case .changedAllPrograms:
                return transformer.transform(destination: 1)
            case .changedSomePrograms:
                return transformer.transform(destination: 2)
        }
    }
}
