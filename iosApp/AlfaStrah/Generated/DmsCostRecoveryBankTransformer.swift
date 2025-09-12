// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryBankTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryBank

    let titleName = "title"
    let bikName = "bik"
    let correspondentAccountName = "corr_number"

    let titleTransformer = CastTransformer<Any, String>()
    let bikTransformer = CastTransformer<Any, String>()
    let correspondentAccountTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let bikResult = dictionary[bikName].map(bikTransformer.transform(source:)) ?? .failure(.requirement)
        let correspondentAccountResult = dictionary[correspondentAccountName].map(correspondentAccountTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        bikResult.error.map { errors.append((bikName, $0)) }
        correspondentAccountResult.error.map { errors.append((correspondentAccountName, $0)) }

        guard
            let title = titleResult.value,
            let bik = bikResult.value,
            let correspondentAccount = correspondentAccountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                bik: bik,
                correspondentAccount: correspondentAccount
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let bikResult = bikTransformer.transform(destination: value.bik)
        let correspondentAccountResult = correspondentAccountTransformer.transform(destination: value.correspondentAccount)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        bikResult.error.map { errors.append((bikName, $0)) }
        correspondentAccountResult.error.map { errors.append((correspondentAccountName, $0)) }

        guard
            let title = titleResult.value,
            let bik = bikResult.value,
            let correspondentAccount = correspondentAccountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[bikName] = bik
        dictionary[correspondentAccountName] = correspondentAccount
        return .success(dictionary)
    }
}
