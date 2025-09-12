// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AnalyticsInsuranceProfileTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AnalyticsInsuranceProfile

    let insurerFirstnameName = "InsurerFName"
    let groupNameName = "GroupName"

    let insurerFirstnameTransformer = CastTransformer<Any, String>()
    let groupNameTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insurerFirstnameResult = dictionary[insurerFirstnameName].map(insurerFirstnameTransformer.transform(source:)) ?? .failure(.requirement)
        let groupNameResult = dictionary[groupNameName].map(groupNameTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insurerFirstnameResult.error.map { errors.append((insurerFirstnameName, $0)) }
        groupNameResult.error.map { errors.append((groupNameName, $0)) }

        guard
            let insurerFirstname = insurerFirstnameResult.value,
            let groupName = groupNameResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insurerFirstname: insurerFirstname,
                groupName: groupName
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insurerFirstnameResult = insurerFirstnameTransformer.transform(destination: value.insurerFirstname)
        let groupNameResult = groupNameTransformer.transform(destination: value.groupName)

        var errors: [(String, TransformerError)] = []
        insurerFirstnameResult.error.map { errors.append((insurerFirstnameName, $0)) }
        groupNameResult.error.map { errors.append((groupNameName, $0)) }

        guard
            let insurerFirstname = insurerFirstnameResult.value,
            let groupName = groupNameResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insurerFirstnameName] = insurerFirstname
        dictionary[groupNameName] = groupName
        return .success(dictionary)
    }
}
