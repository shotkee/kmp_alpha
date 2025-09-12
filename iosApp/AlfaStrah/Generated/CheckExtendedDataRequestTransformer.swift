// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CheckExtendedDataRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CheckExtendedDataRequest

    let insuranceNumberName = "insurance_number"
    let firstNameName = "first_name"
    let lastNameName = "last_name"
    let phoneName = "phone_number"
    let birthDateName = "birth_date"

    let insuranceNumberTransformer = CastTransformer<Any, String>()
    let firstNameTransformer = CastTransformer<Any, String>()
    let lastNameTransformer = CastTransformer<Any, String>()
    let phoneTransformer = CastTransformer<Any, String>()
    let birthDateTransformer = TimestampTransformer<Any>(scale: 1)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceNumberResult = dictionary[insuranceNumberName].map(insuranceNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let firstNameResult = dictionary[firstNameName].map(firstNameTransformer.transform(source:)) ?? .failure(.requirement)
        let lastNameResult = dictionary[lastNameName].map(lastNameTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let birthDateResult = dictionary[birthDateName].map(birthDateTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceNumberResult.error.map { errors.append((insuranceNumberName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }

        guard
            let insuranceNumber = insuranceNumberResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let phone = phoneResult.value,
            let birthDate = birthDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceNumber: insuranceNumber,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                birthDate: birthDate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceNumberResult = insuranceNumberTransformer.transform(destination: value.insuranceNumber)
        let firstNameResult = firstNameTransformer.transform(destination: value.firstName)
        let lastNameResult = lastNameTransformer.transform(destination: value.lastName)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let birthDateResult = birthDateTransformer.transform(destination: value.birthDate)

        var errors: [(String, TransformerError)] = []
        insuranceNumberResult.error.map { errors.append((insuranceNumberName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }

        guard
            let insuranceNumber = insuranceNumberResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let phone = phoneResult.value,
            let birthDate = birthDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceNumberName] = insuranceNumber
        dictionary[firstNameName] = firstName
        dictionary[lastNameName] = lastName
        dictionary[phoneName] = phone
        dictionary[birthDateName] = birthDate
        return .success(dictionary)
    }
}
