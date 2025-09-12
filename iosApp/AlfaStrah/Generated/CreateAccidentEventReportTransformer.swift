// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CreateAccidentEventReportTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CreateAccidentEventReport

    let insuranceIdName = "insurance_id"
    let fullDescriptionName = "full_description"
    let documentCountName = "document_count"
    let claimDateName = "claim_date"
    let timezoneName = "timezone"
    let beneficiaryName = "beneficiary"
    let passportSeriaName = "passport_seria"
    let passportNumberName = "passport_number"
    let bikName = "bik"
    let accountNumberName = "account_number"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let fullDescriptionTransformer = CastTransformer<Any, String>()
    let documentCountTransformer = NumberTransformer<Any, Int>()
    let claimDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let timezoneTransformer = DateTransformer<Any>(format: "xxx", locale: AppLocale.currentLocale)
    let beneficiaryTransformer = CastTransformer<Any, String>()
    let passportSeriaTransformer = CastTransformer<Any, String>()
    let passportNumberTransformer = CastTransformer<Any, String>()
    let bikTransformer = CastTransformer<Any, String>()
    let accountNumberTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let fullDescriptionResult = dictionary[fullDescriptionName].map(fullDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let documentCountResult = dictionary[documentCountName].map(documentCountTransformer.transform(source:)) ?? .failure(.requirement)
        let claimDateResult = dictionary[claimDateName].map(claimDateTransformer.transform(source:)) ?? .failure(.requirement)
        let timezoneResult = dictionary[timezoneName].map(timezoneTransformer.transform(source:)) ?? .failure(.requirement)
        let beneficiaryResult = dictionary[beneficiaryName].map(beneficiaryTransformer.transform(source:)) ?? .failure(.requirement)
        let passportSeriaResult = dictionary[passportSeriaName].map(passportSeriaTransformer.transform(source:)) ?? .failure(.requirement)
        let passportNumberResult = dictionary[passportNumberName].map(passportNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let bikResult = dictionary[bikName].map(bikTransformer.transform(source:)) ?? .failure(.requirement)
        let accountNumberResult = dictionary[accountNumberName].map(accountNumberTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        documentCountResult.error.map { errors.append((documentCountName, $0)) }
        claimDateResult.error.map { errors.append((claimDateName, $0)) }
        timezoneResult.error.map { errors.append((timezoneName, $0)) }
        beneficiaryResult.error.map { errors.append((beneficiaryName, $0)) }
        passportSeriaResult.error.map { errors.append((passportSeriaName, $0)) }
        passportNumberResult.error.map { errors.append((passportNumberName, $0)) }
        bikResult.error.map { errors.append((bikName, $0)) }
        accountNumberResult.error.map { errors.append((accountNumberName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let fullDescription = fullDescriptionResult.value,
            let documentCount = documentCountResult.value,
            let claimDate = claimDateResult.value,
            let timezone = timezoneResult.value,
            let beneficiary = beneficiaryResult.value,
            let passportSeria = passportSeriaResult.value,
            let passportNumber = passportNumberResult.value,
            let bik = bikResult.value,
            let accountNumber = accountNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                fullDescription: fullDescription,
                documentCount: documentCount,
                claimDate: claimDate,
                timezone: timezone,
                beneficiary: beneficiary,
                passportSeria: passportSeria,
                passportNumber: passportNumber,
                bik: bik,
                accountNumber: accountNumber
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let fullDescriptionResult = fullDescriptionTransformer.transform(destination: value.fullDescription)
        let documentCountResult = documentCountTransformer.transform(destination: value.documentCount)
        let claimDateResult = claimDateTransformer.transform(destination: value.claimDate)
        let timezoneResult = timezoneTransformer.transform(destination: value.timezone)
        let beneficiaryResult = beneficiaryTransformer.transform(destination: value.beneficiary)
        let passportSeriaResult = passportSeriaTransformer.transform(destination: value.passportSeria)
        let passportNumberResult = passportNumberTransformer.transform(destination: value.passportNumber)
        let bikResult = bikTransformer.transform(destination: value.bik)
        let accountNumberResult = accountNumberTransformer.transform(destination: value.accountNumber)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        documentCountResult.error.map { errors.append((documentCountName, $0)) }
        claimDateResult.error.map { errors.append((claimDateName, $0)) }
        timezoneResult.error.map { errors.append((timezoneName, $0)) }
        beneficiaryResult.error.map { errors.append((beneficiaryName, $0)) }
        passportSeriaResult.error.map { errors.append((passportSeriaName, $0)) }
        passportNumberResult.error.map { errors.append((passportNumberName, $0)) }
        bikResult.error.map { errors.append((bikName, $0)) }
        accountNumberResult.error.map { errors.append((accountNumberName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let fullDescription = fullDescriptionResult.value,
            let documentCount = documentCountResult.value,
            let claimDate = claimDateResult.value,
            let timezone = timezoneResult.value,
            let beneficiary = beneficiaryResult.value,
            let passportSeria = passportSeriaResult.value,
            let passportNumber = passportNumberResult.value,
            let bik = bikResult.value,
            let accountNumber = accountNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[fullDescriptionName] = fullDescription
        dictionary[documentCountName] = documentCount
        dictionary[claimDateName] = claimDate
        dictionary[timezoneName] = timezone
        dictionary[beneficiaryName] = beneficiary
        dictionary[passportSeriaName] = passportSeria
        dictionary[passportNumberName] = passportNumber
        dictionary[bikName] = bik
        dictionary[accountNumberName] = accountNumber
        return .success(dictionary)
    }
}
