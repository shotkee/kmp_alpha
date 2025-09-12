// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InteractiveSupportAnswerNextStepTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportAnswer.NextStepType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "step":
                return .success(.nextStep)
            case "result":
                return .success(.result)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .nextStep:
                return transformer.transform(destination: "step")
            case .result:
                return transformer.transform(destination: "result")
        }
    }
}
