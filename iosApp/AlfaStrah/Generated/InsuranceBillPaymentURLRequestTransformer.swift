// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceBillPaymentURLRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceBillPaymentURLRequest

    let insuranceIdName = "insurance_id"
    let billIdsName = "bill_ids"
    let emailName = "email"
    let phoneName = "phone"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let billIdsTransformer = ArrayTransformer(from: Any.self, transformer: NumberTransformer<Any, Int>(), skipFailures: true)
    let emailTransformer = CastTransformer<Any, String>()
    let phoneTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let billIdsResult = dictionary[billIdsName].map(billIdsTransformer.transform(source:)) ?? .failure(.requirement)
        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        billIdsResult.error.map { errors.append((billIdsName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let billIds = billIdsResult.value,
            let email = emailResult.value,
            let phone = phoneResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                billIds: billIds,
                email: email,
                phone: phone
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let billIdsResult = billIdsTransformer.transform(destination: value.billIds)
        let emailResult = emailTransformer.transform(destination: value.email)
        let phoneResult = phoneTransformer.transform(destination: value.phone)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        billIdsResult.error.map { errors.append((billIdsName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let billIds = billIdsResult.value,
            let email = emailResult.value,
            let phone = phoneResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[billIdsName] = billIds
        dictionary[emailName] = email
        dictionary[phoneName] = phone
        return .success(dictionary)
    }
}
