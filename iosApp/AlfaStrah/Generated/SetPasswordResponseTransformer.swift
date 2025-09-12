// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SetPasswordResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SetPasswordResponse

    let successName = "success"
    let accountName = "account"
    let messageName = "message"

    let successTransformer = NumberTransformer<Any, Bool>()
    let accountTransformer = AccountTransformer()
    let messageTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let successResult = dictionary[successName].map(successTransformer.transform(source:)) ?? .failure(.requirement)
        let accountResult = dictionary[accountName].map(accountTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = dictionary[messageName].map(messageTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        successResult.error.map { errors.append((successName, $0)) }
        accountResult.error.map { errors.append((accountName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let success = successResult.value,
            let account = accountResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                success: success,
                account: account,
                message: message
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let successResult = successTransformer.transform(destination: value.success)
        let accountResult = accountTransformer.transform(destination: value.account)
        let messageResult = messageTransformer.transform(destination: value.message)

        var errors: [(String, TransformerError)] = []
        successResult.error.map { errors.append((successName, $0)) }
        accountResult.error.map { errors.append((accountName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let success = successResult.value,
            let account = accountResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[successName] = success
        dictionary[accountName] = account
        dictionary[messageName] = message
        return .success(dictionary)
    }
}
