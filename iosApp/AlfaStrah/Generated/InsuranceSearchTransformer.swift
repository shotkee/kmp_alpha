// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceSearchTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceSearch

    let requestName = "search_policy_request"
    let isNewName = "is_new"

    let requestTransformer = InsuranceSearchPolicyRequestTransformer()
    let isNewTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let requestResult = dictionary[requestName].map(requestTransformer.transform(source:)) ?? .failure(.requirement)
        let isNewResult = dictionary[isNewName].map(isNewTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        requestResult.error.map { errors.append((requestName, $0)) }
        isNewResult.error.map { errors.append((isNewName, $0)) }

        guard
            let request = requestResult.value,
            let isNew = isNewResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                request: request,
                isNew: isNew
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let requestResult = requestTransformer.transform(destination: value.request)
        let isNewResult = isNewTransformer.transform(destination: value.isNew)

        var errors: [(String, TransformerError)] = []
        requestResult.error.map { errors.append((requestName, $0)) }
        isNewResult.error.map { errors.append((isNewName, $0)) }

        guard
            let request = requestResult.value,
            let isNew = isNewResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[requestName] = request
        dictionary[isNewName] = isNew
        return .success(dictionary)
    }
}
