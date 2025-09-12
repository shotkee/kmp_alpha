// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct BackendActionUrlOpenMethodTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendAction.UrlOpenMethod

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "webview":
                return .success(.webview)
            case "external":
                return .success(.external)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .webview:
                return transformer.transform(destination: "webview")
            case .external:
                return transformer.transform(destination: "external")
        }
    }
}
