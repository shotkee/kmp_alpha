// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AuthorizationResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AuthorizationResponse

    let sessionName = "session"
    let accountName = "account"

    let sessionTransformer = UserSessionTransformer()
    let accountTransformer = AccountTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let sessionResult = dictionary[sessionName].map(sessionTransformer.transform(source:)) ?? .failure(.requirement)
        let accountResult = dictionary[accountName].map(accountTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        sessionResult.error.map { errors.append((sessionName, $0)) }
        accountResult.error.map { errors.append((accountName, $0)) }

        guard
            let session = sessionResult.value,
            let account = accountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                session: session,
                account: account
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let sessionResult = sessionTransformer.transform(destination: value.session)
        let accountResult = accountTransformer.transform(destination: value.account)

        var errors: [(String, TransformerError)] = []
        sessionResult.error.map { errors.append((sessionName, $0)) }
        accountResult.error.map { errors.append((accountName, $0)) }

        guard
            let session = sessionResult.value,
            let account = accountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[sessionName] = session
        dictionary[accountName] = account
        return .success(dictionary)
    }
}
