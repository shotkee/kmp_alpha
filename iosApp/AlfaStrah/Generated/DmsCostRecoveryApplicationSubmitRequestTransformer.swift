// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryApplicationSubmitRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryApplicationSubmitRequest

    let applicationIdName = "request_id"
    let requestName = "file_id_list"

    let applicationIdTransformer = CastTransformer<Any, String>()
    let requestTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let applicationIdResult = dictionary[applicationIdName].map(applicationIdTransformer.transform(source:)) ?? .failure(.requirement)
        let requestResult = dictionary[requestName].map(requestTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        applicationIdResult.error.map { errors.append((applicationIdName, $0)) }
        requestResult.error.map { errors.append((requestName, $0)) }

        guard
            let applicationId = applicationIdResult.value,
            let request = requestResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                applicationId: applicationId,
                request: request
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let applicationIdResult = applicationIdTransformer.transform(destination: value.applicationId)
        let requestResult = requestTransformer.transform(destination: value.request)

        var errors: [(String, TransformerError)] = []
        applicationIdResult.error.map { errors.append((applicationIdName, $0)) }
        requestResult.error.map { errors.append((requestName, $0)) }

        guard
            let applicationId = applicationIdResult.value,
            let request = requestResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[applicationIdName] = applicationId
        dictionary[requestName] = request
        return .success(dictionary)
    }
}
