// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BackendDoctorCallTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendDoctorCall

    let forChildName = "is_child"
    let childDoctorBannerName = "child_popup_data"
    let userFullnameName = "full_name_insured"
    let userPhoneNumberName = "contact_phone"
    let doctorSpecialityName = "specialist"
    let distanceTypeName = "distance_type"
    let distanceTitleName = "distance_title"
    let medicalLeaveIsRequiredTitleName = "sick_leave_required"
    let visitDatesName = "visit_date_list"
    let additionalInfoName = "call_information"

    let forChildTransformer = NumberTransformer<Any, Bool>()
    let childDoctorBannerTransformer = OptionalTransformer(transformer: BackendBannerDataTransformer())
    let userFullnameTransformer = CastTransformer<Any, String>()
    let userPhoneNumberTransformer = CastTransformer<Any, String>()
    let doctorSpecialityTransformer = CastTransformer<Any, String>()
    let distanceTypeTransformer = CastTransformer<Any, String>()
    let distanceTitleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let medicalLeaveIsRequiredTitleTransformer = CastTransformer<Any, String>()
    let visitDatesTransformer = ArrayTransformer(from: Any.self, transformer: BackendVisitDateTransformer(), skipFailures: true)
    let additionalInfoTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let forChildResult = dictionary[forChildName].map(forChildTransformer.transform(source:)) ?? .failure(.requirement)
        let childDoctorBannerResult = childDoctorBannerTransformer.transform(source: dictionary[childDoctorBannerName])
        let userFullnameResult = dictionary[userFullnameName].map(userFullnameTransformer.transform(source:)) ?? .failure(.requirement)
        let userPhoneNumberResult = dictionary[userPhoneNumberName].map(userPhoneNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let doctorSpecialityResult = dictionary[doctorSpecialityName].map(doctorSpecialityTransformer.transform(source:)) ?? .failure(.requirement)
        let distanceTypeResult = dictionary[distanceTypeName].map(distanceTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let distanceTitleResult = distanceTitleTransformer.transform(source: dictionary[distanceTitleName])
        let medicalLeaveIsRequiredTitleResult = dictionary[medicalLeaveIsRequiredTitleName].map(medicalLeaveIsRequiredTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let visitDatesResult = dictionary[visitDatesName].map(visitDatesTransformer.transform(source:)) ?? .failure(.requirement)
        let additionalInfoResult = additionalInfoTransformer.transform(source: dictionary[additionalInfoName])

        var errors: [(String, TransformerError)] = []
        forChildResult.error.map { errors.append((forChildName, $0)) }
        childDoctorBannerResult.error.map { errors.append((childDoctorBannerName, $0)) }
        userFullnameResult.error.map { errors.append((userFullnameName, $0)) }
        userPhoneNumberResult.error.map { errors.append((userPhoneNumberName, $0)) }
        doctorSpecialityResult.error.map { errors.append((doctorSpecialityName, $0)) }
        distanceTypeResult.error.map { errors.append((distanceTypeName, $0)) }
        distanceTitleResult.error.map { errors.append((distanceTitleName, $0)) }
        medicalLeaveIsRequiredTitleResult.error.map { errors.append((medicalLeaveIsRequiredTitleName, $0)) }
        visitDatesResult.error.map { errors.append((visitDatesName, $0)) }
        additionalInfoResult.error.map { errors.append((additionalInfoName, $0)) }

        guard
            let forChild = forChildResult.value,
            let childDoctorBanner = childDoctorBannerResult.value,
            let userFullname = userFullnameResult.value,
            let userPhoneNumber = userPhoneNumberResult.value,
            let doctorSpeciality = doctorSpecialityResult.value,
            let distanceType = distanceTypeResult.value,
            let distanceTitle = distanceTitleResult.value,
            let medicalLeaveIsRequiredTitle = medicalLeaveIsRequiredTitleResult.value,
            let visitDates = visitDatesResult.value,
            let additionalInfo = additionalInfoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                forChild: forChild,
                childDoctorBanner: childDoctorBanner,
                userFullname: userFullname,
                userPhoneNumber: userPhoneNumber,
                doctorSpeciality: doctorSpeciality,
                distanceType: distanceType,
                distanceTitle: distanceTitle,
                medicalLeaveIsRequiredTitle: medicalLeaveIsRequiredTitle,
                visitDates: visitDates,
                additionalInfo: additionalInfo
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let forChildResult = forChildTransformer.transform(destination: value.forChild)
        let childDoctorBannerResult = childDoctorBannerTransformer.transform(destination: value.childDoctorBanner)
        let userFullnameResult = userFullnameTransformer.transform(destination: value.userFullname)
        let userPhoneNumberResult = userPhoneNumberTransformer.transform(destination: value.userPhoneNumber)
        let doctorSpecialityResult = doctorSpecialityTransformer.transform(destination: value.doctorSpeciality)
        let distanceTypeResult = distanceTypeTransformer.transform(destination: value.distanceType)
        let distanceTitleResult = distanceTitleTransformer.transform(destination: value.distanceTitle)
        let medicalLeaveIsRequiredTitleResult = medicalLeaveIsRequiredTitleTransformer.transform(destination: value.medicalLeaveIsRequiredTitle)
        let visitDatesResult = visitDatesTransformer.transform(destination: value.visitDates)
        let additionalInfoResult = additionalInfoTransformer.transform(destination: value.additionalInfo)

        var errors: [(String, TransformerError)] = []
        forChildResult.error.map { errors.append((forChildName, $0)) }
        childDoctorBannerResult.error.map { errors.append((childDoctorBannerName, $0)) }
        userFullnameResult.error.map { errors.append((userFullnameName, $0)) }
        userPhoneNumberResult.error.map { errors.append((userPhoneNumberName, $0)) }
        doctorSpecialityResult.error.map { errors.append((doctorSpecialityName, $0)) }
        distanceTypeResult.error.map { errors.append((distanceTypeName, $0)) }
        distanceTitleResult.error.map { errors.append((distanceTitleName, $0)) }
        medicalLeaveIsRequiredTitleResult.error.map { errors.append((medicalLeaveIsRequiredTitleName, $0)) }
        visitDatesResult.error.map { errors.append((visitDatesName, $0)) }
        additionalInfoResult.error.map { errors.append((additionalInfoName, $0)) }

        guard
            let forChild = forChildResult.value,
            let childDoctorBanner = childDoctorBannerResult.value,
            let userFullname = userFullnameResult.value,
            let userPhoneNumber = userPhoneNumberResult.value,
            let doctorSpeciality = doctorSpecialityResult.value,
            let distanceType = distanceTypeResult.value,
            let distanceTitle = distanceTitleResult.value,
            let medicalLeaveIsRequiredTitle = medicalLeaveIsRequiredTitleResult.value,
            let visitDates = visitDatesResult.value,
            let additionalInfo = additionalInfoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[forChildName] = forChild
        dictionary[childDoctorBannerName] = childDoctorBanner
        dictionary[userFullnameName] = userFullname
        dictionary[userPhoneNumberName] = userPhoneNumber
        dictionary[doctorSpecialityName] = doctorSpeciality
        dictionary[distanceTypeName] = distanceType
        dictionary[distanceTitleName] = distanceTitle
        dictionary[medicalLeaveIsRequiredTitleName] = medicalLeaveIsRequiredTitle
        dictionary[visitDatesName] = visitDates
        dictionary[additionalInfoName] = additionalInfo
        return .success(dictionary)
    }
}
