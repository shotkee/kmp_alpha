// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceCategoryCategoryKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceCategory.CategoryKind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.none)
            case 1:
                return .success(.auto)
            case 2:
                return .success(.health)
            case 3:
                return .success(.property)
            case 4:
                return .success(.travel)
            case 5:
                return .success(.passengers)
            case 6:
                return .success(.life)
            default:
                return .success(.none)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .none:
                return transformer.transform(destination: 0)
            case .auto:
                return transformer.transform(destination: 1)
            case .health:
                return transformer.transform(destination: 2)
            case .property:
                return transformer.transform(destination: 3)
            case .travel:
                return transformer.transform(destination: 4)
            case .passengers:
                return transformer.transform(destination: 5)
            case .life:
                return transformer.transform(destination: 6)
        }
    }
}
