// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryData

    let instructionName = "plan_info"
    let applicantPersonalInfoName = "insurer"
    let insuredPersonsName = "insured_list"
    let medicalServicesName = "medical_service_list"
    let currenciesName = "currency_list"
    let popularBanksName = "popular_bank_list"
    let documentsInfoName = "files_info"
    let passportName = "passport"
    let requisitesName = "refund_requisites"
    let additionalInfoName = "additional_personal_info"

    let instructionTransformer = DmsCostRecoveryInstructionTransformer()
    let applicantPersonalInfoTransformer = DmsCostRecoveryApplicantPersonalInfoTransformer()
    let insuredPersonsTransformer = ArrayTransformer(from: Any.self, transformer: DmsCostRecoveryInsuredPersonTransformer(), skipFailures: true)
    let medicalServicesTransformer = ArrayTransformer(from: Any.self, transformer: DmsCostRecoveryMedicalServiceTransformer(), skipFailures: true)
    let currenciesTransformer = ArrayTransformer(from: Any.self, transformer: DmsCostRecoveryCurrencyTransformer(), skipFailures: true)
    let popularBanksTransformer = ArrayTransformer(from: Any.self, transformer: DmsCostRecoveryBankTransformer(), skipFailures: true)
    let documentsInfoTransformer = DmsCostRecoveryDocumentsInfoTransformer()
    let passportTransformer = OptionalTransformer(transformer: DmsCostRecoveryPassportTransformer())
    let requisitesTransformer = OptionalTransformer(transformer: DmsCostRecoveryRequisitesTransformer())
    let additionalInfoTransformer = OptionalTransformer(transformer: DmsCostRecoveryAdditionalInfoTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let instructionResult = dictionary[instructionName].map(instructionTransformer.transform(source:)) ?? .failure(.requirement)
        let applicantPersonalInfoResult = dictionary[applicantPersonalInfoName].map(applicantPersonalInfoTransformer.transform(source:)) ?? .failure(.requirement)
        let insuredPersonsResult = dictionary[insuredPersonsName].map(insuredPersonsTransformer.transform(source:)) ?? .failure(.requirement)
        let medicalServicesResult = dictionary[medicalServicesName].map(medicalServicesTransformer.transform(source:)) ?? .failure(.requirement)
        let currenciesResult = dictionary[currenciesName].map(currenciesTransformer.transform(source:)) ?? .failure(.requirement)
        let popularBanksResult = dictionary[popularBanksName].map(popularBanksTransformer.transform(source:)) ?? .failure(.requirement)
        let documentsInfoResult = dictionary[documentsInfoName].map(documentsInfoTransformer.transform(source:)) ?? .failure(.requirement)
        let passportResult = passportTransformer.transform(source: dictionary[passportName])
        let requisitesResult = requisitesTransformer.transform(source: dictionary[requisitesName])
        let additionalInfoResult = additionalInfoTransformer.transform(source: dictionary[additionalInfoName])

        var errors: [(String, TransformerError)] = []
        instructionResult.error.map { errors.append((instructionName, $0)) }
        applicantPersonalInfoResult.error.map { errors.append((applicantPersonalInfoName, $0)) }
        insuredPersonsResult.error.map { errors.append((insuredPersonsName, $0)) }
        medicalServicesResult.error.map { errors.append((medicalServicesName, $0)) }
        currenciesResult.error.map { errors.append((currenciesName, $0)) }
        popularBanksResult.error.map { errors.append((popularBanksName, $0)) }
        documentsInfoResult.error.map { errors.append((documentsInfoName, $0)) }
        passportResult.error.map { errors.append((passportName, $0)) }
        requisitesResult.error.map { errors.append((requisitesName, $0)) }
        additionalInfoResult.error.map { errors.append((additionalInfoName, $0)) }

        guard
            let instruction = instructionResult.value,
            let applicantPersonalInfo = applicantPersonalInfoResult.value,
            let insuredPersons = insuredPersonsResult.value,
            let medicalServices = medicalServicesResult.value,
            let currencies = currenciesResult.value,
            let popularBanks = popularBanksResult.value,
            let documentsInfo = documentsInfoResult.value,
            let passport = passportResult.value,
            let requisites = requisitesResult.value,
            let additionalInfo = additionalInfoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                instruction: instruction,
                applicantPersonalInfo: applicantPersonalInfo,
                insuredPersons: insuredPersons,
                medicalServices: medicalServices,
                currencies: currencies,
                popularBanks: popularBanks,
                documentsInfo: documentsInfo,
                passport: passport,
                requisites: requisites,
                additionalInfo: additionalInfo
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let instructionResult = instructionTransformer.transform(destination: value.instruction)
        let applicantPersonalInfoResult = applicantPersonalInfoTransformer.transform(destination: value.applicantPersonalInfo)
        let insuredPersonsResult = insuredPersonsTransformer.transform(destination: value.insuredPersons)
        let medicalServicesResult = medicalServicesTransformer.transform(destination: value.medicalServices)
        let currenciesResult = currenciesTransformer.transform(destination: value.currencies)
        let popularBanksResult = popularBanksTransformer.transform(destination: value.popularBanks)
        let documentsInfoResult = documentsInfoTransformer.transform(destination: value.documentsInfo)
        let passportResult = passportTransformer.transform(destination: value.passport)
        let requisitesResult = requisitesTransformer.transform(destination: value.requisites)
        let additionalInfoResult = additionalInfoTransformer.transform(destination: value.additionalInfo)

        var errors: [(String, TransformerError)] = []
        instructionResult.error.map { errors.append((instructionName, $0)) }
        applicantPersonalInfoResult.error.map { errors.append((applicantPersonalInfoName, $0)) }
        insuredPersonsResult.error.map { errors.append((insuredPersonsName, $0)) }
        medicalServicesResult.error.map { errors.append((medicalServicesName, $0)) }
        currenciesResult.error.map { errors.append((currenciesName, $0)) }
        popularBanksResult.error.map { errors.append((popularBanksName, $0)) }
        documentsInfoResult.error.map { errors.append((documentsInfoName, $0)) }
        passportResult.error.map { errors.append((passportName, $0)) }
        requisitesResult.error.map { errors.append((requisitesName, $0)) }
        additionalInfoResult.error.map { errors.append((additionalInfoName, $0)) }

        guard
            let instruction = instructionResult.value,
            let applicantPersonalInfo = applicantPersonalInfoResult.value,
            let insuredPersons = insuredPersonsResult.value,
            let medicalServices = medicalServicesResult.value,
            let currencies = currenciesResult.value,
            let popularBanks = popularBanksResult.value,
            let documentsInfo = documentsInfoResult.value,
            let passport = passportResult.value,
            let requisites = requisitesResult.value,
            let additionalInfo = additionalInfoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[instructionName] = instruction
        dictionary[applicantPersonalInfoName] = applicantPersonalInfo
        dictionary[insuredPersonsName] = insuredPersons
        dictionary[medicalServicesName] = medicalServices
        dictionary[currenciesName] = currencies
        dictionary[popularBanksName] = popularBanks
        dictionary[documentsInfoName] = documentsInfo
        dictionary[passportName] = passport
        dictionary[requisitesName] = requisites
        dictionary[additionalInfoName] = additionalInfo
        return .success(dictionary)
    }
}
