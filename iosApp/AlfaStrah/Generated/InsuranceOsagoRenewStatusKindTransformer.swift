// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceOsagoRenewStatusKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Insurance.OsagoRenewStatusKind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.notAvailable)
            case 1:
                return .success(.renewAvailable)
            case 2:
                return .success(.renewInProgress)
            case 3:
                return .success(.raymentPending)
            default:
                return .success(.notAvailable)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .notAvailable:
                return transformer.transform(destination: 0)
            case .renewAvailable:
                return transformer.transform(destination: 1)
            case .renewInProgress:
                return transformer.transform(destination: 2)
            case .raymentPending:
                return transformer.transform(destination: 3)
        }
    }
}
