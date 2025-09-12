// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct RiskCategoryRiskCategoryKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RiskCategory.RiskCategoryKind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.normal)
            case 1:
                return .success(.expandable)
            default:
                return .success(.normal)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .normal:
                return transformer.transform(destination: 0)
            case .expandable:
                return transformer.transform(destination: 1)
        }
    }
}
