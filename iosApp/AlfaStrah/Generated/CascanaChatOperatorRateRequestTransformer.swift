// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CascanaChatOperatorRateRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CascanaChatOperatorRateRequest

    let requestIdName = "RequestId"
    let rateName = "Score"
    let commentName = "Comment"
    let senderIdName = "OperatorId"

    let requestIdTransformer = CastTransformer<Any, String>()
    let rateTransformer = NumberTransformer<Any, Int>()
    let commentTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let senderIdTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let requestIdResult = dictionary[requestIdName].map(requestIdTransformer.transform(source:)) ?? .failure(.requirement)
        let rateResult = dictionary[rateName].map(rateTransformer.transform(source:)) ?? .failure(.requirement)
        let commentResult = commentTransformer.transform(source: dictionary[commentName])
        let senderIdResult = senderIdTransformer.transform(source: dictionary[senderIdName])

        var errors: [(String, TransformerError)] = []
        requestIdResult.error.map { errors.append((requestIdName, $0)) }
        rateResult.error.map { errors.append((rateName, $0)) }
        commentResult.error.map { errors.append((commentName, $0)) }
        senderIdResult.error.map { errors.append((senderIdName, $0)) }

        guard
            let requestId = requestIdResult.value,
            let rate = rateResult.value,
            let comment = commentResult.value,
            let senderId = senderIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                requestId: requestId,
                rate: rate,
                comment: comment,
                senderId: senderId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let requestIdResult = requestIdTransformer.transform(destination: value.requestId)
        let rateResult = rateTransformer.transform(destination: value.rate)
        let commentResult = commentTransformer.transform(destination: value.comment)
        let senderIdResult = senderIdTransformer.transform(destination: value.senderId)

        var errors: [(String, TransformerError)] = []
        requestIdResult.error.map { errors.append((requestIdName, $0)) }
        rateResult.error.map { errors.append((rateName, $0)) }
        commentResult.error.map { errors.append((commentName, $0)) }
        senderIdResult.error.map { errors.append((senderIdName, $0)) }

        guard
            let requestId = requestIdResult.value,
            let rate = rateResult.value,
            let comment = commentResult.value,
            let senderId = senderIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[requestIdName] = requestId
        dictionary[rateName] = rate
        dictionary[commentName] = comment
        dictionary[senderIdName] = senderId
        return .success(dictionary)
    }
}
