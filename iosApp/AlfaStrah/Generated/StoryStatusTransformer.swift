// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct StoryStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Story.Status

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "unviewed":
                return .success(.unviewed)
            case "viewed":
                return .success(.viewed)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unviewed:
                return transformer.transform(destination: "unviewed")
            case .viewed:
                return transformer.transform(destination: "viewed")
        }
    }
}
