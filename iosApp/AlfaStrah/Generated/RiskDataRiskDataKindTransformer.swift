// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct RiskDataRiskDataKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RiskData.RiskDataKind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.text)
            case 1:
                return .success(.radio)
            case 2:
                return .success(.checkbox)
            case 3:
                return .success(.decimalSelect)
            case 4:
                return .success(.date)
            case 5:
                return .success(.time)
            case 6:
                return .success(.decimal)
            default:
                return .success(.text)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .text:
                return transformer.transform(destination: 0)
            case .radio:
                return transformer.transform(destination: 1)
            case .checkbox:
                return transformer.transform(destination: 2)
            case .decimalSelect:
                return transformer.transform(destination: 3)
            case .date:
                return transformer.transform(destination: 4)
            case .time:
                return transformer.transform(destination: 5)
            case .decimal:
                return transformer.transform(destination: 6)
        }
    }
}
