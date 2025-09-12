// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceSearchPolicyRequestStateTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceSearchPolicyRequest.State

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "UNCONFIRMED":
                return .success(.unconfirmed)
            case "CONFIRMED":
                return .success(.confirmed)
            case "CONFIRMED_DELAY":
                return .success(.confirmedWithDelay)
            case "PROCESSING":
                return .success(.processing)
            case "NUMBER_WRONG":
                return .success(.wrongNumber)
            case "POLICY_NOT_FOUND":
                return .success(.notFound)
            case "PERSON_NOT_FOUND":
                return .success(.personNotFound)
            default:
                return .success(.unconfirmed)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unconfirmed:
                return transformer.transform(destination: "UNCONFIRMED")
            case .confirmed:
                return transformer.transform(destination: "CONFIRMED")
            case .confirmedWithDelay:
                return transformer.transform(destination: "CONFIRMED_DELAY")
            case .processing:
                return transformer.transform(destination: "PROCESSING")
            case .wrongNumber:
                return transformer.transform(destination: "NUMBER_WRONG")
            case .notFound:
                return transformer.transform(destination: "POLICY_NOT_FOUND")
            case .personNotFound:
                return transformer.transform(destination: "PERSON_NOT_FOUND")
        }
    }
}
