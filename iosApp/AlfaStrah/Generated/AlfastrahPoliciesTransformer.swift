// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AlfastrahPoliciesTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AlfastrahPolicies

    let registrationName = "registration"
    let telematicName = "telematic"

    let registrationTransformer = CastTransformer<Any, String>()
    let telematicTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let registrationResult = dictionary[registrationName].map(registrationTransformer.transform(source:)) ?? .failure(.requirement)
        let telematicResult = dictionary[telematicName].map(telematicTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        registrationResult.error.map { errors.append((registrationName, $0)) }
        telematicResult.error.map { errors.append((telematicName, $0)) }

        guard
            let registration = registrationResult.value,
            let telematic = telematicResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                registration: registration,
                telematic: telematic
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let registrationResult = registrationTransformer.transform(destination: value.registration)
        let telematicResult = telematicTransformer.transform(destination: value.telematic)

        var errors: [(String, TransformerError)] = []
        registrationResult.error.map { errors.append((registrationName, $0)) }
        telematicResult.error.map { errors.append((telematicName, $0)) }

        guard
            let registration = registrationResult.value,
            let telematic = telematicResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[registrationName] = registration
        dictionary[telematicName] = telematic
        return .success(dictionary)
    }
}
