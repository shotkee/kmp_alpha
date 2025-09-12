// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EsiaUserTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EsiaUser

    let esiaIdName = "oid"
    let firstNameName = "firstName"
    let lastNameName = "lastName"
    let middleNameName = "middleName"
    let birthDateName = "birthDate"
    let addressName = "address"
    let passportName = "passport"
    let drivingLicenseName = "drivingLicense"
    let mobileName = "mobile"
    let emailName = "email"

    let esiaIdTransformer = IdTransformer<Any>()
    let firstNameTransformer = CastTransformer<Any, String>()
    let lastNameTransformer = CastTransformer<Any, String>()
    let middleNameTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let birthDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let addressTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let passportTransformer = EsiaPassportTransformer()
    let drivingLicenseTransformer = OptionalTransformer(transformer: EsiaDriverLicenseTransformer())
    let mobileTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let emailTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let esiaIdResult = dictionary[esiaIdName].map(esiaIdTransformer.transform(source:)) ?? .failure(.requirement)
        let firstNameResult = dictionary[firstNameName].map(firstNameTransformer.transform(source:)) ?? .failure(.requirement)
        let lastNameResult = dictionary[lastNameName].map(lastNameTransformer.transform(source:)) ?? .failure(.requirement)
        let middleNameResult = middleNameTransformer.transform(source: dictionary[middleNameName])
        let birthDateResult = dictionary[birthDateName].map(birthDateTransformer.transform(source:)) ?? .failure(.requirement)
        let addressResult = addressTransformer.transform(source: dictionary[addressName])
        let passportResult = dictionary[passportName].map(passportTransformer.transform(source:)) ?? .failure(.requirement)
        let drivingLicenseResult = drivingLicenseTransformer.transform(source: dictionary[drivingLicenseName])
        let mobileResult = mobileTransformer.transform(source: dictionary[mobileName])
        let emailResult = emailTransformer.transform(source: dictionary[emailName])

        var errors: [(String, TransformerError)] = []
        esiaIdResult.error.map { errors.append((esiaIdName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        middleNameResult.error.map { errors.append((middleNameName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        passportResult.error.map { errors.append((passportName, $0)) }
        drivingLicenseResult.error.map { errors.append((drivingLicenseName, $0)) }
        mobileResult.error.map { errors.append((mobileName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }

        guard
            let esiaId = esiaIdResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let middleName = middleNameResult.value,
            let birthDate = birthDateResult.value,
            let address = addressResult.value,
            let passport = passportResult.value,
            let drivingLicense = drivingLicenseResult.value,
            let mobile = mobileResult.value,
            let email = emailResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                esiaId: esiaId,
                firstName: firstName,
                lastName: lastName,
                middleName: middleName,
                birthDate: birthDate,
                address: address,
                passport: passport,
                drivingLicense: drivingLicense,
                mobile: mobile,
                email: email
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let esiaIdResult = esiaIdTransformer.transform(destination: value.esiaId)
        let firstNameResult = firstNameTransformer.transform(destination: value.firstName)
        let lastNameResult = lastNameTransformer.transform(destination: value.lastName)
        let middleNameResult = middleNameTransformer.transform(destination: value.middleName)
        let birthDateResult = birthDateTransformer.transform(destination: value.birthDate)
        let addressResult = addressTransformer.transform(destination: value.address)
        let passportResult = passportTransformer.transform(destination: value.passport)
        let drivingLicenseResult = drivingLicenseTransformer.transform(destination: value.drivingLicense)
        let mobileResult = mobileTransformer.transform(destination: value.mobile)
        let emailResult = emailTransformer.transform(destination: value.email)

        var errors: [(String, TransformerError)] = []
        esiaIdResult.error.map { errors.append((esiaIdName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        middleNameResult.error.map { errors.append((middleNameName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        passportResult.error.map { errors.append((passportName, $0)) }
        drivingLicenseResult.error.map { errors.append((drivingLicenseName, $0)) }
        mobileResult.error.map { errors.append((mobileName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }

        guard
            let esiaId = esiaIdResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let middleName = middleNameResult.value,
            let birthDate = birthDateResult.value,
            let address = addressResult.value,
            let passport = passportResult.value,
            let drivingLicense = drivingLicenseResult.value,
            let mobile = mobileResult.value,
            let email = emailResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[esiaIdName] = esiaId
        dictionary[firstNameName] = firstName
        dictionary[lastNameName] = lastName
        dictionary[middleNameName] = middleName
        dictionary[birthDateName] = birthDate
        dictionary[addressName] = address
        dictionary[passportName] = passport
        dictionary[drivingLicenseName] = drivingLicense
        dictionary[mobileName] = mobile
        dictionary[emailName] = email
        return .success(dictionary)
    }
}
