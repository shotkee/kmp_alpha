// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DoctorCallBDUITransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorCallBDUI

    let userFullnameName = "fullNameInsured"
    let userPhoneNumberName = "contactPhone"
    let visitDatesName = "visitDateList"
    let doctorSpecialityName = "specialist"
    let distanceTypeName = "distanceType"
    let childDoctorBannerName = "childPopupData"
    let additionalInfoName = "callInformation"
    let forChildName = "isChild"
    let insuranceIdName = "insuranceId"
    let medicalLeaveAnswersName = "sickLeaveRequired"

    let userFullnameTransformer = CastTransformer<Any, String>()
    let userPhoneNumberTransformer = CastTransformer<Any, String>()
    let visitDatesTransformer = ArrayTransformer(from: Any.self, transformer: VisitDateBDUITransformer(), skipFailures: true)
    let doctorSpecialityTransformer = CastTransformer<Any, String>()
    let distanceTypeTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let childDoctorBannerTransformer = OptionalTransformer(transformer: BannerDataBDUITransformer())
    let additionalInfoTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let forChildTransformer = NumberTransformer<Any, Bool>()
    let insuranceIdTransformer = NumberTransformer<Any, Int>()
    let medicalLeaveAnswersTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let userFullnameResult = dictionary[userFullnameName].map(userFullnameTransformer.transform(source:)) ?? .failure(.requirement)
        let userPhoneNumberResult = dictionary[userPhoneNumberName].map(userPhoneNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let visitDatesResult = dictionary[visitDatesName].map(visitDatesTransformer.transform(source:)) ?? .failure(.requirement)
        let doctorSpecialityResult = dictionary[doctorSpecialityName].map(doctorSpecialityTransformer.transform(source:)) ?? .failure(.requirement)
        let distanceTypeResult = dictionary[distanceTypeName].map(distanceTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let childDoctorBannerResult = childDoctorBannerTransformer.transform(source: dictionary[childDoctorBannerName])
        let additionalInfoResult = additionalInfoTransformer.transform(source: dictionary[additionalInfoName])
        let forChildResult = dictionary[forChildName].map(forChildTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let medicalLeaveAnswersResult = dictionary[medicalLeaveAnswersName].map(medicalLeaveAnswersTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        userFullnameResult.error.map { errors.append((userFullnameName, $0)) }
        userPhoneNumberResult.error.map { errors.append((userPhoneNumberName, $0)) }
        visitDatesResult.error.map { errors.append((visitDatesName, $0)) }
        doctorSpecialityResult.error.map { errors.append((doctorSpecialityName, $0)) }
        distanceTypeResult.error.map { errors.append((distanceTypeName, $0)) }
        childDoctorBannerResult.error.map { errors.append((childDoctorBannerName, $0)) }
        additionalInfoResult.error.map { errors.append((additionalInfoName, $0)) }
        forChildResult.error.map { errors.append((forChildName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        medicalLeaveAnswersResult.error.map { errors.append((medicalLeaveAnswersName, $0)) }

        guard
            let userFullname = userFullnameResult.value,
            let userPhoneNumber = userPhoneNumberResult.value,
            let visitDates = visitDatesResult.value,
            let doctorSpeciality = doctorSpecialityResult.value,
            let distanceType = distanceTypeResult.value,
            let childDoctorBanner = childDoctorBannerResult.value,
            let additionalInfo = additionalInfoResult.value,
            let forChild = forChildResult.value,
            let insuranceId = insuranceIdResult.value,
            let medicalLeaveAnswers = medicalLeaveAnswersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                userFullname: userFullname,
                userPhoneNumber: userPhoneNumber,
                visitDates: visitDates,
                doctorSpeciality: doctorSpeciality,
                distanceType: distanceType,
                childDoctorBanner: childDoctorBanner,
                additionalInfo: additionalInfo,
                forChild: forChild,
                insuranceId: insuranceId,
                medicalLeaveAnswers: medicalLeaveAnswers
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let userFullnameResult = userFullnameTransformer.transform(destination: value.userFullname)
        let userPhoneNumberResult = userPhoneNumberTransformer.transform(destination: value.userPhoneNumber)
        let visitDatesResult = visitDatesTransformer.transform(destination: value.visitDates)
        let doctorSpecialityResult = doctorSpecialityTransformer.transform(destination: value.doctorSpeciality)
        let distanceTypeResult = distanceTypeTransformer.transform(destination: value.distanceType)
        let childDoctorBannerResult = childDoctorBannerTransformer.transform(destination: value.childDoctorBanner)
        let additionalInfoResult = additionalInfoTransformer.transform(destination: value.additionalInfo)
        let forChildResult = forChildTransformer.transform(destination: value.forChild)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let medicalLeaveAnswersResult = medicalLeaveAnswersTransformer.transform(destination: value.medicalLeaveAnswers)

        var errors: [(String, TransformerError)] = []
        userFullnameResult.error.map { errors.append((userFullnameName, $0)) }
        userPhoneNumberResult.error.map { errors.append((userPhoneNumberName, $0)) }
        visitDatesResult.error.map { errors.append((visitDatesName, $0)) }
        doctorSpecialityResult.error.map { errors.append((doctorSpecialityName, $0)) }
        distanceTypeResult.error.map { errors.append((distanceTypeName, $0)) }
        childDoctorBannerResult.error.map { errors.append((childDoctorBannerName, $0)) }
        additionalInfoResult.error.map { errors.append((additionalInfoName, $0)) }
        forChildResult.error.map { errors.append((forChildName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        medicalLeaveAnswersResult.error.map { errors.append((medicalLeaveAnswersName, $0)) }

        guard
            let userFullname = userFullnameResult.value,
            let userPhoneNumber = userPhoneNumberResult.value,
            let visitDates = visitDatesResult.value,
            let doctorSpeciality = doctorSpecialityResult.value,
            let distanceType = distanceTypeResult.value,
            let childDoctorBanner = childDoctorBannerResult.value,
            let additionalInfo = additionalInfoResult.value,
            let forChild = forChildResult.value,
            let insuranceId = insuranceIdResult.value,
            let medicalLeaveAnswers = medicalLeaveAnswersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[userFullnameName] = userFullname
        dictionary[userPhoneNumberName] = userPhoneNumber
        dictionary[visitDatesName] = visitDates
        dictionary[doctorSpecialityName] = doctorSpeciality
        dictionary[distanceTypeName] = distanceType
        dictionary[childDoctorBannerName] = childDoctorBanner
        dictionary[additionalInfoName] = additionalInfo
        dictionary[forChildName] = forChild
        dictionary[insuranceIdName] = insuranceId
        dictionary[medicalLeaveAnswersName] = medicalLeaveAnswers
        return .success(dictionary)
    }
}
