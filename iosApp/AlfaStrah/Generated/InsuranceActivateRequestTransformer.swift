// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceActivateRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceActivateRequest

    let priceName = "price"
    let numberName = "number"
    let purchaseDateName = "buy_date"
    let purchaseLocationName = "where_purchased"
    let ownershipTypeName = "ownership_type"
    let insurerName = "insurer"

    let priceTransformer = MoneyTransformer()
    let numberTransformer = CastTransformer<Any, String>()
    let purchaseDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let purchaseLocationTransformer = CastTransformer<Any, String>()
    let ownershipTypeTransformer = OwnershipTypeTransformer()
    let insurerTransformer = InsuranceParticipantTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let priceResult = dictionary[priceName].map(priceTransformer.transform(source:)) ?? .failure(.requirement)
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let purchaseDateResult = dictionary[purchaseDateName].map(purchaseDateTransformer.transform(source:)) ?? .failure(.requirement)
        let purchaseLocationResult = dictionary[purchaseLocationName].map(purchaseLocationTransformer.transform(source:)) ?? .failure(.requirement)
        let ownershipTypeResult = dictionary[ownershipTypeName].map(ownershipTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let insurerResult = dictionary[insurerName].map(insurerTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        priceResult.error.map { errors.append((priceName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        purchaseDateResult.error.map { errors.append((purchaseDateName, $0)) }
        purchaseLocationResult.error.map { errors.append((purchaseLocationName, $0)) }
        ownershipTypeResult.error.map { errors.append((ownershipTypeName, $0)) }
        insurerResult.error.map { errors.append((insurerName, $0)) }

        guard
            let price = priceResult.value,
            let number = numberResult.value,
            let purchaseDate = purchaseDateResult.value,
            let purchaseLocation = purchaseLocationResult.value,
            let ownershipType = ownershipTypeResult.value,
            let insurer = insurerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                price: price,
                number: number,
                purchaseDate: purchaseDate,
                purchaseLocation: purchaseLocation,
                ownershipType: ownershipType,
                insurer: insurer
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let priceResult = priceTransformer.transform(destination: value.price)
        let numberResult = numberTransformer.transform(destination: value.number)
        let purchaseDateResult = purchaseDateTransformer.transform(destination: value.purchaseDate)
        let purchaseLocationResult = purchaseLocationTransformer.transform(destination: value.purchaseLocation)
        let ownershipTypeResult = ownershipTypeTransformer.transform(destination: value.ownershipType)
        let insurerResult = insurerTransformer.transform(destination: value.insurer)

        var errors: [(String, TransformerError)] = []
        priceResult.error.map { errors.append((priceName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        purchaseDateResult.error.map { errors.append((purchaseDateName, $0)) }
        purchaseLocationResult.error.map { errors.append((purchaseLocationName, $0)) }
        ownershipTypeResult.error.map { errors.append((ownershipTypeName, $0)) }
        insurerResult.error.map { errors.append((insurerName, $0)) }

        guard
            let price = priceResult.value,
            let number = numberResult.value,
            let purchaseDate = purchaseDateResult.value,
            let purchaseLocation = purchaseLocationResult.value,
            let ownershipType = ownershipTypeResult.value,
            let insurer = insurerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[priceName] = price
        dictionary[numberName] = number
        dictionary[purchaseDateName] = purchaseDate
        dictionary[purchaseLocationName] = purchaseLocation
        dictionary[ownershipTypeName] = ownershipType
        dictionary[insurerName] = insurer
        return .success(dictionary)
    }
}
