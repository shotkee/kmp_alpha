// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InteractiveSupportQuestionnaireResultActionTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportQuestionnaireResult.ActionType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "screen":
                return .success(.showScreen)
            case "callback":
                return .success(.phoneCall)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .showScreen:
                return transformer.transform(destination: "screen")
            case .phoneCall:
                return transformer.transform(destination: "callback")
        }
    }
}
