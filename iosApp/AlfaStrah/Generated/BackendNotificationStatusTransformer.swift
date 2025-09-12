// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct BackendNotificationStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendNotification.Status

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "read":
                return .success(.read)
            case "unread":
                return .success(.unread)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .read:
                return transformer.transform(destination: "read")
            case .unread:
                return transformer.transform(destination: "unread")
        }
    }
}
