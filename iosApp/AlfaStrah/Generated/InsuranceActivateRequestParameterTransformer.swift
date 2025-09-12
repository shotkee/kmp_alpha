// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceActivateRequestParameterTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceActivateRequestParameter

    let insuranceActivateRequestName = "activate_request"

    let insuranceActivateRequestTransformer = InsuranceActivateRequestTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceActivateRequestResult = dictionary[insuranceActivateRequestName].map(insuranceActivateRequestTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceActivateRequestResult.error.map { errors.append((insuranceActivateRequestName, $0)) }

        guard
            let insuranceActivateRequest = insuranceActivateRequestResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceActivateRequest: insuranceActivateRequest
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceActivateRequestResult = insuranceActivateRequestTransformer.transform(destination: value.insuranceActivateRequest)

        var errors: [(String, TransformerError)] = []
        insuranceActivateRequestResult.error.map { errors.append((insuranceActivateRequestName, $0)) }

        guard
            let insuranceActivateRequest = insuranceActivateRequestResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceActivateRequestName] = insuranceActivateRequest
        return .success(dictionary)
    }
}
