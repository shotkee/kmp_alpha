// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryInsurancePlanTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryInsurancePlan

    let titleName = "title"
    let descriptionName = "description"
    let urlPathName = "pdf_url"

    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let urlPathTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let urlPathResult = dictionary[urlPathName].map(urlPathTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        urlPathResult.error.map { errors.append((urlPathName, $0)) }

        guard
            let title = titleResult.value,
            let description = descriptionResult.value,
            let urlPath = urlPathResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                description: description,
                urlPath: urlPath
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let urlPathResult = urlPathTransformer.transform(destination: value.urlPath)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        urlPathResult.error.map { errors.append((urlPathName, $0)) }

        guard
            let title = titleResult.value,
            let description = descriptionResult.value,
            let urlPath = urlPathResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[urlPathName] = urlPath
        return .success(dictionary)
    }
}
