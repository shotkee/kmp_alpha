// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AppointmentStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AppointmentStatus

    let statusTitleName = "status_title"
    let titleName = "title"
    let backgroundColorName = "background_color"

    let statusTitleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let titleTransformer = ThemedTextTransformer()
    let backgroundColorTransformer = ThemedValueTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let statusTitleResult = statusTitleTransformer.transform(source: dictionary[statusTitleName])
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let backgroundColorResult = dictionary[backgroundColorName].map(backgroundColorTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        statusTitleResult.error.map { errors.append((statusTitleName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        backgroundColorResult.error.map { errors.append((backgroundColorName, $0)) }

        guard
            let statusTitle = statusTitleResult.value,
            let title = titleResult.value,
            let backgroundColor = backgroundColorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                statusTitle: statusTitle,
                title: title,
                backgroundColor: backgroundColor
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let statusTitleResult = statusTitleTransformer.transform(destination: value.statusTitle)
        let titleResult = titleTransformer.transform(destination: value.title)
        let backgroundColorResult = backgroundColorTransformer.transform(destination: value.backgroundColor)

        var errors: [(String, TransformerError)] = []
        statusTitleResult.error.map { errors.append((statusTitleName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        backgroundColorResult.error.map { errors.append((backgroundColorName, $0)) }

        guard
            let statusTitle = statusTitleResult.value,
            let title = titleResult.value,
            let backgroundColor = backgroundColorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[statusTitleName] = statusTitle
        dictionary[titleName] = title
        dictionary[backgroundColorName] = backgroundColor
        return .success(dictionary)
    }
}
