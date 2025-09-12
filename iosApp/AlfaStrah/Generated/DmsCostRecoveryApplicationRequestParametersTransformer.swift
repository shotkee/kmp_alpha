// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryApplicationRequestParametersTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryApplicationRequestParameters

    let insuranceIdName = "insurance_id"
    let requestName = "request"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let requestTransformer = DmsCostRecoveryApplicationRequestTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let requestResult = dictionary[requestName].map(requestTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        requestResult.error.map { errors.append((requestName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let request = requestResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                request: request
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let requestResult = requestTransformer.transform(destination: value.request)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        requestResult.error.map { errors.append((requestName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let request = requestResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[requestName] = request
        return .success(dictionary)
    }
}
