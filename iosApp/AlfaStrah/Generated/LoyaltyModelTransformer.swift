// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct LoyaltyModelTransformer: Transformer {
    typealias Source = Any
    typealias Destination = LoyaltyModel

    let amountName = "points_amount"
    let addedName = "points_added"
    let spentName = "points_spent"
    let statusName = "status"
    let statusDescriptionName = "status_description"
    let nextStatusName = "next_status"
    let nextStatusMoneyName = "next_status_money"
    let nextStatusDescriptionName = "next_status_description"
    let hotlineDescriptionName = "hotline_description"
    let hotlinePhoneName = "hotline_phone"
    let lastOperationsName = "last_operations"
    let insuranceDeeplinkTypesName = "insurance_deeplink_types"
    let operationsCntName = "operations_cnt"

    let amountTransformer = NumberTransformer<Any, Double>()
    let addedTransformer = NumberTransformer<Any, Double>()
    let spentTransformer = NumberTransformer<Any, Double>()
    let statusTransformer = CastTransformer<Any, String>()
    let statusDescriptionTransformer = CastTransformer<Any, String>()
    let nextStatusTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let nextStatusMoneyTransformer = NumberTransformer<Any, Double>()
    let nextStatusDescriptionTransformer = CastTransformer<Any, String>()
    let hotlineDescriptionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let hotlinePhoneTransformer = OptionalTransformer(transformer: PhoneTransformer())
    let lastOperationsTransformer = ArrayTransformer(from: Any.self, transformer: LoyaltyOperationTransformer(), skipFailures: true)
    let insuranceDeeplinkTypesTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceDeeplinkTypeTransformer(), skipFailures: true)
    let operationsCntTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let amountResult = dictionary[amountName].map(amountTransformer.transform(source:)) ?? .failure(.requirement)
        let addedResult = dictionary[addedName].map(addedTransformer.transform(source:)) ?? .failure(.requirement)
        let spentResult = dictionary[spentName].map(spentTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)
        let statusDescriptionResult = dictionary[statusDescriptionName].map(statusDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let nextStatusResult = nextStatusTransformer.transform(source: dictionary[nextStatusName])
        let nextStatusMoneyResult = dictionary[nextStatusMoneyName].map(nextStatusMoneyTransformer.transform(source:)) ?? .failure(.requirement)
        let nextStatusDescriptionResult = dictionary[nextStatusDescriptionName].map(nextStatusDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let hotlineDescriptionResult = hotlineDescriptionTransformer.transform(source: dictionary[hotlineDescriptionName])
        let hotlinePhoneResult = hotlinePhoneTransformer.transform(source: dictionary[hotlinePhoneName])
        let lastOperationsResult = dictionary[lastOperationsName].map(lastOperationsTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceDeeplinkTypesResult = dictionary[insuranceDeeplinkTypesName].map(insuranceDeeplinkTypesTransformer.transform(source:)) ?? .failure(.requirement)
        let operationsCntResult = dictionary[operationsCntName].map(operationsCntTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        amountResult.error.map { errors.append((amountName, $0)) }
        addedResult.error.map { errors.append((addedName, $0)) }
        spentResult.error.map { errors.append((spentName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusDescriptionResult.error.map { errors.append((statusDescriptionName, $0)) }
        nextStatusResult.error.map { errors.append((nextStatusName, $0)) }
        nextStatusMoneyResult.error.map { errors.append((nextStatusMoneyName, $0)) }
        nextStatusDescriptionResult.error.map { errors.append((nextStatusDescriptionName, $0)) }
        hotlineDescriptionResult.error.map { errors.append((hotlineDescriptionName, $0)) }
        hotlinePhoneResult.error.map { errors.append((hotlinePhoneName, $0)) }
        lastOperationsResult.error.map { errors.append((lastOperationsName, $0)) }
        insuranceDeeplinkTypesResult.error.map { errors.append((insuranceDeeplinkTypesName, $0)) }
        operationsCntResult.error.map { errors.append((operationsCntName, $0)) }

        guard
            let amount = amountResult.value,
            let added = addedResult.value,
            let spent = spentResult.value,
            let status = statusResult.value,
            let statusDescription = statusDescriptionResult.value,
            let nextStatus = nextStatusResult.value,
            let nextStatusMoney = nextStatusMoneyResult.value,
            let nextStatusDescription = nextStatusDescriptionResult.value,
            let hotlineDescription = hotlineDescriptionResult.value,
            let hotlinePhone = hotlinePhoneResult.value,
            let lastOperations = lastOperationsResult.value,
            let insuranceDeeplinkTypes = insuranceDeeplinkTypesResult.value,
            let operationsCnt = operationsCntResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                amount: amount,
                added: added,
                spent: spent,
                status: status,
                statusDescription: statusDescription,
                nextStatus: nextStatus,
                nextStatusMoney: nextStatusMoney,
                nextStatusDescription: nextStatusDescription,
                hotlineDescription: hotlineDescription,
                hotlinePhone: hotlinePhone,
                lastOperations: lastOperations,
                insuranceDeeplinkTypes: insuranceDeeplinkTypes,
                operationsCnt: operationsCnt
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let amountResult = amountTransformer.transform(destination: value.amount)
        let addedResult = addedTransformer.transform(destination: value.added)
        let spentResult = spentTransformer.transform(destination: value.spent)
        let statusResult = statusTransformer.transform(destination: value.status)
        let statusDescriptionResult = statusDescriptionTransformer.transform(destination: value.statusDescription)
        let nextStatusResult = nextStatusTransformer.transform(destination: value.nextStatus)
        let nextStatusMoneyResult = nextStatusMoneyTransformer.transform(destination: value.nextStatusMoney)
        let nextStatusDescriptionResult = nextStatusDescriptionTransformer.transform(destination: value.nextStatusDescription)
        let hotlineDescriptionResult = hotlineDescriptionTransformer.transform(destination: value.hotlineDescription)
        let hotlinePhoneResult = hotlinePhoneTransformer.transform(destination: value.hotlinePhone)
        let lastOperationsResult = lastOperationsTransformer.transform(destination: value.lastOperations)
        let insuranceDeeplinkTypesResult = insuranceDeeplinkTypesTransformer.transform(destination: value.insuranceDeeplinkTypes)
        let operationsCntResult = operationsCntTransformer.transform(destination: value.operationsCnt)

        var errors: [(String, TransformerError)] = []
        amountResult.error.map { errors.append((amountName, $0)) }
        addedResult.error.map { errors.append((addedName, $0)) }
        spentResult.error.map { errors.append((spentName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusDescriptionResult.error.map { errors.append((statusDescriptionName, $0)) }
        nextStatusResult.error.map { errors.append((nextStatusName, $0)) }
        nextStatusMoneyResult.error.map { errors.append((nextStatusMoneyName, $0)) }
        nextStatusDescriptionResult.error.map { errors.append((nextStatusDescriptionName, $0)) }
        hotlineDescriptionResult.error.map { errors.append((hotlineDescriptionName, $0)) }
        hotlinePhoneResult.error.map { errors.append((hotlinePhoneName, $0)) }
        lastOperationsResult.error.map { errors.append((lastOperationsName, $0)) }
        insuranceDeeplinkTypesResult.error.map { errors.append((insuranceDeeplinkTypesName, $0)) }
        operationsCntResult.error.map { errors.append((operationsCntName, $0)) }

        guard
            let amount = amountResult.value,
            let added = addedResult.value,
            let spent = spentResult.value,
            let status = statusResult.value,
            let statusDescription = statusDescriptionResult.value,
            let nextStatus = nextStatusResult.value,
            let nextStatusMoney = nextStatusMoneyResult.value,
            let nextStatusDescription = nextStatusDescriptionResult.value,
            let hotlineDescription = hotlineDescriptionResult.value,
            let hotlinePhone = hotlinePhoneResult.value,
            let lastOperations = lastOperationsResult.value,
            let insuranceDeeplinkTypes = insuranceDeeplinkTypesResult.value,
            let operationsCnt = operationsCntResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[amountName] = amount
        dictionary[addedName] = added
        dictionary[spentName] = spent
        dictionary[statusName] = status
        dictionary[statusDescriptionName] = statusDescription
        dictionary[nextStatusName] = nextStatus
        dictionary[nextStatusMoneyName] = nextStatusMoney
        dictionary[nextStatusDescriptionName] = nextStatusDescription
        dictionary[hotlineDescriptionName] = hotlineDescription
        dictionary[hotlinePhoneName] = hotlinePhone
        dictionary[lastOperationsName] = lastOperations
        dictionary[insuranceDeeplinkTypesName] = insuranceDeeplinkTypes
        dictionary[operationsCntName] = operationsCnt
        return .success(dictionary)
    }
}
