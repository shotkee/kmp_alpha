// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfflineAppointmentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OfflineAppointment

    let idName = "id"
    let appointmentNumberName = "avis_id"
    let phoneName = "phone"
    let dateName = "date"
    let reasonName = "reason_text"
    let clinicIdName = "clinic_id"
    let clinicName = "clinic"
    let insuranceIdName = "insurance_id"

    let idTransformer = IdTransformer<Any>()
    let appointmentNumberTransformer = CastTransformer<Any, String>()
    let phoneTransformer = PhoneTransformer()
    let dateTransformer = TimestampTransformer<Any>(scale: 1)
    let reasonTransformer = CastTransformer<Any, String>()
    let clinicIdTransformer = CastTransformer<Any, String>()
    let clinicTransformer = OptionalTransformer(transformer: ClinicTransformer())
    let insuranceIdTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let appointmentNumberResult = dictionary[appointmentNumberName].map(appointmentNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let reasonResult = dictionary[reasonName].map(reasonTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicIdResult = dictionary[clinicIdName].map(clinicIdTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicResult = clinicTransformer.transform(source: dictionary[clinicName])
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        appointmentNumberResult.error.map { errors.append((appointmentNumberName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        reasonResult.error.map { errors.append((reasonName, $0)) }
        clinicIdResult.error.map { errors.append((clinicIdName, $0)) }
        clinicResult.error.map { errors.append((clinicName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }

        guard
            let id = idResult.value,
            let appointmentNumber = appointmentNumberResult.value,
            let phone = phoneResult.value,
            let date = dateResult.value,
            let reason = reasonResult.value,
            let clinicId = clinicIdResult.value,
            let clinic = clinicResult.value,
            let insuranceId = insuranceIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                appointmentNumber: appointmentNumber,
                phone: phone,
                date: date,
                reason: reason,
                clinicId: clinicId,
                clinic: clinic,
                insuranceId: insuranceId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let appointmentNumberResult = appointmentNumberTransformer.transform(destination: value.appointmentNumber)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let dateResult = dateTransformer.transform(destination: value.date)
        let reasonResult = reasonTransformer.transform(destination: value.reason)
        let clinicIdResult = clinicIdTransformer.transform(destination: value.clinicId)
        let clinicResult = clinicTransformer.transform(destination: value.clinic)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        appointmentNumberResult.error.map { errors.append((appointmentNumberName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        reasonResult.error.map { errors.append((reasonName, $0)) }
        clinicIdResult.error.map { errors.append((clinicIdName, $0)) }
        clinicResult.error.map { errors.append((clinicName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }

        guard
            let id = idResult.value,
            let appointmentNumber = appointmentNumberResult.value,
            let phone = phoneResult.value,
            let date = dateResult.value,
            let reason = reasonResult.value,
            let clinicId = clinicIdResult.value,
            let clinic = clinicResult.value,
            let insuranceId = insuranceIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[appointmentNumberName] = appointmentNumber
        dictionary[phoneName] = phone
        dictionary[dateName] = date
        dictionary[reasonName] = reason
        dictionary[clinicIdName] = clinicId
        dictionary[clinicName] = clinic
        dictionary[insuranceIdName] = insuranceId
        return .success(dictionary)
    }
}
