// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct AuthTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AuthType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.notDefined)
            case 1:
                return .success(.full)
            case 2:
                return .success(.auto)
            case 3:
                return .success(.pin)
            case 4:
                return .success(.biometric)
            case 5:
                return .success(.demo)
            default:
                return .success(.notDefined)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .notDefined:
                return transformer.transform(destination: 0)
            case .full:
                return transformer.transform(destination: 1)
            case .auto:
                return transformer.transform(destination: 2)
            case .pin:
                return transformer.transform(destination: 3)
            case .biometric:
                return transformer.transform(destination: 4)
            case .demo:
                return transformer.transform(destination: 5)
        }
    }
}
