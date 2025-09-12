// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceParticipantTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceParticipant

    let fullNameName = "full_name"
    let firstNameName = "first_name"
    let lastNameName = "last_name"
    let patronymicName = "patronymic"
    let birthDateName = "birth_date_iso"
    let birthDateNonISOName = "birth_date"
    let sexName = "sex"
    let contactInformationName = "contact_information"
    let fullAddressName = "full_address"

    let fullNameTransformer = CastTransformer<Any, String>()
    let firstNameTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let lastNameTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let patronymicTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let birthDateTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale))
    let birthDateNonISOTransformer = OptionalTransformer(transformer: TimestampTransformer<Any>(scale: 1))
    let sexTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let contactInformationTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let fullAddressTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let fullNameResult = dictionary[fullNameName].map(fullNameTransformer.transform(source:)) ?? .failure(.requirement)
        let firstNameResult = firstNameTransformer.transform(source: dictionary[firstNameName])
        let lastNameResult = lastNameTransformer.transform(source: dictionary[lastNameName])
        let patronymicResult = patronymicTransformer.transform(source: dictionary[patronymicName])
        let birthDateResult = birthDateTransformer.transform(source: dictionary[birthDateName])
        let birthDateNonISOResult = birthDateNonISOTransformer.transform(source: dictionary[birthDateNonISOName])
        let sexResult = sexTransformer.transform(source: dictionary[sexName])
        let contactInformationResult = contactInformationTransformer.transform(source: dictionary[contactInformationName])
        let fullAddressResult = fullAddressTransformer.transform(source: dictionary[fullAddressName])

        var errors: [(String, TransformerError)] = []
        fullNameResult.error.map { errors.append((fullNameName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }
        birthDateNonISOResult.error.map { errors.append((birthDateNonISOName, $0)) }
        sexResult.error.map { errors.append((sexName, $0)) }
        contactInformationResult.error.map { errors.append((contactInformationName, $0)) }
        fullAddressResult.error.map { errors.append((fullAddressName, $0)) }

        guard
            let fullName = fullNameResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let patronymic = patronymicResult.value,
            let birthDate = birthDateResult.value,
            let birthDateNonISO = birthDateNonISOResult.value,
            let sex = sexResult.value,
            let contactInformation = contactInformationResult.value,
            let fullAddress = fullAddressResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                fullName: fullName,
                firstName: firstName,
                lastName: lastName,
                patronymic: patronymic,
                birthDate: birthDate,
                birthDateNonISO: birthDateNonISO,
                sex: sex,
                contactInformation: contactInformation,
                fullAddress: fullAddress
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let fullNameResult = fullNameTransformer.transform(destination: value.fullName)
        let firstNameResult = firstNameTransformer.transform(destination: value.firstName)
        let lastNameResult = lastNameTransformer.transform(destination: value.lastName)
        let patronymicResult = patronymicTransformer.transform(destination: value.patronymic)
        let birthDateResult = birthDateTransformer.transform(destination: value.birthDate)
        let birthDateNonISOResult = birthDateNonISOTransformer.transform(destination: value.birthDateNonISO)
        let sexResult = sexTransformer.transform(destination: value.sex)
        let contactInformationResult = contactInformationTransformer.transform(destination: value.contactInformation)
        let fullAddressResult = fullAddressTransformer.transform(destination: value.fullAddress)

        var errors: [(String, TransformerError)] = []
        fullNameResult.error.map { errors.append((fullNameName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }
        birthDateNonISOResult.error.map { errors.append((birthDateNonISOName, $0)) }
        sexResult.error.map { errors.append((sexName, $0)) }
        contactInformationResult.error.map { errors.append((contactInformationName, $0)) }
        fullAddressResult.error.map { errors.append((fullAddressName, $0)) }

        guard
            let fullName = fullNameResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let patronymic = patronymicResult.value,
            let birthDate = birthDateResult.value,
            let birthDateNonISO = birthDateNonISOResult.value,
            let sex = sexResult.value,
            let contactInformation = contactInformationResult.value,
            let fullAddress = fullAddressResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[fullNameName] = fullName
        dictionary[firstNameName] = firstName
        dictionary[lastNameName] = lastName
        dictionary[patronymicName] = patronymic
        dictionary[birthDateName] = birthDate
        dictionary[birthDateNonISOName] = birthDateNonISO
        dictionary[sexName] = sex
        dictionary[contactInformationName] = contactInformation
        dictionary[fullAddressName] = fullAddress
        return .success(dictionary)
    }
}
