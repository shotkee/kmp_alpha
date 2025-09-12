// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct ApiStatusStateTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ApiStatus.State

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "normal":
                return .success(.normal)
            case "restricted":
                return .success(.restricted)
            case "blocked":
                return .success(.blocked)
            default:
                return .success(.normal)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .normal:
                return transformer.transform(destination: "normal")
            case .restricted:
                return transformer.transform(destination: "restricted")
            case .blocked:
                return transformer.transform(destination: "blocked")
        }
    }
}
