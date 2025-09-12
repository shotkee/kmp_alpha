// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct ResetPasswordResponsePassRecoveryFlowTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ResetPasswordResponse.PassRecoveryFlow

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "default":
                return .success(.regular)
            case "partner":
                return .success(.partner)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .regular:
                return transformer.transform(destination: "default")
            case .partner:
                return transformer.transform(destination: "partner")
        }
    }
}
