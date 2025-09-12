// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DoctorAppointmentRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorAppointmentRequest

    let insuranceIdName = "insurance_id"
    let userFullameName = "full_name_insured"
    let symptomsName = "reason"
    let userPhoneName = "contact_phone"
    let userAddressName = "address"
    let doctorSpecialityName = "specialist"
    let distanceTypeName = "distance_type"
    let medicalLeaveIsRequiredTitleName = "sick_leave_required"
    let visitDateName = "visit_date"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let userFullameTransformer = CastTransformer<Any, String>()
    let symptomsTransformer = CastTransformer<Any, String>()
    let userPhoneTransformer = CastTransformer<Any, String>()
    let userAddressTransformer = CastTransformer<Any, String>()
    let doctorSpecialityTransformer = CastTransformer<Any, String>()
    let distanceTypeTransformer = CastTransformer<Any, String>()
    let medicalLeaveIsRequiredTitleTransformer = CastTransformer<Any, String>()
    let visitDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let userFullameResult = dictionary[userFullameName].map(userFullameTransformer.transform(source:)) ?? .failure(.requirement)
        let symptomsResult = dictionary[symptomsName].map(symptomsTransformer.transform(source:)) ?? .failure(.requirement)
        let userPhoneResult = dictionary[userPhoneName].map(userPhoneTransformer.transform(source:)) ?? .failure(.requirement)
        let userAddressResult = dictionary[userAddressName].map(userAddressTransformer.transform(source:)) ?? .failure(.requirement)
        let doctorSpecialityResult = dictionary[doctorSpecialityName].map(doctorSpecialityTransformer.transform(source:)) ?? .failure(.requirement)
        let distanceTypeResult = dictionary[distanceTypeName].map(distanceTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let medicalLeaveIsRequiredTitleResult = dictionary[medicalLeaveIsRequiredTitleName].map(medicalLeaveIsRequiredTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let visitDateResult = dictionary[visitDateName].map(visitDateTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        userFullameResult.error.map { errors.append((userFullameName, $0)) }
        symptomsResult.error.map { errors.append((symptomsName, $0)) }
        userPhoneResult.error.map { errors.append((userPhoneName, $0)) }
        userAddressResult.error.map { errors.append((userAddressName, $0)) }
        doctorSpecialityResult.error.map { errors.append((doctorSpecialityName, $0)) }
        distanceTypeResult.error.map { errors.append((distanceTypeName, $0)) }
        medicalLeaveIsRequiredTitleResult.error.map { errors.append((medicalLeaveIsRequiredTitleName, $0)) }
        visitDateResult.error.map { errors.append((visitDateName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let userFullame = userFullameResult.value,
            let symptoms = symptomsResult.value,
            let userPhone = userPhoneResult.value,
            let userAddress = userAddressResult.value,
            let doctorSpeciality = doctorSpecialityResult.value,
            let distanceType = distanceTypeResult.value,
            let medicalLeaveIsRequiredTitle = medicalLeaveIsRequiredTitleResult.value,
            let visitDate = visitDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                userFullame: userFullame,
                symptoms: symptoms,
                userPhone: userPhone,
                userAddress: userAddress,
                doctorSpeciality: doctorSpeciality,
                distanceType: distanceType,
                medicalLeaveIsRequiredTitle: medicalLeaveIsRequiredTitle,
                visitDate: visitDate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let userFullameResult = userFullameTransformer.transform(destination: value.userFullame)
        let symptomsResult = symptomsTransformer.transform(destination: value.symptoms)
        let userPhoneResult = userPhoneTransformer.transform(destination: value.userPhone)
        let userAddressResult = userAddressTransformer.transform(destination: value.userAddress)
        let doctorSpecialityResult = doctorSpecialityTransformer.transform(destination: value.doctorSpeciality)
        let distanceTypeResult = distanceTypeTransformer.transform(destination: value.distanceType)
        let medicalLeaveIsRequiredTitleResult = medicalLeaveIsRequiredTitleTransformer.transform(destination: value.medicalLeaveIsRequiredTitle)
        let visitDateResult = visitDateTransformer.transform(destination: value.visitDate)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        userFullameResult.error.map { errors.append((userFullameName, $0)) }
        symptomsResult.error.map { errors.append((symptomsName, $0)) }
        userPhoneResult.error.map { errors.append((userPhoneName, $0)) }
        userAddressResult.error.map { errors.append((userAddressName, $0)) }
        doctorSpecialityResult.error.map { errors.append((doctorSpecialityName, $0)) }
        distanceTypeResult.error.map { errors.append((distanceTypeName, $0)) }
        medicalLeaveIsRequiredTitleResult.error.map { errors.append((medicalLeaveIsRequiredTitleName, $0)) }
        visitDateResult.error.map { errors.append((visitDateName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let userFullame = userFullameResult.value,
            let symptoms = symptomsResult.value,
            let userPhone = userPhoneResult.value,
            let userAddress = userAddressResult.value,
            let doctorSpeciality = doctorSpecialityResult.value,
            let distanceType = distanceTypeResult.value,
            let medicalLeaveIsRequiredTitle = medicalLeaveIsRequiredTitleResult.value,
            let visitDate = visitDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[userFullameName] = userFullame
        dictionary[symptomsName] = symptoms
        dictionary[userPhoneName] = userPhone
        dictionary[userAddressName] = userAddress
        dictionary[doctorSpecialityName] = doctorSpeciality
        dictionary[distanceTypeName] = distanceType
        dictionary[medicalLeaveIsRequiredTitleName] = medicalLeaveIsRequiredTitle
        dictionary[visitDateName] = visitDate
        return .success(dictionary)
    }
}
