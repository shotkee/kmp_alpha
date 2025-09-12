// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct PointsTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Points

    let themedAmountName = "amount"
    let themedIconName = "icon"

    let themedAmountTransformer = OptionalTransformer(transformer: ThemedTextTransformer())
    let themedIconTransformer = OptionalTransformer(transformer: ThemedValueTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let themedAmountResult = themedAmountTransformer.transform(source: dictionary[themedAmountName])
        let themedIconResult = themedIconTransformer.transform(source: dictionary[themedIconName])

        var errors: [(String, TransformerError)] = []
        themedAmountResult.error.map { errors.append((themedAmountName, $0)) }
        themedIconResult.error.map { errors.append((themedIconName, $0)) }

        guard
            let themedAmount = themedAmountResult.value,
            let themedIcon = themedIconResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                themedAmount: themedAmount,
                themedIcon: themedIcon
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let themedAmountResult = themedAmountTransformer.transform(destination: value.themedAmount)
        let themedIconResult = themedIconTransformer.transform(destination: value.themedIcon)

        var errors: [(String, TransformerError)] = []
        themedAmountResult.error.map { errors.append((themedAmountName, $0)) }
        themedIconResult.error.map { errors.append((themedIconName, $0)) }

        guard
            let themedAmount = themedAmountResult.value,
            let themedIcon = themedIconResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[themedAmountName] = themedAmount
        dictionary[themedIconName] = themedIcon
        return .success(dictionary)
    }
}
