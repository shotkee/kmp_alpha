// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceBillHighlightingTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceBill.Highlighting

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.noHighlighting)
            case 1:
                return .success(.highlightWithRed)
            default:
                return .success(.noHighlighting)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .noHighlighting:
                return transformer.transform(destination: 0)
            case .highlightWithRed:
                return transformer.transform(destination: 1)
        }
    }
}
