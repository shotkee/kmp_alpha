// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosEmergencyCommunicationBlockTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosEmergencyCommunicationBlock

    let titleName = "title"
    let itemListName = "emergency_connection_list"

    let titleTransformer = CastTransformer<Any, String>()
    let itemListTransformer = ArrayTransformer(from: Any.self, transformer: SosEmergencyCommunicationItemTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let itemListResult = dictionary[itemListName].map(itemListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        itemListResult.error.map { errors.append((itemListName, $0)) }

        guard
            let title = titleResult.value,
            let itemList = itemListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                itemList: itemList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let itemListResult = itemListTransformer.transform(destination: value.itemList)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        itemListResult.error.map { errors.append((itemListName, $0)) }

        guard
            let title = titleResult.value,
            let itemList = itemListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[itemListName] = itemList
        return .success(dictionary)
    }
}
