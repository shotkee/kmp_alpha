// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfflineAppointmentRequestContainerTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OfflineAppointmentRequestContainer

    let offlineAppointmentRequestName = "appointment"
    let cancelingAppointmentAvisIdName = "cancel_appointment_avis_id"

    let offlineAppointmentRequestTransformer = OfflineAppointmentRequestTransformer()
    let cancelingAppointmentAvisIdTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let offlineAppointmentRequestResult = dictionary[offlineAppointmentRequestName].map(offlineAppointmentRequestTransformer.transform(source:)) ?? .failure(.requirement)
        let cancelingAppointmentAvisIdResult = cancelingAppointmentAvisIdTransformer.transform(source: dictionary[cancelingAppointmentAvisIdName])

        var errors: [(String, TransformerError)] = []
        offlineAppointmentRequestResult.error.map { errors.append((offlineAppointmentRequestName, $0)) }
        cancelingAppointmentAvisIdResult.error.map { errors.append((cancelingAppointmentAvisIdName, $0)) }

        guard
            let offlineAppointmentRequest = offlineAppointmentRequestResult.value,
            let cancelingAppointmentAvisId = cancelingAppointmentAvisIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                offlineAppointmentRequest: offlineAppointmentRequest,
                cancelingAppointmentAvisId: cancelingAppointmentAvisId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let offlineAppointmentRequestResult = offlineAppointmentRequestTransformer.transform(destination: value.offlineAppointmentRequest)
        let cancelingAppointmentAvisIdResult = cancelingAppointmentAvisIdTransformer.transform(destination: value.cancelingAppointmentAvisId)

        var errors: [(String, TransformerError)] = []
        offlineAppointmentRequestResult.error.map { errors.append((offlineAppointmentRequestName, $0)) }
        cancelingAppointmentAvisIdResult.error.map { errors.append((cancelingAppointmentAvisIdName, $0)) }

        guard
            let offlineAppointmentRequest = offlineAppointmentRequestResult.value,
            let cancelingAppointmentAvisId = cancelingAppointmentAvisIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[offlineAppointmentRequestName] = offlineAppointmentRequest
        dictionary[cancelingAppointmentAvisIdName] = cancelingAppointmentAvisId
        return .success(dictionary)
    }
}
