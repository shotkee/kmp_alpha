// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct ClinicFilterRenderTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicFilter.RenderType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "checkbox":
                return .success(.checkbox)
            case "specialities":
                return .success(.specialities)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .checkbox:
                return transformer.transform(destination: "checkbox")
            case .specialities:
                return transformer.transform(destination: "specialities")
        }
    }
}
