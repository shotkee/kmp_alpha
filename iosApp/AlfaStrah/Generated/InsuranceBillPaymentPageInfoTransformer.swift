// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceBillPaymentPageInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceBillPaymentPageInfo

    let urlName = "payment_link"
    let successStringName = "success_url_part"
    let failureStringName = "fail_url_part"

    let urlTransformer = UrlTransformer<Any>()
    let successStringTransformer = CastTransformer<Any, String>()
    let failureStringTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let urlResult = dictionary[urlName].map(urlTransformer.transform(source:)) ?? .failure(.requirement)
        let successStringResult = dictionary[successStringName].map(successStringTransformer.transform(source:)) ?? .failure(.requirement)
        let failureStringResult = dictionary[failureStringName].map(failureStringTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        urlResult.error.map { errors.append((urlName, $0)) }
        successStringResult.error.map { errors.append((successStringName, $0)) }
        failureStringResult.error.map { errors.append((failureStringName, $0)) }

        guard
            let url = urlResult.value,
            let successString = successStringResult.value,
            let failureString = failureStringResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                url: url,
                successString: successString,
                failureString: failureString
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let urlResult = urlTransformer.transform(destination: value.url)
        let successStringResult = successStringTransformer.transform(destination: value.successString)
        let failureStringResult = failureStringTransformer.transform(destination: value.failureString)

        var errors: [(String, TransformerError)] = []
        urlResult.error.map { errors.append((urlName, $0)) }
        successStringResult.error.map { errors.append((successStringName, $0)) }
        failureStringResult.error.map { errors.append((failureStringName, $0)) }

        guard
            let url = urlResult.value,
            let successString = successStringResult.value,
            let failureString = failureStringResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[urlName] = url
        dictionary[successStringName] = successString
        dictionary[failureStringName] = failureString
        return .success(dictionary)
    }
}
