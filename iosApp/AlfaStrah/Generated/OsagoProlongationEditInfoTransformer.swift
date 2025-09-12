// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationEditInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationEditInfo

    let descriptionName = "description"
    let participantsName = "participants"

    let descriptionTransformer = CastTransformer<Any, String>()
    let participantsTransformer = ArrayTransformer(from: Any.self, transformer: OsagoProlongationParticipantTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let participantsResult = dictionary[participantsName].map(participantsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        participantsResult.error.map { errors.append((participantsName, $0)) }

        guard
            let description = descriptionResult.value,
            let participants = participantsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                description: description,
                participants: participants
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let participantsResult = participantsTransformer.transform(destination: value.participants)

        var errors: [(String, TransformerError)] = []
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        participantsResult.error.map { errors.append((participantsName, $0)) }

        guard
            let description = descriptionResult.value,
            let participants = participantsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[descriptionName] = description
        dictionary[participantsName] = participants
        return .success(dictionary)
    }
}
