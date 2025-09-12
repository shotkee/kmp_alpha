// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct BackendActionInternalActionTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendAction.InternalActionType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "insurance":
                return .success(.isurance)
            case "dms_appointment_offline_mw":
                return .success(.offlineAppointment)
            case "dms_appointment_online":
                return .success(.onlineAppointment)
            case "url":
                return .success(.url)
            case "telemed":
                return .success(.telemed)
            case "event_report_osago":
                return .success(.osagoReport)
            case "event_report_kasko":
                return .success(.kaskoReport)
            case "loyalty":
                return .success(.loyalty)
            case "property_prolongation":
                return .success(.propetryProlonagation)
            case "clinic_appointment":
                return .success(.clinicAppointment)
            case "doctor_call":
                return .success(.doctorCall)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .isurance:
                return transformer.transform(destination: "insurance")
            case .offlineAppointment:
                return transformer.transform(destination: "dms_appointment_offline_mw")
            case .onlineAppointment:
                return transformer.transform(destination: "dms_appointment_online")
            case .url:
                return transformer.transform(destination: "url")
            case .telemed:
                return transformer.transform(destination: "telemed")
            case .osagoReport:
                return transformer.transform(destination: "event_report_osago")
            case .kaskoReport:
                return transformer.transform(destination: "event_report_kasko")
            case .loyalty:
                return transformer.transform(destination: "loyalty")
            case .propetryProlonagation:
                return transformer.transform(destination: "property_prolongation")
            case .clinicAppointment:
                return transformer.transform(destination: "clinic_appointment")
            case .doctorCall:
                return transformer.transform(destination: "doctor_call")
        }
    }
}
