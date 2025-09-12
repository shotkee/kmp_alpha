// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct RiskDataRequiredStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RiskData.RequiredStatus

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.optional)
            case 1:
                return .success(.required)
            default:
                return .success(.optional)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .optional:
                return transformer.transform(destination: 0)
            case .required:
                return transformer.transform(destination: 1)
        }
    }
}
