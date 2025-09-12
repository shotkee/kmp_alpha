// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct BackendComponentRequestMethodTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Method

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "GET":
                return .success(.get)
            case "POST":
                return .success(.post)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .get:
                return transformer.transform(destination: "GET")
            case .post:
                return transformer.transform(destination: "POST")
        }
    }
}
