// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct VoteAnswerAnswerTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VoteAnswer.Answer

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "yes":
                return .success(.positive)
            case "no":
                return .success(.negative)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .positive:
                return transformer.transform(destination: "yes")
            case .negative:
                return transformer.transform(destination: "no")
        }
    }
}
