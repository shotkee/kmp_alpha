// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfflineAppointmentRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OfflineAppointmentRequest

    let phoneName = "phone"
    let reasonName = "reason_text"
    let clinicIdName = "clinic_id"
    let insuranceIdName = "insurance_id"
    let datesName = "dates"
    let clinicSpecialityIdName = "clinic_speciality_id"
    let userInputForClinicSpecialityName = "user_input"
    let disclaimerAnswerName = "disclaimer_answer"

    let phoneTransformer = PhoneTransformer()
    let reasonTransformer = CastTransformer<Any, String>()
    let clinicIdTransformer = CastTransformer<Any, String>()
    let insuranceIdTransformer = CastTransformer<Any, String>()
    let datesTransformer = ArrayTransformer(from: Any.self, transformer: OfflineAppointmentDateTransformer(), skipFailures: true)
    let clinicSpecialityIdTransformer = NumberTransformer<Any, Int>()
    let userInputForClinicSpecialityTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let disclaimerAnswerTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let reasonResult = dictionary[reasonName].map(reasonTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicIdResult = dictionary[clinicIdName].map(clinicIdTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let datesResult = dictionary[datesName].map(datesTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicSpecialityIdResult = dictionary[clinicSpecialityIdName].map(clinicSpecialityIdTransformer.transform(source:)) ?? .failure(.requirement)
        let userInputForClinicSpecialityResult = userInputForClinicSpecialityTransformer.transform(source: dictionary[userInputForClinicSpecialityName])
        let disclaimerAnswerResult = disclaimerAnswerTransformer.transform(source: dictionary[disclaimerAnswerName])

        var errors: [(String, TransformerError)] = []
        phoneResult.error.map { errors.append((phoneName, $0)) }
        reasonResult.error.map { errors.append((reasonName, $0)) }
        clinicIdResult.error.map { errors.append((clinicIdName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        datesResult.error.map { errors.append((datesName, $0)) }
        clinicSpecialityIdResult.error.map { errors.append((clinicSpecialityIdName, $0)) }
        userInputForClinicSpecialityResult.error.map { errors.append((userInputForClinicSpecialityName, $0)) }
        disclaimerAnswerResult.error.map { errors.append((disclaimerAnswerName, $0)) }

        guard
            let phone = phoneResult.value,
            let reason = reasonResult.value,
            let clinicId = clinicIdResult.value,
            let insuranceId = insuranceIdResult.value,
            let dates = datesResult.value,
            let clinicSpecialityId = clinicSpecialityIdResult.value,
            let userInputForClinicSpeciality = userInputForClinicSpecialityResult.value,
            let disclaimerAnswer = disclaimerAnswerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                phone: phone,
                reason: reason,
                clinicId: clinicId,
                insuranceId: insuranceId,
                dates: dates,
                clinicSpecialityId: clinicSpecialityId,
                userInputForClinicSpeciality: userInputForClinicSpeciality,
                disclaimerAnswer: disclaimerAnswer
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let reasonResult = reasonTransformer.transform(destination: value.reason)
        let clinicIdResult = clinicIdTransformer.transform(destination: value.clinicId)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let datesResult = datesTransformer.transform(destination: value.dates)
        let clinicSpecialityIdResult = clinicSpecialityIdTransformer.transform(destination: value.clinicSpecialityId)
        let userInputForClinicSpecialityResult = userInputForClinicSpecialityTransformer.transform(destination: value.userInputForClinicSpeciality)
        let disclaimerAnswerResult = disclaimerAnswerTransformer.transform(destination: value.disclaimerAnswer)

        var errors: [(String, TransformerError)] = []
        phoneResult.error.map { errors.append((phoneName, $0)) }
        reasonResult.error.map { errors.append((reasonName, $0)) }
        clinicIdResult.error.map { errors.append((clinicIdName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        datesResult.error.map { errors.append((datesName, $0)) }
        clinicSpecialityIdResult.error.map { errors.append((clinicSpecialityIdName, $0)) }
        userInputForClinicSpecialityResult.error.map { errors.append((userInputForClinicSpecialityName, $0)) }
        disclaimerAnswerResult.error.map { errors.append((disclaimerAnswerName, $0)) }

        guard
            let phone = phoneResult.value,
            let reason = reasonResult.value,
            let clinicId = clinicIdResult.value,
            let insuranceId = insuranceIdResult.value,
            let dates = datesResult.value,
            let clinicSpecialityId = clinicSpecialityIdResult.value,
            let userInputForClinicSpeciality = userInputForClinicSpecialityResult.value,
            let disclaimerAnswer = disclaimerAnswerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[phoneName] = phone
        dictionary[reasonName] = reason
        dictionary[clinicIdName] = clinicId
        dictionary[insuranceIdName] = insuranceId
        dictionary[datesName] = dates
        dictionary[clinicSpecialityIdName] = clinicSpecialityId
        dictionary[userInputForClinicSpecialityName] = userInputForClinicSpeciality
        dictionary[disclaimerAnswerName] = disclaimerAnswer
        return .success(dictionary)
    }
}
