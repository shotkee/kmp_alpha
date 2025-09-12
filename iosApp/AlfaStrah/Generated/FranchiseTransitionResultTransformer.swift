// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FranchiseTransitionResultTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FranchiseTransitionResult

    let personsName = "persons"
    let stateName = "state"
    let messageName = "result_message"

    let personsTransformer = ArrayTransformer(from: Any.self, transformer: FranchiseTransitionResultInsuredPersonTransformer(), skipFailures: true)
    let stateTransformer = FranchiseTransitionResultStatusTransformer()
    let messageTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let personsResult = dictionary[personsName].map(personsTransformer.transform(source:)) ?? .failure(.requirement)
        let stateResult = dictionary[stateName].map(stateTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = messageTransformer.transform(source: dictionary[messageName])

        var errors: [(String, TransformerError)] = []
        personsResult.error.map { errors.append((personsName, $0)) }
        stateResult.error.map { errors.append((stateName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let persons = personsResult.value,
            let state = stateResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                persons: persons,
                state: state,
                message: message
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let personsResult = personsTransformer.transform(destination: value.persons)
        let stateResult = stateTransformer.transform(destination: value.state)
        let messageResult = messageTransformer.transform(destination: value.message)

        var errors: [(String, TransformerError)] = []
        personsResult.error.map { errors.append((personsName, $0)) }
        stateResult.error.map { errors.append((stateName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let persons = personsResult.value,
            let state = stateResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[personsName] = persons
        dictionary[stateName] = state
        dictionary[messageName] = message
        return .success(dictionary)
    }
}
