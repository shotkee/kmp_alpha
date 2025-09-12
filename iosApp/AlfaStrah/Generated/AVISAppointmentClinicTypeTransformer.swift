// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct AVISAppointmentClinicTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AVISAppointment.ClinicType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "avis":
                return .success(.avis)
            case "javis":
                return .success(.javis)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .avis:
                return transformer.transform(destination: "avis")
            case .javis:
                return transformer.transform(destination: "javis")
        }
    }
}
