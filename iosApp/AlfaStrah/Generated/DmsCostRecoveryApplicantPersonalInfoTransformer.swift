// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryApplicantPersonalInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryApplicantPersonalInfo

    let fullnameName = "full_name"
    let birthdayName = "birthday"
    let policyNumberName = "policy_number"
    let serviceNumberName = "tab_number"
    let phoneName = "phone"
    let emailName = "email"

    let fullnameTransformer = CastTransformer<Any, String>()
    let birthdayTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-MM-dd"))
    let policyNumberTransformer = CastTransformer<Any, String>()
    let serviceNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let phoneTransformer = OptionalTransformer(transformer: PhoneTransformer())
    let emailTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let fullnameResult = dictionary[fullnameName].map(fullnameTransformer.transform(source:)) ?? .failure(.requirement)
        let birthdayResult = birthdayTransformer.transform(source: dictionary[birthdayName])
        let policyNumberResult = dictionary[policyNumberName].map(policyNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let serviceNumberResult = serviceNumberTransformer.transform(source: dictionary[serviceNumberName])
        let phoneResult = phoneTransformer.transform(source: dictionary[phoneName])
        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        fullnameResult.error.map { errors.append((fullnameName, $0)) }
        birthdayResult.error.map { errors.append((birthdayName, $0)) }
        policyNumberResult.error.map { errors.append((policyNumberName, $0)) }
        serviceNumberResult.error.map { errors.append((serviceNumberName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }

        guard
            let fullname = fullnameResult.value,
            let birthday = birthdayResult.value,
            let policyNumber = policyNumberResult.value,
            let serviceNumber = serviceNumberResult.value,
            let phone = phoneResult.value,
            let email = emailResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                fullname: fullname,
                birthday: birthday,
                policyNumber: policyNumber,
                serviceNumber: serviceNumber,
                phone: phone,
                email: email
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let fullnameResult = fullnameTransformer.transform(destination: value.fullname)
        let birthdayResult = birthdayTransformer.transform(destination: value.birthday)
        let policyNumberResult = policyNumberTransformer.transform(destination: value.policyNumber)
        let serviceNumberResult = serviceNumberTransformer.transform(destination: value.serviceNumber)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let emailResult = emailTransformer.transform(destination: value.email)

        var errors: [(String, TransformerError)] = []
        fullnameResult.error.map { errors.append((fullnameName, $0)) }
        birthdayResult.error.map { errors.append((birthdayName, $0)) }
        policyNumberResult.error.map { errors.append((policyNumberName, $0)) }
        serviceNumberResult.error.map { errors.append((serviceNumberName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }

        guard
            let fullname = fullnameResult.value,
            let birthday = birthdayResult.value,
            let policyNumber = policyNumberResult.value,
            let serviceNumber = serviceNumberResult.value,
            let phone = phoneResult.value,
            let email = emailResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[fullnameName] = fullname
        dictionary[birthdayName] = birthday
        dictionary[policyNumberName] = policyNumber
        dictionary[serviceNumberName] = serviceNumber
        dictionary[phoneName] = phone
        dictionary[emailName] = email
        return .success(dictionary)
    }
}
