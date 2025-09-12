// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RenewInsuranceRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RenewInsuranceRequest

    let insurancePontsName = "points"
    let agreedToPersonalDataPolicyName = "agreed"

    let insurancePontsTransformer = NumberTransformer<Any, Int>()
    let agreedToPersonalDataPolicyTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insurancePontsResult = dictionary[insurancePontsName].map(insurancePontsTransformer.transform(source:)) ?? .failure(.requirement)
        let agreedToPersonalDataPolicyResult = dictionary[agreedToPersonalDataPolicyName].map(agreedToPersonalDataPolicyTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insurancePontsResult.error.map { errors.append((insurancePontsName, $0)) }
        agreedToPersonalDataPolicyResult.error.map { errors.append((agreedToPersonalDataPolicyName, $0)) }

        guard
            let insurancePonts = insurancePontsResult.value,
            let agreedToPersonalDataPolicy = agreedToPersonalDataPolicyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insurancePonts: insurancePonts,
                agreedToPersonalDataPolicy: agreedToPersonalDataPolicy
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insurancePontsResult = insurancePontsTransformer.transform(destination: value.insurancePonts)
        let agreedToPersonalDataPolicyResult = agreedToPersonalDataPolicyTransformer.transform(destination: value.agreedToPersonalDataPolicy)

        var errors: [(String, TransformerError)] = []
        insurancePontsResult.error.map { errors.append((insurancePontsName, $0)) }
        agreedToPersonalDataPolicyResult.error.map { errors.append((agreedToPersonalDataPolicyName, $0)) }

        guard
            let insurancePonts = insurancePontsResult.value,
            let agreedToPersonalDataPolicy = agreedToPersonalDataPolicyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insurancePontsName] = insurancePonts
        dictionary[agreedToPersonalDataPolicyName] = agreedToPersonalDataPolicy
        return .success(dictionary)
    }
}
