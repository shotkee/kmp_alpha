// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct AccountTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AccountType

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.alfaStrah)
            case 1:
                return .success(.alfaLife)
            default:
                return .success(.alfaStrah)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .alfaStrah:
                return transformer.transform(destination: 0)
            case .alfaLife:
                return transformer.transform(destination: 1)
        }
    }
}
