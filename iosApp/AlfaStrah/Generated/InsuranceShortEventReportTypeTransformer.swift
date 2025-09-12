// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceShortEventReportTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceShort.EventReportType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.unsupported)
            case 1:
                return .success(.kasko)
            case 2:
                return .success(.osago)
            case 3:
                return .success(.doctor)
            case 4:
                return .success(.passenger)
            case 5:
                return .success(.vzr)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: 0)
            case .kasko:
                return transformer.transform(destination: 1)
            case .osago:
                return transformer.transform(destination: 2)
            case .doctor:
                return transformer.transform(destination: 3)
            case .passenger:
                return transformer.transform(destination: 4)
            case .vzr:
                return transformer.transform(destination: 5)
        }
    }
}
