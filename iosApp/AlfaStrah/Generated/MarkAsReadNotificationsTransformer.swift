// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct MarkAsReadNotificationsTransformer: Transformer {
    typealias Source = Any
    typealias Destination = MarkAsReadNotifications

    let idsName = "ids"

    let idsTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idsResult = dictionary[idsName].map(idsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idsResult.error.map { errors.append((idsName, $0)) }

        guard
            let ids = idsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                ids: ids
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idsResult = idsTransformer.transform(destination: value.ids)

        var errors: [(String, TransformerError)] = []
        idsResult.error.map { errors.append((idsName, $0)) }

        guard
            let ids = idsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idsName] = ids
        return .success(dictionary)
    }
}
