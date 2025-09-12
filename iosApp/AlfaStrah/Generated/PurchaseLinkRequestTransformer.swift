// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct PurchaseLinkRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = PurchaseLinkRequest

    let insuranceIdName = "insurance_id"
    let purchaseItemIdName = "purchaseitem_id"

    let insuranceIdTransformer = IdTransformer<Any>()
    let purchaseItemIdTransformer = IdTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let purchaseItemIdResult = dictionary[purchaseItemIdName].map(purchaseItemIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        purchaseItemIdResult.error.map { errors.append((purchaseItemIdName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let purchaseItemId = purchaseItemIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                purchaseItemId: purchaseItemId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let purchaseItemIdResult = purchaseItemIdTransformer.transform(destination: value.purchaseItemId)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        purchaseItemIdResult.error.map { errors.append((purchaseItemIdName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let purchaseItemId = purchaseItemIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[purchaseItemIdName] = purchaseItemId
        return .success(dictionary)
    }
}
