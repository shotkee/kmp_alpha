// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceCompanyTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Insurance.Company

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "unsupported":
                return .success(.unsupported)
            case "yandex":
                return .success(.yandex)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: "unsupported")
            case .yandex:
                return transformer.transform(destination: "yandex")
        }
    }
}
