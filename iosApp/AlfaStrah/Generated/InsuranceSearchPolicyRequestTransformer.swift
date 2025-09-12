// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceSearchPolicyRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceSearchPolicyRequest

    let idName = "id"
    let insuranceNumberName = "insurance_number"
    let imageURLName = "image_url"
    let issueDateName = "issue_date"
    let requestDateName = "request_datetime"
    let stateName = "state"
    let plannedDateName = "planned_date"
    let plannedDateMinName = "planned_date_min"
    let productIdName = "type"

    let idTransformer = IdTransformer<Any>()
    let insuranceNumberTransformer = CastTransformer<Any, String>()
    let imageURLTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let issueDateTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-mm-dd", locale: AppLocale.currentLocale))
    let requestDateTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-mm-dd HH:mm:ss", locale: AppLocale.currentLocale))
    let stateTransformer = InsuranceSearchPolicyRequestStateTransformer()
    let plannedDateTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale))
    let plannedDateMinTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-mm-dd", locale: AppLocale.currentLocale))
    let productIdTransformer = IdTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceNumberResult = dictionary[insuranceNumberName].map(insuranceNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let imageURLResult = imageURLTransformer.transform(source: dictionary[imageURLName])
        let issueDateResult = issueDateTransformer.transform(source: dictionary[issueDateName])
        let requestDateResult = requestDateTransformer.transform(source: dictionary[requestDateName])
        let stateResult = dictionary[stateName].map(stateTransformer.transform(source:)) ?? .failure(.requirement)
        let plannedDateResult = plannedDateTransformer.transform(source: dictionary[plannedDateName])
        let plannedDateMinResult = plannedDateMinTransformer.transform(source: dictionary[plannedDateMinName])
        let productIdResult = dictionary[productIdName].map(productIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        insuranceNumberResult.error.map { errors.append((insuranceNumberName, $0)) }
        imageURLResult.error.map { errors.append((imageURLName, $0)) }
        issueDateResult.error.map { errors.append((issueDateName, $0)) }
        requestDateResult.error.map { errors.append((requestDateName, $0)) }
        stateResult.error.map { errors.append((stateName, $0)) }
        plannedDateResult.error.map { errors.append((plannedDateName, $0)) }
        plannedDateMinResult.error.map { errors.append((plannedDateMinName, $0)) }
        productIdResult.error.map { errors.append((productIdName, $0)) }

        guard
            let id = idResult.value,
            let insuranceNumber = insuranceNumberResult.value,
            let imageURL = imageURLResult.value,
            let issueDate = issueDateResult.value,
            let requestDate = requestDateResult.value,
            let state = stateResult.value,
            let plannedDate = plannedDateResult.value,
            let plannedDateMin = plannedDateMinResult.value,
            let productId = productIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                insuranceNumber: insuranceNumber,
                imageURL: imageURL,
                issueDate: issueDate,
                requestDate: requestDate,
                state: state,
                plannedDate: plannedDate,
                plannedDateMin: plannedDateMin,
                productId: productId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let insuranceNumberResult = insuranceNumberTransformer.transform(destination: value.insuranceNumber)
        let imageURLResult = imageURLTransformer.transform(destination: value.imageURL)
        let issueDateResult = issueDateTransformer.transform(destination: value.issueDate)
        let requestDateResult = requestDateTransformer.transform(destination: value.requestDate)
        let stateResult = stateTransformer.transform(destination: value.state)
        let plannedDateResult = plannedDateTransformer.transform(destination: value.plannedDate)
        let plannedDateMinResult = plannedDateMinTransformer.transform(destination: value.plannedDateMin)
        let productIdResult = productIdTransformer.transform(destination: value.productId)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        insuranceNumberResult.error.map { errors.append((insuranceNumberName, $0)) }
        imageURLResult.error.map { errors.append((imageURLName, $0)) }
        issueDateResult.error.map { errors.append((issueDateName, $0)) }
        requestDateResult.error.map { errors.append((requestDateName, $0)) }
        stateResult.error.map { errors.append((stateName, $0)) }
        plannedDateResult.error.map { errors.append((plannedDateName, $0)) }
        plannedDateMinResult.error.map { errors.append((plannedDateMinName, $0)) }
        productIdResult.error.map { errors.append((productIdName, $0)) }

        guard
            let id = idResult.value,
            let insuranceNumber = insuranceNumberResult.value,
            let imageURL = imageURLResult.value,
            let issueDate = issueDateResult.value,
            let requestDate = requestDateResult.value,
            let state = stateResult.value,
            let plannedDate = plannedDateResult.value,
            let plannedDateMin = plannedDateMinResult.value,
            let productId = productIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[insuranceNumberName] = insuranceNumber
        dictionary[imageURLName] = imageURL
        dictionary[issueDateName] = issueDate
        dictionary[requestDateName] = requestDate
        dictionary[stateName] = state
        dictionary[plannedDateName] = plannedDate
        dictionary[plannedDateMinName] = plannedDateMin
        dictionary[productIdName] = productId
        return .success(dictionary)
    }
}
