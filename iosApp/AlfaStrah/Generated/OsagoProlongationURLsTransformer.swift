// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationURLsTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationURLs

    let urlActivationName = "url_activation"
    let urlInsuranceName = "url_insurance"

    let urlActivationTransformer = UrlTransformer<Any>()
    let urlInsuranceTransformer = UrlTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let urlActivationResult = dictionary[urlActivationName].map(urlActivationTransformer.transform(source:)) ?? .failure(.requirement)
        let urlInsuranceResult = dictionary[urlInsuranceName].map(urlInsuranceTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        urlActivationResult.error.map { errors.append((urlActivationName, $0)) }
        urlInsuranceResult.error.map { errors.append((urlInsuranceName, $0)) }

        guard
            let urlActivation = urlActivationResult.value,
            let urlInsurance = urlInsuranceResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                urlActivation: urlActivation,
                urlInsurance: urlInsurance
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let urlActivationResult = urlActivationTransformer.transform(destination: value.urlActivation)
        let urlInsuranceResult = urlInsuranceTransformer.transform(destination: value.urlInsurance)

        var errors: [(String, TransformerError)] = []
        urlActivationResult.error.map { errors.append((urlActivationName, $0)) }
        urlInsuranceResult.error.map { errors.append((urlInsuranceName, $0)) }

        guard
            let urlActivation = urlActivationResult.value,
            let urlInsurance = urlInsuranceResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[urlActivationName] = urlActivation
        dictionary[urlInsuranceName] = urlInsurance
        return .success(dictionary)
    }
}
