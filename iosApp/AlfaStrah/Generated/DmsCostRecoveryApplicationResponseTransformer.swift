// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryApplicationResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryApplicationResponse

    let applicationIdName = "request_id"
    let detailsName = "acceptance"

    let applicationIdTransformer = CastTransformer<Any, String>()
    let detailsTransformer = LinkedTextTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let applicationIdResult = dictionary[applicationIdName].map(applicationIdTransformer.transform(source:)) ?? .failure(.requirement)
        let detailsResult = dictionary[detailsName].map(detailsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        applicationIdResult.error.map { errors.append((applicationIdName, $0)) }
        detailsResult.error.map { errors.append((detailsName, $0)) }

        guard
            let applicationId = applicationIdResult.value,
            let details = detailsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                applicationId: applicationId,
                details: details
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let applicationIdResult = applicationIdTransformer.transform(destination: value.applicationId)
        let detailsResult = detailsTransformer.transform(destination: value.details)

        var errors: [(String, TransformerError)] = []
        applicationIdResult.error.map { errors.append((applicationIdName, $0)) }
        detailsResult.error.map { errors.append((detailsName, $0)) }

        guard
            let applicationId = applicationIdResult.value,
            let details = detailsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[applicationIdName] = applicationId
        dictionary[detailsName] = details
        return .success(dictionary)
    }
}
