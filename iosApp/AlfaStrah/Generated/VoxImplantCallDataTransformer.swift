// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VoxImplantCallDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VoxImplantCallData

    let usernameForOneTimeLoginKeyName = "username"
    let fromName = "from"
    let destinationName = "destination"
    let headersName = "headers"

    let usernameForOneTimeLoginKeyTransformer = CastTransformer<Any, String>()
    let fromTransformer = CastTransformer<Any, String>()
    let destinationTransformer = CastTransformer<Any, String>()
    let headersTransformer = ArrayTransformer(from: Any.self, transformer: VoxImplantCallHeaderTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let usernameForOneTimeLoginKeyResult = dictionary[usernameForOneTimeLoginKeyName].map(usernameForOneTimeLoginKeyTransformer.transform(source:)) ?? .failure(.requirement)
        let fromResult = dictionary[fromName].map(fromTransformer.transform(source:)) ?? .failure(.requirement)
        let destinationResult = dictionary[destinationName].map(destinationTransformer.transform(source:)) ?? .failure(.requirement)
        let headersResult = dictionary[headersName].map(headersTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        usernameForOneTimeLoginKeyResult.error.map { errors.append((usernameForOneTimeLoginKeyName, $0)) }
        fromResult.error.map { errors.append((fromName, $0)) }
        destinationResult.error.map { errors.append((destinationName, $0)) }
        headersResult.error.map { errors.append((headersName, $0)) }

        guard
            let usernameForOneTimeLoginKey = usernameForOneTimeLoginKeyResult.value,
            let from = fromResult.value,
            let destination = destinationResult.value,
            let headers = headersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                usernameForOneTimeLoginKey: usernameForOneTimeLoginKey,
                from: from,
                destination: destination,
                headers: headers
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let usernameForOneTimeLoginKeyResult = usernameForOneTimeLoginKeyTransformer.transform(destination: value.usernameForOneTimeLoginKey)
        let fromResult = fromTransformer.transform(destination: value.from)
        let destinationResult = destinationTransformer.transform(destination: value.destination)
        let headersResult = headersTransformer.transform(destination: value.headers)

        var errors: [(String, TransformerError)] = []
        usernameForOneTimeLoginKeyResult.error.map { errors.append((usernameForOneTimeLoginKeyName, $0)) }
        fromResult.error.map { errors.append((fromName, $0)) }
        destinationResult.error.map { errors.append((destinationName, $0)) }
        headersResult.error.map { errors.append((headersName, $0)) }

        guard
            let usernameForOneTimeLoginKey = usernameForOneTimeLoginKeyResult.value,
            let from = fromResult.value,
            let destination = destinationResult.value,
            let headers = headersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[usernameForOneTimeLoginKeyName] = usernameForOneTimeLoginKey
        dictionary[fromName] = from
        dictionary[destinationName] = destination
        dictionary[headersName] = headers
        return .success(dictionary)
    }
}
