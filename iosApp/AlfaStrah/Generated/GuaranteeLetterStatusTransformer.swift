// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct GuaranteeLetterStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = GuaranteeLetter.Status

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.inactive)
            case 1:
                return .success(.active)
            default:
                return .success(.inactive)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .inactive:
                return transformer.transform(destination: 0)
            case .active:
                return transformer.transform(destination: 1)
        }
    }
}
