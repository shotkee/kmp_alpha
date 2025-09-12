// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceBillDisagreementRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceBillDisagreementRequest

    let insuranceIdName = "insurance_id"
    let insuranceBillIdName = "bill_id"
    let reasonIdName = "reason_id"
    let servicesIdsName = "service_ids"
    let commentName = "comment"
    let phoneName = "phone"
    let emailName = "email"
    let documentsIdsName = "file_ids"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let insuranceBillIdTransformer = NumberTransformer<Any, Int>()
    let reasonIdTransformer = NumberTransformer<Any, Int>()
    let servicesIdsTransformer = ArrayTransformer(from: Any.self, transformer: NumberTransformer<Any, Int>(), skipFailures: true)
    let commentTransformer = CastTransformer<Any, String>()
    let phoneTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let emailTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let documentsIdsTransformer = ArrayTransformer(from: Any.self, transformer: NumberTransformer<Any, Int>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceBillIdResult = dictionary[insuranceBillIdName].map(insuranceBillIdTransformer.transform(source:)) ?? .failure(.requirement)
        let reasonIdResult = dictionary[reasonIdName].map(reasonIdTransformer.transform(source:)) ?? .failure(.requirement)
        let servicesIdsResult = dictionary[servicesIdsName].map(servicesIdsTransformer.transform(source:)) ?? .failure(.requirement)
        let commentResult = dictionary[commentName].map(commentTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = phoneTransformer.transform(source: dictionary[phoneName])
        let emailResult = emailTransformer.transform(source: dictionary[emailName])
        let documentsIdsResult = dictionary[documentsIdsName].map(documentsIdsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        insuranceBillIdResult.error.map { errors.append((insuranceBillIdName, $0)) }
        reasonIdResult.error.map { errors.append((reasonIdName, $0)) }
        servicesIdsResult.error.map { errors.append((servicesIdsName, $0)) }
        commentResult.error.map { errors.append((commentName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        documentsIdsResult.error.map { errors.append((documentsIdsName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let insuranceBillId = insuranceBillIdResult.value,
            let reasonId = reasonIdResult.value,
            let servicesIds = servicesIdsResult.value,
            let comment = commentResult.value,
            let phone = phoneResult.value,
            let email = emailResult.value,
            let documentsIds = documentsIdsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                insuranceBillId: insuranceBillId,
                reasonId: reasonId,
                servicesIds: servicesIds,
                comment: comment,
                phone: phone,
                email: email,
                documentsIds: documentsIds
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let insuranceBillIdResult = insuranceBillIdTransformer.transform(destination: value.insuranceBillId)
        let reasonIdResult = reasonIdTransformer.transform(destination: value.reasonId)
        let servicesIdsResult = servicesIdsTransformer.transform(destination: value.servicesIds)
        let commentResult = commentTransformer.transform(destination: value.comment)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let emailResult = emailTransformer.transform(destination: value.email)
        let documentsIdsResult = documentsIdsTransformer.transform(destination: value.documentsIds)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        insuranceBillIdResult.error.map { errors.append((insuranceBillIdName, $0)) }
        reasonIdResult.error.map { errors.append((reasonIdName, $0)) }
        servicesIdsResult.error.map { errors.append((servicesIdsName, $0)) }
        commentResult.error.map { errors.append((commentName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        documentsIdsResult.error.map { errors.append((documentsIdsName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let insuranceBillId = insuranceBillIdResult.value,
            let reasonId = reasonIdResult.value,
            let servicesIds = servicesIdsResult.value,
            let comment = commentResult.value,
            let phone = phoneResult.value,
            let email = emailResult.value,
            let documentsIds = documentsIdsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[insuranceBillIdName] = insuranceBillId
        dictionary[reasonIdName] = reasonId
        dictionary[servicesIdsName] = servicesIds
        dictionary[commentName] = comment
        dictionary[phoneName] = phone
        dictionary[emailName] = email
        dictionary[documentsIdsName] = documentsIds
        return .success(dictionary)
    }
}
