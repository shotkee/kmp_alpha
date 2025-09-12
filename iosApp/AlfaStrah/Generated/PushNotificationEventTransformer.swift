// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct PushNotificationEventTransformer: Transformer {
    typealias Source = Any
    typealias Destination = PushNotificationEvent

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.received)
            case 2:
                return .success(.opened)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .received:
                return transformer.transform(destination: 1)
            case .opened:
                return transformer.transform(destination: 2)
        }
    }
}
