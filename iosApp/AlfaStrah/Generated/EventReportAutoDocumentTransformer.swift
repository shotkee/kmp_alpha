// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EventReportAutoDocumentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventReportAutoDocument

    let titleName = "title"
    let urlName = "url"

    let titleTransformer = CastTransformer<Any, String>()
    let urlTransformer = UrlTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let urlResult = dictionary[urlName].map(urlTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let title = titleResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                url: url
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let urlResult = urlTransformer.transform(destination: value.url)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let title = titleResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[urlName] = url
        return .success(dictionary)
    }
}
