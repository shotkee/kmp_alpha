// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DeleteNotificationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DeleteNotification

    let idName = "id"
    let isDeletedName = "is_deleted"

    let idTransformer = CastTransformer<Any, String>()
    let isDeletedTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let isDeletedResult = dictionary[isDeletedName].map(isDeletedTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        isDeletedResult.error.map { errors.append((isDeletedName, $0)) }

        guard
            let id = idResult.value,
            let isDeleted = isDeletedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                isDeleted: isDeleted
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let isDeletedResult = isDeletedTransformer.transform(destination: value.isDeleted)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        isDeletedResult.error.map { errors.append((isDeletedName, $0)) }

        guard
            let id = idResult.value,
            let isDeleted = isDeletedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[isDeletedName] = isDeleted
        return .success(dictionary)
    }
}
