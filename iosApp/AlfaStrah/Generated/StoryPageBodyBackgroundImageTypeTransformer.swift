// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct StoryPageBodyBackgroundImageTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = StoryPageBody.BackgroundImageType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "image":
                return .success(.image)
            case "color_fill":
                return .success(.colorFill)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .image:
                return transformer.transform(destination: "image")
            case .colorFill:
                return transformer.transform(destination: "color_fill")
        }
    }
}
