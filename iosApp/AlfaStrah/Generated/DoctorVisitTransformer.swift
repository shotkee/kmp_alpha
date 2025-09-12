// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DoctorVisitTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorVisit

    let idName = "id"
    let clinicName = "clinic"
    let doctorName = "doctor"
    let doctorScheduleIntervalName = "interval"
    let insuranceIdName = "insurance_id"
    let alertMessageName = "alert"
    let statusName = "status"

    let idTransformer = IdTransformer<Any>()
    let clinicTransformer = OptionalTransformer(transformer: ClinicTransformer())
    let doctorTransformer = ShortDoctorTransformer()
    let doctorScheduleIntervalTransformer = DoctorScheduleIntervalTransformer()
    let insuranceIdTransformer = CastTransformer<Any, String>()
    let alertMessageTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let statusTransformer = OptionalTransformer(transformer: AppointmentStatusTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicResult = clinicTransformer.transform(source: dictionary[clinicName])
        let doctorResult = dictionary[doctorName].map(doctorTransformer.transform(source:)) ?? .failure(.requirement)
        let doctorScheduleIntervalResult = dictionary[doctorScheduleIntervalName].map(doctorScheduleIntervalTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let alertMessageResult = alertMessageTransformer.transform(source: dictionary[alertMessageName])
        let statusResult = statusTransformer.transform(source: dictionary[statusName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        clinicResult.error.map { errors.append((clinicName, $0)) }
        doctorResult.error.map { errors.append((doctorName, $0)) }
        doctorScheduleIntervalResult.error.map { errors.append((doctorScheduleIntervalName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        alertMessageResult.error.map { errors.append((alertMessageName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let clinic = clinicResult.value,
            let doctor = doctorResult.value,
            let doctorScheduleInterval = doctorScheduleIntervalResult.value,
            let insuranceId = insuranceIdResult.value,
            let alertMessage = alertMessageResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                clinic: clinic,
                doctor: doctor,
                doctorScheduleInterval: doctorScheduleInterval,
                insuranceId: insuranceId,
                alertMessage: alertMessage,
                status: status
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let clinicResult = clinicTransformer.transform(destination: value.clinic)
        let doctorResult = doctorTransformer.transform(destination: value.doctor)
        let doctorScheduleIntervalResult = doctorScheduleIntervalTransformer.transform(destination: value.doctorScheduleInterval)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let alertMessageResult = alertMessageTransformer.transform(destination: value.alertMessage)
        let statusResult = statusTransformer.transform(destination: value.status)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        clinicResult.error.map { errors.append((clinicName, $0)) }
        doctorResult.error.map { errors.append((doctorName, $0)) }
        doctorScheduleIntervalResult.error.map { errors.append((doctorScheduleIntervalName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        alertMessageResult.error.map { errors.append((alertMessageName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let clinic = clinicResult.value,
            let doctor = doctorResult.value,
            let doctorScheduleInterval = doctorScheduleIntervalResult.value,
            let insuranceId = insuranceIdResult.value,
            let alertMessage = alertMessageResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[clinicName] = clinic
        dictionary[doctorName] = doctor
        dictionary[doctorScheduleIntervalName] = doctorScheduleInterval
        dictionary[insuranceIdName] = insuranceId
        dictionary[alertMessageName] = alertMessage
        dictionary[statusName] = status
        return .success(dictionary)
    }
}
