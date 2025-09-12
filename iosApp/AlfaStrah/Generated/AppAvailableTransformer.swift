// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AppAvailableTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AppAvailable

    let statusName = "status"
    let messageName = "message"
    let titleName = "title"
    let linkName = "link"

    let statusTransformer = AppAvailableAvailabilityStatusTransformer()
    let messageTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let titleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let linkTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = messageTransformer.transform(source: dictionary[messageName])
        let titleResult = titleTransformer.transform(source: dictionary[titleName])
        let linkResult = linkTransformer.transform(source: dictionary[linkName])

        var errors: [(String, TransformerError)] = []
        statusResult.error.map { errors.append((statusName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        linkResult.error.map { errors.append((linkName, $0)) }

        guard
            let status = statusResult.value,
            let message = messageResult.value,
            let title = titleResult.value,
            let link = linkResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                status: status,
                message: message,
                title: title,
                link: link
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let statusResult = statusTransformer.transform(destination: value.status)
        let messageResult = messageTransformer.transform(destination: value.message)
        let titleResult = titleTransformer.transform(destination: value.title)
        let linkResult = linkTransformer.transform(destination: value.link)

        var errors: [(String, TransformerError)] = []
        statusResult.error.map { errors.append((statusName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        linkResult.error.map { errors.append((linkName, $0)) }

        guard
            let status = statusResult.value,
            let message = messageResult.value,
            let title = titleResult.value,
            let link = linkResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[statusName] = status
        dictionary[messageName] = message
        dictionary[titleName] = title
        dictionary[linkName] = link
        return .success(dictionary)
    }
}
