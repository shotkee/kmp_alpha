// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InfoMessageActionTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InfoMessageActionType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "close":
                return .success(.close)
            case "retry":
                return .success(.retry)
            case "chat":
                return .success(.toChat)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .close:
                return transformer.transform(destination: "close")
            case .retry:
                return transformer.transform(destination: "retry")
            case .toChat:
                return transformer.transform(destination: "chat")
        }
    }
}
