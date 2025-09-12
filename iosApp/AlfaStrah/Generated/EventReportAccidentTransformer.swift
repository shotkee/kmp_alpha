// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EventReportAccidentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventReportAccident

    let idName = "id"
    let titleName = "title"
    let numberName = "number"
    let createDateName = "date"
    let insuranceIdName = "insurance_id"
    let statusKindName = "status_id"
    let statusName = "status"
    let statusDescriptionName = "status_description"
    let eventName = "event"
    let photoUploadedName = "photo_cnt"
    let isOpenedName = "is_opened"
    let canAddPhotosName = "allow_attach_optional"
    let canEditPayoutName = "allow_change_payout"
    let bikName = "bik"
    let accountNumberName = "account_number"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let numberTransformer = IdTransformer<Any>()
    let createDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let insuranceIdTransformer = IdTransformer<Any>()
    let statusKindTransformer = EventReportAccidentStatusKindTransformer()
    let statusTransformer = CastTransformer<Any, String>()
    let statusDescriptionTransformer = CastTransformer<Any, String>()
    let eventTransformer = CastTransformer<Any, String>()
    let photoUploadedTransformer = NumberTransformer<Any, Int>()
    let isOpenedTransformer = NumberTransformer<Any, Bool>()
    let canAddPhotosTransformer = NumberTransformer<Any, Bool>()
    let canEditPayoutTransformer = NumberTransformer<Any, Bool>()
    let bikTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let accountNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let createDateResult = dictionary[createDateName].map(createDateTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let statusKindResult = dictionary[statusKindName].map(statusKindTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)
        let statusDescriptionResult = dictionary[statusDescriptionName].map(statusDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let eventResult = dictionary[eventName].map(eventTransformer.transform(source:)) ?? .failure(.requirement)
        let photoUploadedResult = dictionary[photoUploadedName].map(photoUploadedTransformer.transform(source:)) ?? .failure(.requirement)
        let isOpenedResult = dictionary[isOpenedName].map(isOpenedTransformer.transform(source:)) ?? .failure(.requirement)
        let canAddPhotosResult = dictionary[canAddPhotosName].map(canAddPhotosTransformer.transform(source:)) ?? .failure(.requirement)
        let canEditPayoutResult = dictionary[canEditPayoutName].map(canEditPayoutTransformer.transform(source:)) ?? .failure(.requirement)
        let bikResult = bikTransformer.transform(source: dictionary[bikName])
        let accountNumberResult = accountNumberTransformer.transform(source: dictionary[accountNumberName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        createDateResult.error.map { errors.append((createDateName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        statusKindResult.error.map { errors.append((statusKindName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusDescriptionResult.error.map { errors.append((statusDescriptionName, $0)) }
        eventResult.error.map { errors.append((eventName, $0)) }
        photoUploadedResult.error.map { errors.append((photoUploadedName, $0)) }
        isOpenedResult.error.map { errors.append((isOpenedName, $0)) }
        canAddPhotosResult.error.map { errors.append((canAddPhotosName, $0)) }
        canEditPayoutResult.error.map { errors.append((canEditPayoutName, $0)) }
        bikResult.error.map { errors.append((bikName, $0)) }
        accountNumberResult.error.map { errors.append((accountNumberName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let number = numberResult.value,
            let createDate = createDateResult.value,
            let insuranceId = insuranceIdResult.value,
            let statusKind = statusKindResult.value,
            let status = statusResult.value,
            let statusDescription = statusDescriptionResult.value,
            let event = eventResult.value,
            let photoUploaded = photoUploadedResult.value,
            let isOpened = isOpenedResult.value,
            let canAddPhotos = canAddPhotosResult.value,
            let canEditPayout = canEditPayoutResult.value,
            let bik = bikResult.value,
            let accountNumber = accountNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                number: number,
                createDate: createDate,
                insuranceId: insuranceId,
                statusKind: statusKind,
                status: status,
                statusDescription: statusDescription,
                event: event,
                photoUploaded: photoUploaded,
                isOpened: isOpened,
                canAddPhotos: canAddPhotos,
                canEditPayout: canEditPayout,
                bik: bik,
                accountNumber: accountNumber
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let numberResult = numberTransformer.transform(destination: value.number)
        let createDateResult = createDateTransformer.transform(destination: value.createDate)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let statusKindResult = statusKindTransformer.transform(destination: value.statusKind)
        let statusResult = statusTransformer.transform(destination: value.status)
        let statusDescriptionResult = statusDescriptionTransformer.transform(destination: value.statusDescription)
        let eventResult = eventTransformer.transform(destination: value.event)
        let photoUploadedResult = photoUploadedTransformer.transform(destination: value.photoUploaded)
        let isOpenedResult = isOpenedTransformer.transform(destination: value.isOpened)
        let canAddPhotosResult = canAddPhotosTransformer.transform(destination: value.canAddPhotos)
        let canEditPayoutResult = canEditPayoutTransformer.transform(destination: value.canEditPayout)
        let bikResult = bikTransformer.transform(destination: value.bik)
        let accountNumberResult = accountNumberTransformer.transform(destination: value.accountNumber)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        createDateResult.error.map { errors.append((createDateName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        statusKindResult.error.map { errors.append((statusKindName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusDescriptionResult.error.map { errors.append((statusDescriptionName, $0)) }
        eventResult.error.map { errors.append((eventName, $0)) }
        photoUploadedResult.error.map { errors.append((photoUploadedName, $0)) }
        isOpenedResult.error.map { errors.append((isOpenedName, $0)) }
        canAddPhotosResult.error.map { errors.append((canAddPhotosName, $0)) }
        canEditPayoutResult.error.map { errors.append((canEditPayoutName, $0)) }
        bikResult.error.map { errors.append((bikName, $0)) }
        accountNumberResult.error.map { errors.append((accountNumberName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let number = numberResult.value,
            let createDate = createDateResult.value,
            let insuranceId = insuranceIdResult.value,
            let statusKind = statusKindResult.value,
            let status = statusResult.value,
            let statusDescription = statusDescriptionResult.value,
            let event = eventResult.value,
            let photoUploaded = photoUploadedResult.value,
            let isOpened = isOpenedResult.value,
            let canAddPhotos = canAddPhotosResult.value,
            let canEditPayout = canEditPayoutResult.value,
            let bik = bikResult.value,
            let accountNumber = accountNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[numberName] = number
        dictionary[createDateName] = createDate
        dictionary[insuranceIdName] = insuranceId
        dictionary[statusKindName] = statusKind
        dictionary[statusName] = status
        dictionary[statusDescriptionName] = statusDescription
        dictionary[eventName] = event
        dictionary[photoUploadedName] = photoUploaded
        dictionary[isOpenedName] = isOpened
        dictionary[canAddPhotosName] = canAddPhotos
        dictionary[canEditPayoutName] = canEditPayout
        dictionary[bikName] = bik
        dictionary[accountNumberName] = accountNumber
        return .success(dictionary)
    }
}
