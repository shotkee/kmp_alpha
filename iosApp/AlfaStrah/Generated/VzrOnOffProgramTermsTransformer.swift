// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VzrOnOffProgramTermsTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VzrOnOffProgramTerms

    let contractTermsUrlStringName = "url_activation"
    let insuranceTermsUrlStringName = "url_insurance"

    let contractTermsUrlStringTransformer = CastTransformer<Any, String>()
    let insuranceTermsUrlStringTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let contractTermsUrlStringResult = dictionary[contractTermsUrlStringName].map(contractTermsUrlStringTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceTermsUrlStringResult = dictionary[insuranceTermsUrlStringName].map(insuranceTermsUrlStringTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        contractTermsUrlStringResult.error.map { errors.append((contractTermsUrlStringName, $0)) }
        insuranceTermsUrlStringResult.error.map { errors.append((insuranceTermsUrlStringName, $0)) }

        guard
            let contractTermsUrlString = contractTermsUrlStringResult.value,
            let insuranceTermsUrlString = insuranceTermsUrlStringResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                contractTermsUrlString: contractTermsUrlString,
                insuranceTermsUrlString: insuranceTermsUrlString
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let contractTermsUrlStringResult = contractTermsUrlStringTransformer.transform(destination: value.contractTermsUrlString)
        let insuranceTermsUrlStringResult = insuranceTermsUrlStringTransformer.transform(destination: value.insuranceTermsUrlString)

        var errors: [(String, TransformerError)] = []
        contractTermsUrlStringResult.error.map { errors.append((contractTermsUrlStringName, $0)) }
        insuranceTermsUrlStringResult.error.map { errors.append((insuranceTermsUrlStringName, $0)) }

        guard
            let contractTermsUrlString = contractTermsUrlStringResult.value,
            let insuranceTermsUrlString = insuranceTermsUrlStringResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[contractTermsUrlStringName] = contractTermsUrlString
        dictionary[insuranceTermsUrlStringName] = insuranceTermsUrlString
        return .success(dictionary)
    }
}
