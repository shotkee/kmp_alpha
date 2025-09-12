// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceBillDisagreementServiceTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceBillDisagreementService

    let idName = "id"
    let clinicNameName = "corp_full_name"
    let dateName = "mt_date"
    let serviceNameName = "service_name"
    let quantityName = "quantity"
    let sumWithFranchiseName = "sum_franch"
    let franchisePercentageName = "franchise"
    let paymentAmountName = "to_pay_value"

    let idTransformer = NumberTransformer<Any, Int>()
    let clinicNameTransformer = CastTransformer<Any, String>()
    let dateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let serviceNameTransformer = CastTransformer<Any, String>()
    let quantityTransformer = NumberTransformer<Any, Double>()
    let sumWithFranchiseTransformer = NumberTransformer<Any, Double>()
    let franchisePercentageTransformer = CastTransformer<Any, String>()
    let paymentAmountTransformer = NumberTransformer<Any, Double>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicNameResult = dictionary[clinicNameName].map(clinicNameTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let serviceNameResult = dictionary[serviceNameName].map(serviceNameTransformer.transform(source:)) ?? .failure(.requirement)
        let quantityResult = dictionary[quantityName].map(quantityTransformer.transform(source:)) ?? .failure(.requirement)
        let sumWithFranchiseResult = dictionary[sumWithFranchiseName].map(sumWithFranchiseTransformer.transform(source:)) ?? .failure(.requirement)
        let franchisePercentageResult = dictionary[franchisePercentageName].map(franchisePercentageTransformer.transform(source:)) ?? .failure(.requirement)
        let paymentAmountResult = dictionary[paymentAmountName].map(paymentAmountTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        clinicNameResult.error.map { errors.append((clinicNameName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        serviceNameResult.error.map { errors.append((serviceNameName, $0)) }
        quantityResult.error.map { errors.append((quantityName, $0)) }
        sumWithFranchiseResult.error.map { errors.append((sumWithFranchiseName, $0)) }
        franchisePercentageResult.error.map { errors.append((franchisePercentageName, $0)) }
        paymentAmountResult.error.map { errors.append((paymentAmountName, $0)) }

        guard
            let id = idResult.value,
            let clinicName = clinicNameResult.value,
            let date = dateResult.value,
            let serviceName = serviceNameResult.value,
            let quantity = quantityResult.value,
            let sumWithFranchise = sumWithFranchiseResult.value,
            let franchisePercentage = franchisePercentageResult.value,
            let paymentAmount = paymentAmountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                clinicName: clinicName,
                date: date,
                serviceName: serviceName,
                quantity: quantity,
                sumWithFranchise: sumWithFranchise,
                franchisePercentage: franchisePercentage,
                paymentAmount: paymentAmount
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let clinicNameResult = clinicNameTransformer.transform(destination: value.clinicName)
        let dateResult = dateTransformer.transform(destination: value.date)
        let serviceNameResult = serviceNameTransformer.transform(destination: value.serviceName)
        let quantityResult = quantityTransformer.transform(destination: value.quantity)
        let sumWithFranchiseResult = sumWithFranchiseTransformer.transform(destination: value.sumWithFranchise)
        let franchisePercentageResult = franchisePercentageTransformer.transform(destination: value.franchisePercentage)
        let paymentAmountResult = paymentAmountTransformer.transform(destination: value.paymentAmount)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        clinicNameResult.error.map { errors.append((clinicNameName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        serviceNameResult.error.map { errors.append((serviceNameName, $0)) }
        quantityResult.error.map { errors.append((quantityName, $0)) }
        sumWithFranchiseResult.error.map { errors.append((sumWithFranchiseName, $0)) }
        franchisePercentageResult.error.map { errors.append((franchisePercentageName, $0)) }
        paymentAmountResult.error.map { errors.append((paymentAmountName, $0)) }

        guard
            let id = idResult.value,
            let clinicName = clinicNameResult.value,
            let date = dateResult.value,
            let serviceName = serviceNameResult.value,
            let quantity = quantityResult.value,
            let sumWithFranchise = sumWithFranchiseResult.value,
            let franchisePercentage = franchisePercentageResult.value,
            let paymentAmount = paymentAmountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[clinicNameName] = clinicName
        dictionary[dateName] = date
        dictionary[serviceNameName] = serviceName
        dictionary[quantityName] = quantity
        dictionary[sumWithFranchiseName] = sumWithFranchise
        dictionary[franchisePercentageName] = franchisePercentage
        dictionary[paymentAmountName] = paymentAmount
        return .success(dictionary)
    }
}
