// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryApplicationRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryApplicationRequest

    let applicantPersonalInfoName = "insurer"
    let passportName = "passport"
    let requisitesName = "refund_requisites"
    let additionalInfoName = "additional_personal_info"
    let insuredPersonInfoName = "insured"
    let insuranceEventInfoName = "additional_service_info"

    let applicantPersonalInfoTransformer = DmsCostRecoveryApplicantPersonalInfoTransformer()
    let passportTransformer = DmsCostRecoveryPassportTransformer()
    let requisitesTransformer = DmsCostRecoveryRequisitesTransformer()
    let additionalInfoTransformer = DmsCostRecoveryAdditionalInfoTransformer()
    let insuredPersonInfoTransformer = DmsCostRecoveryInsuredPersonTransformer()
    let insuranceEventInfoTransformer = DmsCostRecoveryInsuranceEventApplicationInfoTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let applicantPersonalInfoResult = dictionary[applicantPersonalInfoName].map(applicantPersonalInfoTransformer.transform(source:)) ?? .failure(.requirement)
        let passportResult = dictionary[passportName].map(passportTransformer.transform(source:)) ?? .failure(.requirement)
        let requisitesResult = dictionary[requisitesName].map(requisitesTransformer.transform(source:)) ?? .failure(.requirement)
        let additionalInfoResult = dictionary[additionalInfoName].map(additionalInfoTransformer.transform(source:)) ?? .failure(.requirement)
        let insuredPersonInfoResult = dictionary[insuredPersonInfoName].map(insuredPersonInfoTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceEventInfoResult = dictionary[insuranceEventInfoName].map(insuranceEventInfoTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        applicantPersonalInfoResult.error.map { errors.append((applicantPersonalInfoName, $0)) }
        passportResult.error.map { errors.append((passportName, $0)) }
        requisitesResult.error.map { errors.append((requisitesName, $0)) }
        additionalInfoResult.error.map { errors.append((additionalInfoName, $0)) }
        insuredPersonInfoResult.error.map { errors.append((insuredPersonInfoName, $0)) }
        insuranceEventInfoResult.error.map { errors.append((insuranceEventInfoName, $0)) }

        guard
            let applicantPersonalInfo = applicantPersonalInfoResult.value,
            let passport = passportResult.value,
            let requisites = requisitesResult.value,
            let additionalInfo = additionalInfoResult.value,
            let insuredPersonInfo = insuredPersonInfoResult.value,
            let insuranceEventInfo = insuranceEventInfoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                applicantPersonalInfo: applicantPersonalInfo,
                passport: passport,
                requisites: requisites,
                additionalInfo: additionalInfo,
                insuredPersonInfo: insuredPersonInfo,
                insuranceEventInfo: insuranceEventInfo
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let applicantPersonalInfoResult = applicantPersonalInfoTransformer.transform(destination: value.applicantPersonalInfo)
        let passportResult = passportTransformer.transform(destination: value.passport)
        let requisitesResult = requisitesTransformer.transform(destination: value.requisites)
        let additionalInfoResult = additionalInfoTransformer.transform(destination: value.additionalInfo)
        let insuredPersonInfoResult = insuredPersonInfoTransformer.transform(destination: value.insuredPersonInfo)
        let insuranceEventInfoResult = insuranceEventInfoTransformer.transform(destination: value.insuranceEventInfo)

        var errors: [(String, TransformerError)] = []
        applicantPersonalInfoResult.error.map { errors.append((applicantPersonalInfoName, $0)) }
        passportResult.error.map { errors.append((passportName, $0)) }
        requisitesResult.error.map { errors.append((requisitesName, $0)) }
        additionalInfoResult.error.map { errors.append((additionalInfoName, $0)) }
        insuredPersonInfoResult.error.map { errors.append((insuredPersonInfoName, $0)) }
        insuranceEventInfoResult.error.map { errors.append((insuranceEventInfoName, $0)) }

        guard
            let applicantPersonalInfo = applicantPersonalInfoResult.value,
            let passport = passportResult.value,
            let requisites = requisitesResult.value,
            let additionalInfo = additionalInfoResult.value,
            let insuredPersonInfo = insuredPersonInfoResult.value,
            let insuranceEventInfo = insuranceEventInfoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[applicantPersonalInfoName] = applicantPersonalInfo
        dictionary[passportName] = passport
        dictionary[requisitesName] = requisites
        dictionary[additionalInfoName] = additionalInfo
        dictionary[insuredPersonInfoName] = insuredPersonInfo
        dictionary[insuranceEventInfoName] = insuranceEventInfo
        return .success(dictionary)
    }
}
