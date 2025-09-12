// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceReportVZRDetailedTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceReportVZRDetailed

    let titleName = "title"
    let statusName = "status"
    let statusColorName = "status_color"
    let statusColorThemedName = "status_color_themed"
    let descriptionName = "description"
    let detailedContentName = "detailed_content"
    let urlName = "redirect_url"

    let titleTransformer = CastTransformer<Any, String>()
    let statusTransformer = CastTransformer<Any, String>()
    let statusColorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let statusColorThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let descriptionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let detailedContentTransformer = ArrayTransformer(from: Any.self, transformer: FieldListTransformer(), skipFailures: true)
    let urlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)
        let statusColorResult = statusColorTransformer.transform(source: dictionary[statusColorName])
        let statusColorThemedResult = statusColorThemedTransformer.transform(source: dictionary[statusColorThemedName])
        let descriptionResult = descriptionTransformer.transform(source: dictionary[descriptionName])
        let detailedContentResult = dictionary[detailedContentName].map(detailedContentTransformer.transform(source:)) ?? .failure(.requirement)
        let urlResult = urlTransformer.transform(source: dictionary[urlName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusColorResult.error.map { errors.append((statusColorName, $0)) }
        statusColorThemedResult.error.map { errors.append((statusColorThemedName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        detailedContentResult.error.map { errors.append((detailedContentName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let title = titleResult.value,
            let status = statusResult.value,
            let statusColor = statusColorResult.value,
            let statusColorThemed = statusColorThemedResult.value,
            let description = descriptionResult.value,
            let detailedContent = detailedContentResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                status: status,
                statusColor: statusColor,
                statusColorThemed: statusColorThemed,
                description: description,
                detailedContent: detailedContent,
                url: url
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let statusResult = statusTransformer.transform(destination: value.status)
        let statusColorResult = statusColorTransformer.transform(destination: value.statusColor)
        let statusColorThemedResult = statusColorThemedTransformer.transform(destination: value.statusColorThemed)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let detailedContentResult = detailedContentTransformer.transform(destination: value.detailedContent)
        let urlResult = urlTransformer.transform(destination: value.url)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusColorResult.error.map { errors.append((statusColorName, $0)) }
        statusColorThemedResult.error.map { errors.append((statusColorThemedName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        detailedContentResult.error.map { errors.append((detailedContentName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let title = titleResult.value,
            let status = statusResult.value,
            let statusColor = statusColorResult.value,
            let statusColorThemed = statusColorThemedResult.value,
            let description = descriptionResult.value,
            let detailedContent = detailedContentResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[statusName] = status
        dictionary[statusColorName] = statusColor
        dictionary[statusColorThemedName] = statusColorThemed
        dictionary[descriptionName] = description
        dictionary[detailedContentName] = detailedContent
        dictionary[urlName] = url
        return .success(dictionary)
    }
}
