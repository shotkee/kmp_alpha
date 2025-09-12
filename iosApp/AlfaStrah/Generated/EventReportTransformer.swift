// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EventReportTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventReport

    let idName = "id"
    let numberName = "number"
    let createDateName = "date"
    let sentDateName = "sent_date"
    let fullDescriptionName = "full_description"
    let filesName = "files"
    let eventTypeName = "type"
    let coordinateName = "coordinate"
    let insuranceIdName = "insurance_id"

    let idTransformer = IdTransformer<Any>()
    let numberTransformer = IdTransformer<Any>()
    let createDateTransformer = TimestampTransformer<Any>(scale: 1)
    let sentDateTransformer = TimestampTransformer<Any>(scale: 1)
    let fullDescriptionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let filesTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: FilePreviewTransformer(), skipFailures: true))
    let eventTypeTransformer = EventTypeTransformer()
    let coordinateTransformer = OptionalTransformer(transformer: CoordinateTransformer())
    let insuranceIdTransformer = IdTransformer<Any>()

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
                insuranceId: insuranceId
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
        return .success(dictionary)
    }
}
