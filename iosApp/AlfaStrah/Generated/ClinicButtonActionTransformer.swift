// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct ClinicButtonActionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Clinic.ButtonAction

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "appointment_online":
                return .success(.appointmentOnline)
            case "appointment_offline":
                return .success(.appointmentOffline)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .appointmentOnline:
                return transformer.transform(destination: "appointment_online")
            case .appointmentOffline:
                return transformer.transform(destination: "appointment_offline")
        }
    }
}
