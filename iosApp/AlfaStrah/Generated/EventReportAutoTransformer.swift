// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EventReportAutoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventReportAuto

    let idName = "id"
    let numberName = "number"
    let createDateName = "date"
    let sentDateName = "sent_date"
    let fullDescriptionName = "full_description"
    let filesName = "files"
    let eventTypeName = "type"
    let coordinateName = "coordinate"
    let insuranceIdName = "insurance_id"
    let isOpenedName = "is_opened"
    let documentsName = "documents"
    let addressName = "address"
    let requisitesName = "requisites"
    let statusesName = "statuses"

    let idTransformer = IdTransformer<Any>()
    let numberTransformer = IdTransformer<Any>()
    let createDateTransformer = TimestampTransformer<Any>(scale: 1)
    let sentDateTransformer = TimestampTransformer<Any>(scale: 1)
    let fullDescriptionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let filesTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: FilePreviewTransformer(), skipFailures: true))
    let eventTypeTransformer = EventTypeTransformer()
    let coordinateTransformer = OptionalTransformer(transformer: CoordinateTransformer())
    let insuranceIdTransformer = IdTransformer<Any>()
    let isOpenedTransformer = NumberTransformer<Any, Bool>()
    let documentsTransformer = ArrayTransformer(from: Any.self, transformer: EventReportAutoDocumentTransformer(), skipFailures: true)
    let addressTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let requisitesTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let statusesTransformer = ArrayTransformer(from: Any.self, transformer: EventStatusTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let createDateResult = dictionary[createDateName].map(createDateTransformer.transform(source:)) ?? .failure(.requirement)
        let sentDateResult = dictionary[sentDateName].map(sentDateTransformer.transform(source:)) ?? .failure(.requirement)
        let fullDescriptionResult = fullDescriptionTransformer.transform(source: dictionary[fullDescriptionName])
        let filesResult = filesTransformer.transform(source: dictionary[filesName])
        let eventTypeResult = dictionary[eventTypeName].map(eventTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let coordinateResult = coordinateTransformer.transform(source: dictionary[coordinateName])
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let isOpenedResult = dictionary[isOpenedName].map(isOpenedTransformer.transform(source:)) ?? .failure(.requirement)
        let documentsResult = dictionary[documentsName].map(documentsTransformer.transform(source:)) ?? .failure(.requirement)
        let addressResult = addressTransformer.transform(source: dictionary[addressName])
        let requisitesResult = requisitesTransformer.transform(source: dictionary[requisitesName])
        let statusesResult = dictionary[statusesName].map(statusesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        createDateResult.error.map { errors.append((createDateName, $0)) }
        sentDateResult.error.map { errors.append((sentDateName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        filesResult.error.map { errors.append((filesName, $0)) }
        eventTypeResult.error.map { errors.append((eventTypeName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        isOpenedResult.error.map { errors.append((isOpenedName, $0)) }
        documentsResult.error.map { errors.append((documentsName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        requisitesResult.error.map { errors.append((requisitesName, $0)) }
        statusesResult.error.map { errors.append((statusesName, $0)) }

        guard
            let id = idResult.value,
            let number = numberResult.value,
            let createDate = createDateResult.value,
            let sentDate = sentDateResult.value,
            let fullDescription = fullDescriptionResult.value,
            let files = filesResult.value,
            let eventType = eventTypeResult.value,
            let coordinate = coordinateResult.value,
            let insuranceId = insuranceIdResult.value,
            let isOpened = isOpenedResult.value,
            let documents = documentsResult.value,
            let address = addressResult.value,
            let requisites = requisitesResult.value,
            let statuses = statusesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                number: number,
                createDate: createDate,
                sentDate: sentDate,
                fullDescription: fullDescription,
                files: files,
                eventType: eventType,
                coordinate: coordinate,
                insuranceId: insuranceId,
                isOpened: isOpened,
                documents: documents,
                address: address,
                requisites: requisites,
                statuses: statuses
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let numberResult = numberTransformer.transform(destination: value.number)
        let createDateResult = createDateTransformer.transform(destination: value.createDate)
        let sentDateResult = sentDateTransformer.transform(destination: value.sentDate)
        let fullDescriptionResult = fullDescriptionTransformer.transform(destination: value.fullDescription)
        let filesResult = filesTransformer.transform(destination: value.files)
        let eventTypeResult = eventTypeTransformer.transform(destination: value.eventType)
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let isOpenedResult = isOpenedTransformer.transform(destination: value.isOpened)
        let documentsResult = documentsTransformer.transform(destination: value.documents)
        let addressResult = addressTransformer.transform(destination: value.address)
        let requisitesResult = requisitesTransformer.transform(destination: value.requisites)
        let statusesResult = statusesTransformer.transform(destination: value.statuses)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        createDateResult.error.map { errors.append((createDateName, $0)) }
        sentDateResult.error.map { errors.append((sentDateName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        filesResult.error.map { errors.append((filesName, $0)) }
        eventTypeResult.error.map { errors.append((eventTypeName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        isOpenedResult.error.map { errors.append((isOpenedName, $0)) }
        documentsResult.error.map { errors.append((documentsName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        requisitesResult.error.map { errors.append((requisitesName, $0)) }
        statusesResult.error.map { errors.append((statusesName, $0)) }

        guard
            let id = idResult.value,
            let number = numberResult.value,
            let createDate = createDateResult.value,
            let sentDate = sentDateResult.value,
            let fullDescription = fullDescriptionResult.value,
            let files = filesResult.value,
            let eventType = eventTypeResult.value,
            let coordinate = coordinateResult.value,
            let insuranceId = insuranceIdResult.value,
            let isOpened = isOpenedResult.value,
            let documents = documentsResult.value,
            let address = addressResult.value,
            let requisites = requisitesResult.value,
            let statuses = statusesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[numberName] = number
        dictionary[createDateName] = createDate
        dictionary[sentDateName] = sentDate
        dictionary[fullDescriptionName] = fullDescription
        dictionary[filesName] = files
        dictionary[eventTypeName] = eventType
        dictionary[coordinateName] = coordinate
        dictionary[insuranceIdName] = insuranceId
        dictionary[isOpenedName] = isOpened
        dictionary[documentsName] = documents
        dictionary[addressName] = address
        dictionary[requisitesName] = requisites
        dictionary[statusesName] = statuses
        return .success(dictionary)
    }
}
