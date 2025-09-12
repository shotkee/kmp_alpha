// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AppNotificationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AppNotification

    let idName = "id"
    let typeName = "type"
    let titleName = "title"
    let annotationName = "annotation"
    let fullTextName = "full_text"
    let dateName = "date"
    let importantName = "important"
    let insuranceIdName = "insurance_id"
    let stoaName = "stoa"
    let offlineAppointmentIdName = "appointment_id"
    let fieldListName = "field_list"
    let phoneName = "phone"
    let userRequestDateName = "user_request_date"
    let eventNumberName = "event_number"
    let onlineAppointmentIdName = "doctor_visit_id"
    let isReadName = "is_read"
    let urlName = "url"
    let targetName = "target"

    let idTransformer = IdTransformer<Any>()
    let typeTransformer = AppNotificationKindTransformer()
    let titleTransformer = CastTransformer<Any, String>()
    let annotationTransformer = CastTransformer<Any, String>()
    let fullTextTransformer = CastTransformer<Any, String>()
    let dateTransformer = TimestampTransformer<Any>(scale: 1)
    let importantTransformer = NumberTransformer<Any, Bool>()
    let insuranceIdTransformer = CastTransformer<Any, String>()
    let stoaTransformer = OptionalTransformer(transformer: StoaTransformer())
    let offlineAppointmentIdTransformer = OptionalTransformer(transformer: IdTransformer<Any>())
    let fieldListTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: AppNotificationFieldTransformer(), skipFailures: true))
    let phoneTransformer = OptionalTransformer(transformer: PhoneTransformer())
    let userRequestDateTransformer = OptionalTransformer(transformer: TimestampTransformer<Any>(scale: 1))
    let eventNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let onlineAppointmentIdTransformer = OptionalTransformer(transformer: IdTransformer<Any>())
    let isReadTransformer = NumberTransformer<Any, Bool>()
    let urlTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let targetTransformer = DeeplinkDestinationTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let annotationResult = dictionary[annotationName].map(annotationTransformer.transform(source:)) ?? .failure(.requirement)
        let fullTextResult = dictionary[fullTextName].map(fullTextTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let importantResult = dictionary[importantName].map(importantTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let stoaResult = stoaTransformer.transform(source: dictionary[stoaName])
        let offlineAppointmentIdResult = offlineAppointmentIdTransformer.transform(source: dictionary[offlineAppointmentIdName])
        let fieldListResult = fieldListTransformer.transform(source: dictionary[fieldListName])
        let phoneResult = phoneTransformer.transform(source: dictionary[phoneName])
        let userRequestDateResult = userRequestDateTransformer.transform(source: dictionary[userRequestDateName])
        let eventNumberResult = eventNumberTransformer.transform(source: dictionary[eventNumberName])
        let onlineAppointmentIdResult = onlineAppointmentIdTransformer.transform(source: dictionary[onlineAppointmentIdName])
        let isReadResult = dictionary[isReadName].map(isReadTransformer.transform(source:)) ?? .failure(.requirement)
        let urlResult = urlTransformer.transform(source: dictionary[urlName])
        let targetResult = dictionary[targetName].map(targetTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        annotationResult.error.map { errors.append((annotationName, $0)) }
        fullTextResult.error.map { errors.append((fullTextName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        importantResult.error.map { errors.append((importantName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        stoaResult.error.map { errors.append((stoaName, $0)) }
        offlineAppointmentIdResult.error.map { errors.append((offlineAppointmentIdName, $0)) }
        fieldListResult.error.map { errors.append((fieldListName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        userRequestDateResult.error.map { errors.append((userRequestDateName, $0)) }
        eventNumberResult.error.map { errors.append((eventNumberName, $0)) }
        onlineAppointmentIdResult.error.map { errors.append((onlineAppointmentIdName, $0)) }
        isReadResult.error.map { errors.append((isReadName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }
        targetResult.error.map { errors.append((targetName, $0)) }

        guard
            let id = idResult.value,
            let type = typeResult.value,
            let title = titleResult.value,
            let annotation = annotationResult.value,
            let fullText = fullTextResult.value,
            let date = dateResult.value,
            let important = importantResult.value,
            let insuranceId = insuranceIdResult.value,
            let stoa = stoaResult.value,
            let offlineAppointmentId = offlineAppointmentIdResult.value,
            let fieldList = fieldListResult.value,
            let phone = phoneResult.value,
            let userRequestDate = userRequestDateResult.value,
            let eventNumber = eventNumberResult.value,
            let onlineAppointmentId = onlineAppointmentIdResult.value,
            let isRead = isReadResult.value,
            let url = urlResult.value,
            let target = targetResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                type: type,
                title: title,
                annotation: annotation,
                fullText: fullText,
                date: date,
                important: important,
                insuranceId: insuranceId,
                stoa: stoa,
                offlineAppointmentId: offlineAppointmentId,
                fieldList: fieldList,
                phone: phone,
                userRequestDate: userRequestDate,
                eventNumber: eventNumber,
                onlineAppointmentId: onlineAppointmentId,
                isRead: isRead,
                url: url,
                target: target
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let typeResult = typeTransformer.transform(destination: value.type)
        let titleResult = titleTransformer.transform(destination: value.title)
        let annotationResult = annotationTransformer.transform(destination: value.annotation)
        let fullTextResult = fullTextTransformer.transform(destination: value.fullText)
        let dateResult = dateTransformer.transform(destination: value.date)
        let importantResult = importantTransformer.transform(destination: value.important)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let stoaResult = stoaTransformer.transform(destination: value.stoa)
        let offlineAppointmentIdResult = offlineAppointmentIdTransformer.transform(destination: value.offlineAppointmentId)
        let fieldListResult = fieldListTransformer.transform(destination: value.fieldList)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let userRequestDateResult = userRequestDateTransformer.transform(destination: value.userRequestDate)
        let eventNumberResult = eventNumberTransformer.transform(destination: value.eventNumber)
        let onlineAppointmentIdResult = onlineAppointmentIdTransformer.transform(destination: value.onlineAppointmentId)
        let isReadResult = isReadTransformer.transform(destination: value.isRead)
        let urlResult = urlTransformer.transform(destination: value.url)
        let targetResult = targetTransformer.transform(destination: value.target)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        annotationResult.error.map { errors.append((annotationName, $0)) }
        fullTextResult.error.map { errors.append((fullTextName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        importantResult.error.map { errors.append((importantName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        stoaResult.error.map { errors.append((stoaName, $0)) }
        offlineAppointmentIdResult.error.map { errors.append((offlineAppointmentIdName, $0)) }
        fieldListResult.error.map { errors.append((fieldListName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        userRequestDateResult.error.map { errors.append((userRequestDateName, $0)) }
        eventNumberResult.error.map { errors.append((eventNumberName, $0)) }
        onlineAppointmentIdResult.error.map { errors.append((onlineAppointmentIdName, $0)) }
        isReadResult.error.map { errors.append((isReadName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }
        targetResult.error.map { errors.append((targetName, $0)) }

        guard
            let id = idResult.value,
            let type = typeResult.value,
            let title = titleResult.value,
            let annotation = annotationResult.value,
            let fullText = fullTextResult.value,
            let date = dateResult.value,
            let important = importantResult.value,
            let insuranceId = insuranceIdResult.value,
            let stoa = stoaResult.value,
            let offlineAppointmentId = offlineAppointmentIdResult.value,
            let fieldList = fieldListResult.value,
            let phone = phoneResult.value,
            let userRequestDate = userRequestDateResult.value,
            let eventNumber = eventNumberResult.value,
            let onlineAppointmentId = onlineAppointmentIdResult.value,
            let isRead = isReadResult.value,
            let url = urlResult.value,
            let target = targetResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[typeName] = type
        dictionary[titleName] = title
        dictionary[annotationName] = annotation
        dictionary[fullTextName] = fullText
        dictionary[dateName] = date
        dictionary[importantName] = important
        dictionary[insuranceIdName] = insuranceId
        dictionary[stoaName] = stoa
        dictionary[offlineAppointmentIdName] = offlineAppointmentId
        dictionary[fieldListName] = fieldList
        dictionary[phoneName] = phone
        dictionary[userRequestDateName] = userRequestDate
        dictionary[eventNumberName] = eventNumber
        dictionary[onlineAppointmentIdName] = onlineAppointmentId
        dictionary[isReadName] = isRead
        dictionary[urlName] = url
        dictionary[targetName] = target
        return .success(dictionary)
    }
}
