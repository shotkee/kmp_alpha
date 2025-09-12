// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationParticipantDetailedTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationParticipantDetailed

    let descriptionName = "description"
    let fieldGroupsName = "field_groups"

    let descriptionTransformer = CastTransformer<Any, String>()
    let fieldGroupsTransformer = ArrayTransformer(from: Any.self, transformer: OsagoProlongationFieldGroupTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let fieldGroupsResult = dictionary[fieldGroupsName].map(fieldGroupsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        fieldGroupsResult.error.map { errors.append((fieldGroupsName, $0)) }

        guard
            let description = descriptionResult.value,
            let fieldGroups = fieldGroupsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                description: description,
                fieldGroups: fieldGroups
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let fieldGroupsResult = fieldGroupsTransformer.transform(destination: value.fieldGroups)

        var errors: [(String, TransformerError)] = []
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        fieldGroupsResult.error.map { errors.append((fieldGroupsName, $0)) }

        guard
            let description = descriptionResult.value,
            let fieldGroups = fieldGroupsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[descriptionName] = description
        dictionary[fieldGroupsName] = fieldGroups
        return .success(dictionary)
    }
}
