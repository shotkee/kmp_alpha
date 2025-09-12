// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceBillTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceBill

    let idName = "id"
    let recipientNameName = "user_name"
    let numberName = "bill_number"
    let infoName = "bill_info"
    let statusTextName = "status"
    let creationDateName = "date"
    let moneyAmountName = "amount"
    let descriptionName = "description"
    let shouldBePaidOffName = "is_payment_needed"
    let canBePaidInGroupName = "can_be_group_paid"
    let canSubmitDisagreementName = "can_create_not_agreed"
    let paymentDateName = "date_paid"
    let highlightingName = "highlighted_type"

    let idTransformer = NumberTransformer<Any, Int>()
    let recipientNameTransformer = CastTransformer<Any, String>()
    let numberTransformer = CastTransformer<Any, String>()
    let infoTransformer = CastTransformer<Any, String>()
    let statusTextTransformer = CastTransformer<Any, String>()
    let creationDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let moneyAmountTransformer = NumberTransformer<Any, Double>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let shouldBePaidOffTransformer = NumberTransformer<Any, Bool>()
    let canBePaidInGroupTransformer = NumberTransformer<Any, Bool>()
    let canSubmitDisagreementTransformer = NumberTransformer<Any, Bool>()
    let paymentDateTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "dd/MM/yyyy", locale: AppLocale.currentLocale))
    let highlightingTransformer = InsuranceBillHighlightingTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let recipientNameResult = dictionary[recipientNameName].map(recipientNameTransformer.transform(source:)) ?? .failure(.requirement)
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let infoResult = dictionary[infoName].map(infoTransformer.transform(source:)) ?? .failure(.requirement)
        let statusTextResult = dictionary[statusTextName].map(statusTextTransformer.transform(source:)) ?? .failure(.requirement)
        let creationDateResult = dictionary[creationDateName].map(creationDateTransformer.transform(source:)) ?? .failure(.requirement)
        let moneyAmountResult = dictionary[moneyAmountName].map(moneyAmountTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let shouldBePaidOffResult = dictionary[shouldBePaidOffName].map(shouldBePaidOffTransformer.transform(source:)) ?? .failure(.requirement)
        let canBePaidInGroupResult = dictionary[canBePaidInGroupName].map(canBePaidInGroupTransformer.transform(source:)) ?? .failure(.requirement)
        let canSubmitDisagreementResult = dictionary[canSubmitDisagreementName].map(canSubmitDisagreementTransformer.transform(source:)) ?? .failure(.requirement)
        let paymentDateResult = paymentDateTransformer.transform(source: dictionary[paymentDateName])
        let highlightingResult = dictionary[highlightingName].map(highlightingTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        recipientNameResult.error.map { errors.append((recipientNameName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        infoResult.error.map { errors.append((infoName, $0)) }
        statusTextResult.error.map { errors.append((statusTextName, $0)) }
        creationDateResult.error.map { errors.append((creationDateName, $0)) }
        moneyAmountResult.error.map { errors.append((moneyAmountName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        shouldBePaidOffResult.error.map { errors.append((shouldBePaidOffName, $0)) }
        canBePaidInGroupResult.error.map { errors.append((canBePaidInGroupName, $0)) }
        canSubmitDisagreementResult.error.map { errors.append((canSubmitDisagreementName, $0)) }
        paymentDateResult.error.map { errors.append((paymentDateName, $0)) }
        highlightingResult.error.map { errors.append((highlightingName, $0)) }

        guard
            let id = idResult.value,
            let recipientName = recipientNameResult.value,
            let number = numberResult.value,
            let info = infoResult.value,
            let statusText = statusTextResult.value,
            let creationDate = creationDateResult.value,
            let moneyAmount = moneyAmountResult.value,
            let description = descriptionResult.value,
            let shouldBePaidOff = shouldBePaidOffResult.value,
            let canBePaidInGroup = canBePaidInGroupResult.value,
            let canSubmitDisagreement = canSubmitDisagreementResult.value,
            let paymentDate = paymentDateResult.value,
            let highlighting = highlightingResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                recipientName: recipientName,
                number: number,
                info: info,
                statusText: statusText,
                creationDate: creationDate,
                moneyAmount: moneyAmount,
                description: description,
                shouldBePaidOff: shouldBePaidOff,
                canBePaidInGroup: canBePaidInGroup,
                canSubmitDisagreement: canSubmitDisagreement,
                paymentDate: paymentDate,
                highlighting: highlighting
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let recipientNameResult = recipientNameTransformer.transform(destination: value.recipientName)
        let numberResult = numberTransformer.transform(destination: value.number)
        let infoResult = infoTransformer.transform(destination: value.info)
        let statusTextResult = statusTextTransformer.transform(destination: value.statusText)
        let creationDateResult = creationDateTransformer.transform(destination: value.creationDate)
        let moneyAmountResult = moneyAmountTransformer.transform(destination: value.moneyAmount)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let shouldBePaidOffResult = shouldBePaidOffTransformer.transform(destination: value.shouldBePaidOff)
        let canBePaidInGroupResult = canBePaidInGroupTransformer.transform(destination: value.canBePaidInGroup)
        let canSubmitDisagreementResult = canSubmitDisagreementTransformer.transform(destination: value.canSubmitDisagreement)
        let paymentDateResult = paymentDateTransformer.transform(destination: value.paymentDate)
        let highlightingResult = highlightingTransformer.transform(destination: value.highlighting)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        recipientNameResult.error.map { errors.append((recipientNameName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        infoResult.error.map { errors.append((infoName, $0)) }
        statusTextResult.error.map { errors.append((statusTextName, $0)) }
        creationDateResult.error.map { errors.append((creationDateName, $0)) }
        moneyAmountResult.error.map { errors.append((moneyAmountName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        shouldBePaidOffResult.error.map { errors.append((shouldBePaidOffName, $0)) }
        canBePaidInGroupResult.error.map { errors.append((canBePaidInGroupName, $0)) }
        canSubmitDisagreementResult.error.map { errors.append((canSubmitDisagreementName, $0)) }
        paymentDateResult.error.map { errors.append((paymentDateName, $0)) }
        highlightingResult.error.map { errors.append((highlightingName, $0)) }

        guard
            let id = idResult.value,
            let recipientName = recipientNameResult.value,
            let number = numberResult.value,
            let info = infoResult.value,
            let statusText = statusTextResult.value,
            let creationDate = creationDateResult.value,
            let moneyAmount = moneyAmountResult.value,
            let description = descriptionResult.value,
            let shouldBePaidOff = shouldBePaidOffResult.value,
            let canBePaidInGroup = canBePaidInGroupResult.value,
            let canSubmitDisagreement = canSubmitDisagreementResult.value,
            let paymentDate = paymentDateResult.value,
            let highlighting = highlightingResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[recipientNameName] = recipientName
        dictionary[numberName] = number
        dictionary[infoName] = info
        dictionary[statusTextName] = statusText
        dictionary[creationDateName] = creationDate
        dictionary[moneyAmountName] = moneyAmount
        dictionary[descriptionName] = description
        dictionary[shouldBePaidOffName] = shouldBePaidOff
        dictionary[canBePaidInGroupName] = canBePaidInGroup
        dictionary[canSubmitDisagreementName] = canSubmitDisagreement
        dictionary[paymentDateName] = paymentDate
        dictionary[highlightingName] = highlighting
        return .success(dictionary)
    }
}
