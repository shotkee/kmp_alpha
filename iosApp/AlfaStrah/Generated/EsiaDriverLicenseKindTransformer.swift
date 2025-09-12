// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct EsiaDriverLicenseKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EsiaDriverLicense.Kind

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "RF_DRIVING_LICENSE":
                return .success(.rus)
            case "date":
                return .success(.unknown)
            default:
                return .success(.unknown)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .rus:
                return transformer.transform(destination: "RF_DRIVING_LICENSE")
            case .unknown:
                return transformer.transform(destination: "date")
        }
    }
}
