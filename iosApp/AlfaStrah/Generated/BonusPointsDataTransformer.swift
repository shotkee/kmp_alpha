// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BonusPointsDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BonusPointsData

    let themedTitleName = "title"
    let themedIconsName = "icons"
    let bonusesName = "bonuses"

    let themedTitleTransformer = OptionalTransformer(transformer: ThemedTextTransformer())
    let themedIconsTransformer = ArrayTransformer(from: Any.self, transformer: ThemedValueTransformer(), skipFailures: true)
    let bonusesTransformer = ArrayTransformer(from: Any.self, transformer: BonusTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let themedTitleResult = themedTitleTransformer.transform(source: dictionary[themedTitleName])
        let themedIconsResult = dictionary[themedIconsName].map(themedIconsTransformer.transform(source:)) ?? .failure(.requirement)
        let bonusesResult = dictionary[bonusesName].map(bonusesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        themedTitleResult.error.map { errors.append((themedTitleName, $0)) }
        themedIconsResult.error.map { errors.append((themedIconsName, $0)) }
        bonusesResult.error.map { errors.append((bonusesName, $0)) }

        guard
            let themedTitle = themedTitleResult.value,
            let themedIcons = themedIconsResult.value,
            let bonuses = bonusesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                themedTitle: themedTitle,
                themedIcons: themedIcons,
                bonuses: bonuses
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let themedTitleResult = themedTitleTransformer.transform(destination: value.themedTitle)
        let themedIconsResult = themedIconsTransformer.transform(destination: value.themedIcons)
        let bonusesResult = bonusesTransformer.transform(destination: value.bonuses)

        var errors: [(String, TransformerError)] = []
        themedTitleResult.error.map { errors.append((themedTitleName, $0)) }
        themedIconsResult.error.map { errors.append((themedIconsName, $0)) }
        bonusesResult.error.map { errors.append((bonusesName, $0)) }

        guard
            let themedTitle = themedTitleResult.value,
            let themedIcons = themedIconsResult.value,
            let bonuses = bonusesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[themedTitleName] = themedTitle
        dictionary[themedIconsName] = themedIcons
        dictionary[bonusesName] = bonuses
        return .success(dictionary)
    }
}
