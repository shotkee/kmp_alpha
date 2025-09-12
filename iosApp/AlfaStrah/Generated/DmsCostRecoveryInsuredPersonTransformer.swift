// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryInsuredPersonTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryInsuredPerson

    let fullnameName = "full_name"
    let birthdayName = "birthday"
    let policyNumberName = "policy_number"

    let fullnameTransformer = CastTransformer<Any, String>()
    let birthdayTransformer = DateTransformer<Any>(format: "yyyy-MM-dd")
    let policyNumberTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let fullnameResult = dictionary[fullnameName].map(fullnameTransformer.transform(source:)) ?? .failure(.requirement)
        let birthdayResult = dictionary[birthdayName].map(birthdayTransformer.transform(source:)) ?? .failure(.requirement)
        let policyNumberResult = dictionary[policyNumberName].map(policyNumberTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        fullnameResult.error.map { errors.append((fullnameName, $0)) }
        birthdayResult.error.map { errors.append((birthdayName, $0)) }
        policyNumberResult.error.map { errors.append((policyNumberName, $0)) }

        guard
            let fullname = fullnameResult.value,
            let birthday = birthdayResult.value,
            let policyNumber = policyNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                fullname: fullname,
                birthday: birthday,
                policyNumber: policyNumber
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let fullnameResult = fullnameTransformer.transform(destination: value.fullname)
        let birthdayResult = birthdayTransformer.transform(destination: value.birthday)
        let policyNumberResult = policyNumberTransformer.transform(destination: value.policyNumber)

        var errors: [(String, TransformerError)] = []
        fullnameResult.error.map { errors.append((fullnameName, $0)) }
        birthdayResult.error.map { errors.append((birthdayName, $0)) }
        policyNumberResult.error.map { errors.append((policyNumberName, $0)) }

        guard
            let fullname = fullnameResult.value,
            let birthday = birthdayResult.value,
            let policyNumber = policyNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[fullnameName] = fullname
        dictionary[birthdayName] = birthday
        dictionary[policyNumberName] = policyNumber
        return .success(dictionary)
    }
}
