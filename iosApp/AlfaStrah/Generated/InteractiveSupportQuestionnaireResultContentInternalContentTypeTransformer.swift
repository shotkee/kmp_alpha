// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InteractiveSupportQuestionnaireResultContentInternalContentTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportQuestionnaireResultContent.InternalContentType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "title":
                return .success(.title)
            case "image":
                return .success(.image)
            case "answers":
                return .success(.answers)
            case "steps":
                return .success(.steps)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .title:
                return transformer.transform(destination: "title")
            case .image:
                return transformer.transform(destination: "image")
            case .answers:
                return transformer.transform(destination: "answers")
            case .steps:
                return transformer.transform(destination: "steps")
        }
    }
}
