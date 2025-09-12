// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceShortRenewTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceShort.RenewType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.unsupported)
            case 1:
                return .success(.url)
            case 2:
                return .success(.osago)
            case 3:
                return .success(.kasko)
            case 4:
                return .success(.remont)
            case 5:
                return .success(.kindNeighbors)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: 0)
            case .url:
                return transformer.transform(destination: 1)
            case .osago:
                return transformer.transform(destination: 2)
            case .kasko:
                return transformer.transform(destination: 3)
            case .remont:
                return transformer.transform(destination: 4)
            case .kindNeighbors:
                return transformer.transform(destination: 5)
        }
    }
}
