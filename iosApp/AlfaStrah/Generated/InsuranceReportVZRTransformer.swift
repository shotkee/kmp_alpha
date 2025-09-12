// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceReportVZRTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceReportVZR

    let idName = "event_report_id"
    let titleName = "title"
    let dateStringName = "title_date"
    let numberNoficationName = "title_number"
    let statusName = "status"
    let statusColorName = "status_color"
    let statusColorThemedName = "status_color_themed"

    let idTransformer = NumberTransformer<Any, Int64>()
    let titleTransformer = CastTransformer<Any, String>()
    let dateStringTransformer = CastTransformer<Any, String>()
    let numberNoficationTransformer = CastTransformer<Any, String>()
    let statusTransformer = CastTransformer<Any, String>()
    let statusColorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let statusColorThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let dateStringResult = dictionary[dateStringName].map(dateStringTransformer.transform(source:)) ?? .failure(.requirement)
        let numberNoficationResult = dictionary[numberNoficationName].map(numberNoficationTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)
        let statusColorResult = statusColorTransformer.transform(source: dictionary[statusColorName])
        let statusColorThemedResult = statusColorThemedTransformer.transform(source: dictionary[statusColorThemedName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        dateStringResult.error.map { errors.append((dateStringName, $0)) }
        numberNoficationResult.error.map { errors.append((numberNoficationName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusColorResult.error.map { errors.append((statusColorName, $0)) }
        statusColorThemedResult.error.map { errors.append((statusColorThemedName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let dateString = dateStringResult.value,
            let numberNofication = numberNoficationResult.value,
            let status = statusResult.value,
            let statusColor = statusColorResult.value,
            let statusColorThemed = statusColorThemedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                dateString: dateString,
                numberNofication: numberNofication,
                status: status,
                statusColor: statusColor,
                statusColorThemed: statusColorThemed
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let dateStringResult = dateStringTransformer.transform(destination: value.dateString)
        let numberNoficationResult = numberNoficationTransformer.transform(destination: value.numberNofication)
        let statusResult = statusTransformer.transform(destination: value.status)
        let statusColorResult = statusColorTransformer.transform(destination: value.statusColor)
        let statusColorThemedResult = statusColorThemedTransformer.transform(destination: value.statusColorThemed)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        dateStringResult.error.map { errors.append((dateStringName, $0)) }
        numberNoficationResult.error.map { errors.append((numberNoficationName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusColorResult.error.map { errors.append((statusColorName, $0)) }
        statusColorThemedResult.error.map { errors.append((statusColorThemedName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let dateString = dateStringResult.value,
            let numberNofication = numberNoficationResult.value,
            let status = statusResult.value,
            let statusColor = statusColorResult.value,
            let statusColorThemed = statusColorThemedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[dateStringName] = dateString
        dictionary[numberNoficationName] = numberNofication
        dictionary[statusName] = status
        dictionary[statusColorName] = statusColor
        dictionary[statusColorThemedName] = statusColorThemed
        return .success(dictionary)
    }
}
