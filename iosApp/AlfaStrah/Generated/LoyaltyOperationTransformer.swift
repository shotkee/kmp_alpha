// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct LoyaltyOperationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = LoyaltyOperation

    let idName = "id"
    let productIdName = "product_id"
    let categoryIdName = "category_id"
    let categoryTypeName = "category_type"
    let insuranceDeeplinkTypeIdName = "insurance_deeplink_type"
    let loyaltyTypeName = "type"
    let operationTypeName = "operation_type"
    let amountName = "amount"
    let descriptionName = "description"
    let dateName = "date"
    let statusDescriptionName = "status"
    let statusName = "status_id"
    let contractNumberName = "contract_number"
    let iconTypeName = "icon_type"

    let idTransformer = IdTransformer<Any>()
    let productIdTransformer = OptionalTransformer(transformer: IdTransformer<Any>())
    let categoryIdTransformer = OptionalTransformer(transformer: IdTransformer<Any>())
    let categoryTypeTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())
    let insuranceDeeplinkTypeIdTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())
    let loyaltyTypeTransformer = OptionalTransformer(transformer: LoyaltyOperationLoyaltyTypeTransformer())
    let operationTypeTransformer = OptionalTransformer(transformer: LoyaltyOperationOperationTypeTransformer())
    let amountTransformer = NumberTransformer<Any, Double>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let dateTransformer = TimestampTransformer<Any>(scale: 1)
    let statusDescriptionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let statusTransformer = OptionalTransformer(transformer: LoyaltyOperationOperationStatusTransformer())
    let contractNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let iconTypeTransformer = OptionalTransformer(transformer: LoyaltyOperationIconTypeTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let productIdResult = productIdTransformer.transform(source: dictionary[productIdName])
        let categoryIdResult = categoryIdTransformer.transform(source: dictionary[categoryIdName])
        let categoryTypeResult = categoryTypeTransformer.transform(source: dictionary[categoryTypeName])
        let insuranceDeeplinkTypeIdResult = insuranceDeeplinkTypeIdTransformer.transform(source: dictionary[insuranceDeeplinkTypeIdName])
        let loyaltyTypeResult = loyaltyTypeTransformer.transform(source: dictionary[loyaltyTypeName])
        let operationTypeResult = operationTypeTransformer.transform(source: dictionary[operationTypeName])
        let amountResult = dictionary[amountName].map(amountTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let statusDescriptionResult = statusDescriptionTransformer.transform(source: dictionary[statusDescriptionName])
        let statusResult = statusTransformer.transform(source: dictionary[statusName])
        let contractNumberResult = contractNumberTransformer.transform(source: dictionary[contractNumberName])
        let iconTypeResult = iconTypeTransformer.transform(source: dictionary[iconTypeName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        productIdResult.error.map { errors.append((productIdName, $0)) }
        categoryIdResult.error.map { errors.append((categoryIdName, $0)) }
        categoryTypeResult.error.map { errors.append((categoryTypeName, $0)) }
        insuranceDeeplinkTypeIdResult.error.map { errors.append((insuranceDeeplinkTypeIdName, $0)) }
        loyaltyTypeResult.error.map { errors.append((loyaltyTypeName, $0)) }
        operationTypeResult.error.map { errors.append((operationTypeName, $0)) }
        amountResult.error.map { errors.append((amountName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        statusDescriptionResult.error.map { errors.append((statusDescriptionName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        contractNumberResult.error.map { errors.append((contractNumberName, $0)) }
        iconTypeResult.error.map { errors.append((iconTypeName, $0)) }

        guard
            let id = idResult.value,
            let productId = productIdResult.value,
            let categoryId = categoryIdResult.value,
            let categoryType = categoryTypeResult.value,
            let insuranceDeeplinkTypeId = insuranceDeeplinkTypeIdResult.value,
            let loyaltyType = loyaltyTypeResult.value,
            let operationType = operationTypeResult.value,
            let amount = amountResult.value,
            let description = descriptionResult.value,
            let date = dateResult.value,
            let statusDescription = statusDescriptionResult.value,
            let status = statusResult.value,
            let contractNumber = contractNumberResult.value,
            let iconType = iconTypeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                productId: productId,
                categoryId: categoryId,
                categoryType: categoryType,
                insuranceDeeplinkTypeId: insuranceDeeplinkTypeId,
                loyaltyType: loyaltyType,
                operationType: operationType,
                amount: amount,
                description: description,
                date: date,
                statusDescription: statusDescription,
                status: status,
                contractNumber: contractNumber,
                iconType: iconType
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let productIdResult = productIdTransformer.transform(destination: value.productId)
        let categoryIdResult = categoryIdTransformer.transform(destination: value.categoryId)
        let categoryTypeResult = categoryTypeTransformer.transform(destination: value.categoryType)
        let insuranceDeeplinkTypeIdResult = insuranceDeeplinkTypeIdTransformer.transform(destination: value.insuranceDeeplinkTypeId)
        let loyaltyTypeResult = loyaltyTypeTransformer.transform(destination: value.loyaltyType)
        let operationTypeResult = operationTypeTransformer.transform(destination: value.operationType)
        let amountResult = amountTransformer.transform(destination: value.amount)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let dateResult = dateTransformer.transform(destination: value.date)
        let statusDescriptionResult = statusDescriptionTransformer.transform(destination: value.statusDescription)
        let statusResult = statusTransformer.transform(destination: value.status)
        let contractNumberResult = contractNumberTransformer.transform(destination: value.contractNumber)
        let iconTypeResult = iconTypeTransformer.transform(destination: value.iconType)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        productIdResult.error.map { errors.append((productIdName, $0)) }
        categoryIdResult.error.map { errors.append((categoryIdName, $0)) }
        categoryTypeResult.error.map { errors.append((categoryTypeName, $0)) }
        insuranceDeeplinkTypeIdResult.error.map { errors.append((insuranceDeeplinkTypeIdName, $0)) }
        loyaltyTypeResult.error.map { errors.append((loyaltyTypeName, $0)) }
        operationTypeResult.error.map { errors.append((operationTypeName, $0)) }
        amountResult.error.map { errors.append((amountName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        statusDescriptionResult.error.map { errors.append((statusDescriptionName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        contractNumberResult.error.map { errors.append((contractNumberName, $0)) }
        iconTypeResult.error.map { errors.append((iconTypeName, $0)) }

        guard
            let id = idResult.value,
            let productId = productIdResult.value,
            let categoryId = categoryIdResult.value,
            let categoryType = categoryTypeResult.value,
            let insuranceDeeplinkTypeId = insuranceDeeplinkTypeIdResult.value,
            let loyaltyType = loyaltyTypeResult.value,
            let operationType = operationTypeResult.value,
            let amount = amountResult.value,
            let description = descriptionResult.value,
            let date = dateResult.value,
            let statusDescription = statusDescriptionResult.value,
            let status = statusResult.value,
            let contractNumber = contractNumberResult.value,
            let iconType = iconTypeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[productIdName] = productId
        dictionary[categoryIdName] = categoryId
        dictionary[categoryTypeName] = categoryType
        dictionary[insuranceDeeplinkTypeIdName] = insuranceDeeplinkTypeId
        dictionary[loyaltyTypeName] = loyaltyType
        dictionary[operationTypeName] = operationType
        dictionary[amountName] = amount
        dictionary[descriptionName] = description
        dictionary[dateName] = date
        dictionary[statusDescriptionName] = statusDescription
        dictionary[statusName] = status
        dictionary[contractNumberName] = contractNumber
        dictionary[iconTypeName] = iconType
        return .success(dictionary)
    }
}
