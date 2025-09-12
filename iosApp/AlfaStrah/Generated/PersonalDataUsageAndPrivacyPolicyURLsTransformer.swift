// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct PersonalDataUsageAndPrivacyPolicyURLsTransformer: Transformer {
    typealias Source = Any
    typealias Destination = PersonalDataUsageAndPrivacyPolicyURLs

    let personalDataUsageUrlName = "pd_agreement"
    let privacyPolicyUrlName = "pd_policy"
    let yandexMapsPolicyUrlName = "ymaps_agreement"

    let personalDataUsageUrlTransformer = UrlTransformer<Any>()
    let privacyPolicyUrlTransformer = UrlTransformer<Any>()
    let yandexMapsPolicyUrlTransformer = UrlTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let personalDataUsageUrlResult = dictionary[personalDataUsageUrlName].map(personalDataUsageUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let privacyPolicyUrlResult = dictionary[privacyPolicyUrlName].map(privacyPolicyUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let yandexMapsPolicyUrlResult = dictionary[yandexMapsPolicyUrlName].map(yandexMapsPolicyUrlTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        personalDataUsageUrlResult.error.map { errors.append((personalDataUsageUrlName, $0)) }
        privacyPolicyUrlResult.error.map { errors.append((privacyPolicyUrlName, $0)) }
        yandexMapsPolicyUrlResult.error.map { errors.append((yandexMapsPolicyUrlName, $0)) }

        guard
            let personalDataUsageUrl = personalDataUsageUrlResult.value,
            let privacyPolicyUrl = privacyPolicyUrlResult.value,
            let yandexMapsPolicyUrl = yandexMapsPolicyUrlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                personalDataUsageUrl: personalDataUsageUrl,
                privacyPolicyUrl: privacyPolicyUrl,
                yandexMapsPolicyUrl: yandexMapsPolicyUrl
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let personalDataUsageUrlResult = personalDataUsageUrlTransformer.transform(destination: value.personalDataUsageUrl)
        let privacyPolicyUrlResult = privacyPolicyUrlTransformer.transform(destination: value.privacyPolicyUrl)
        let yandexMapsPolicyUrlResult = yandexMapsPolicyUrlTransformer.transform(destination: value.yandexMapsPolicyUrl)

        var errors: [(String, TransformerError)] = []
        personalDataUsageUrlResult.error.map { errors.append((personalDataUsageUrlName, $0)) }
        privacyPolicyUrlResult.error.map { errors.append((privacyPolicyUrlName, $0)) }
        yandexMapsPolicyUrlResult.error.map { errors.append((yandexMapsPolicyUrlName, $0)) }

        guard
            let personalDataUsageUrl = personalDataUsageUrlResult.value,
            let privacyPolicyUrl = privacyPolicyUrlResult.value,
            let yandexMapsPolicyUrl = yandexMapsPolicyUrlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[personalDataUsageUrlName] = personalDataUsageUrl
        dictionary[privacyPolicyUrlName] = privacyPolicyUrl
        dictionary[yandexMapsPolicyUrlName] = yandexMapsPolicyUrl
        return .success(dictionary)
    }
}
