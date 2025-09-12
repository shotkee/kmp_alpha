// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct EventReportAccidentStatusKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventReportAccident.StatusKind

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "new":
                return .success(.new)
            case "in-work":
                return .success(.inWork)
            case "request-documents":
                return .success(.requestDocuments)
            case "payout":
                return .success(.payout)
            case "reject":
                return .success(.reject)
            default:
                return .success(.new)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .new:
                return transformer.transform(destination: "new")
            case .inWork:
                return transformer.transform(destination: "in-work")
            case .requestDocuments:
                return transformer.transform(destination: "request-documents")
            case .payout:
                return transformer.transform(destination: "payout")
            case .reject:
                return transformer.transform(destination: "reject")
        }
    }
}
