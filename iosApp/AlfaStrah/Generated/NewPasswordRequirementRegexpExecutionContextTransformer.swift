// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct NewPasswordRequirementRegexpExecutionContextTransformer: Transformer {
    typealias Source = Any
    typealias Destination = NewPasswordRequirement.RegexpExecutionContext

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "always":
                return .success(.showAlways)
            case "positive":
                return .success(.satisfiedIfPositiveResult)
            case "negative":
                return .success(.satisfiedIfNegativeResult)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .showAlways:
                return transformer.transform(destination: "always")
            case .satisfiedIfPositiveResult:
                return transformer.transform(destination: "positive")
            case .satisfiedIfNegativeResult:
                return transformer.transform(destination: "negative")
        }
    }
}
