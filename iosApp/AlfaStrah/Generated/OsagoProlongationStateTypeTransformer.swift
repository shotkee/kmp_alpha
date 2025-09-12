// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct OsagoProlongationStateTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongation.StateType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case -1:
                return .success(.unsupported)
            case 0:
                return .success(.success)
            case 1:
                return .success(.failure)
            case 2:
                return .success(.error)
            case 3:
                return .success(.inProcessed)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: -1)
            case .success:
                return transformer.transform(destination: 0)
            case .failure:
                return transformer.transform(destination: 1)
            case .error:
                return transformer.transform(destination: 2)
            case .inProcessed:
                return transformer.transform(destination: 3)
        }
    }
}
