// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct SosModelSosModelKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosModel.SosModelKind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.unsupported)
            case 1:
                return .success(.category)
            case 2:
                return .success(.phone)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: 0)
            case .category:
                return transformer.transform(destination: 1)
            case .phone:
                return transformer.transform(destination: 2)
        }
    }
}
