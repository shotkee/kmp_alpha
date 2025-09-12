// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RegisterAccountRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RegisterAccountRequest

    let firstNameName = "first_name"
    let lastNameName = "last_name"
    let phoneNumberName = "phone_number"
    let birthDateISOName = "birth_date_iso"
    let insuranceNumberName = "insurance_number"
    let emailName = "email"
    let patronymicName = "patronymic"
    let typeName = "type"
    let deviceTokenName = "device_token"
    let seedName = "seed"
    let hashName = "hash"
    let agreedToPersonalDataPolicyName = "agreed"

    let firstNameTransformer = CastTransformer<Any, String>()
    let lastNameTransformer = CastTransformer<Any, String>()
    let phoneNumberTransformer = CastTransformer<Any, String>()
    let birthDateISOTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let insuranceNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let emailTransformer = CastTransformer<Any, String>()
    let patronymicTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let typeTransformer = AccountTypeTransformer()
    let deviceTokenTransformer = CastTransformer<Any, String>()
    let seedTransformer = CastTransformer<Any, String>()
    let hashTransformer = CastTransformer<Any, String>()
    let agreedToPersonalDataPolicyTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let firstNameResult = dictionary[firstNameName].map(firstNameTransformer.transform(source:)) ?? .failure(.requirement)
        let lastNameResult = dictionary[lastNameName].map(lastNameTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneNumberResult = dictionary[phoneNumberName].map(phoneNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let birthDateISOResult = dictionary[birthDateISOName].map(birthDateISOTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceNumberResult = insuranceNumberTransformer.transform(source: dictionary[insuranceNumberName])
        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)
        let patronymicResult = patronymicTransformer.transform(source: dictionary[patronymicName])
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let deviceTokenResult = dictionary[deviceTokenName].map(deviceTokenTransformer.transform(source:)) ?? .failure(.requirement)
        let seedResult = dictionary[seedName].map(seedTransformer.transform(source:)) ?? .failure(.requirement)
        let hashResult = dictionary[hashName].map(hashTransformer.transform(source:)) ?? .failure(.requirement)
        let agreedToPersonalDataPolicyResult = dictionary[agreedToPersonalDataPolicyName].map(agreedToPersonalDataPolicyTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        phoneNumberResult.error.map { errors.append((phoneNumberName, $0)) }
        birthDateISOResult.error.map { errors.append((birthDateISOName, $0)) }
        insuranceNumberResult.error.map { errors.append((insuranceNumberName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        deviceTokenResult.error.map { errors.append((deviceTokenName, $0)) }
        seedResult.error.map { errors.append((seedName, $0)) }
        hashResult.error.map { errors.append((hashName, $0)) }
        agreedToPersonalDataPolicyResult.error.map { errors.append((agreedToPersonalDataPolicyName, $0)) }

        guard
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let phoneNumber = phoneNumberResult.value,
            let birthDateISO = birthDateISOResult.value,
            let insuranceNumber = insuranceNumberResult.value,
            let email = emailResult.value,
            let patronymic = patronymicResult.value,
            let type = typeResult.value,
            let deviceToken = deviceTokenResult.value,
            let seed = seedResult.value,
            let hash = hashResult.value,
            let agreedToPersonalDataPolicy = agreedToPersonalDataPolicyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                birthDateISO: birthDateISO,
                insuranceNumber: insuranceNumber,
                email: email,
                patronymic: patronymic,
                type: type,
                deviceToken: deviceToken,
                seed: seed,
                hash: hash,
                agreedToPersonalDataPolicy: agreedToPersonalDataPolicy
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let firstNameResult = firstNameTransformer.transform(destination: value.firstName)
        let lastNameResult = lastNameTransformer.transform(destination: value.lastName)
        let phoneNumberResult = phoneNumberTransformer.transform(destination: value.phoneNumber)
        let birthDateISOResult = birthDateISOTransformer.transform(destination: value.birthDateISO)
        let insuranceNumberResult = insuranceNumberTransformer.transform(destination: value.insuranceNumber)
        let emailResult = emailTransformer.transform(destination: value.email)
        let patronymicResult = patronymicTransformer.transform(destination: value.patronymic)
        let typeResult = typeTransformer.transform(destination: value.type)
        let deviceTokenResult = deviceTokenTransformer.transform(destination: value.deviceToken)
        let seedResult = seedTransformer.transform(destination: value.seed)
        let hashResult = hashTransformer.transform(destination: value.hash)
        let agreedToPersonalDataPolicyResult = agreedToPersonalDataPolicyTransformer.transform(destination: value.agreedToPersonalDataPolicy)

        var errors: [(String, TransformerError)] = []
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        phoneNumberResult.error.map { errors.append((phoneNumberName, $0)) }
        birthDateISOResult.error.map { errors.append((birthDateISOName, $0)) }
        insuranceNumberResult.error.map { errors.append((insuranceNumberName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        deviceTokenResult.error.map { errors.append((deviceTokenName, $0)) }
        seedResult.error.map { errors.append((seedName, $0)) }
        hashResult.error.map { errors.append((hashName, $0)) }
        agreedToPersonalDataPolicyResult.error.map { errors.append((agreedToPersonalDataPolicyName, $0)) }

        guard
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let phoneNumber = phoneNumberResult.value,
            let birthDateISO = birthDateISOResult.value,
            let insuranceNumber = insuranceNumberResult.value,
            let email = emailResult.value,
            let patronymic = patronymicResult.value,
            let type = typeResult.value,
            let deviceToken = deviceTokenResult.value,
            let seed = seedResult.value,
            let hash = hashResult.value,
            let agreedToPersonalDataPolicy = agreedToPersonalDataPolicyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[firstNameName] = firstName
        dictionary[lastNameName] = lastName
        dictionary[phoneNumberName] = phoneNumber
        dictionary[birthDateISOName] = birthDateISO
        dictionary[insuranceNumberName] = insuranceNumber
        dictionary[emailName] = email
        dictionary[patronymicName] = patronymic
        dictionary[typeName] = type
        dictionary[deviceTokenName] = deviceToken
        dictionary[seedName] = seed
        dictionary[hashName] = hash
        dictionary[agreedToPersonalDataPolicyName] = agreedToPersonalDataPolicy
        return .success(dictionary)
    }
}
