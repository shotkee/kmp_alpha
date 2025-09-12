// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceProductDetailedContentContentTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceProductDetailedContent.ContentType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "title":
                return .success(.title)
            case "linked_text":
                return .success(.linkedText)
            case "list_with_checkmark":
                return .success(.listWithCheckmark)
            case "image":
                return .success(.image)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .title:
                return transformer.transform(destination: "title")
            case .linkedText:
                return transformer.transform(destination: "linked_text")
            case .listWithCheckmark:
                return transformer.transform(destination: "list_with_checkmark")
            case .image:
                return transformer.transform(destination: "image")
        }
    }
}
