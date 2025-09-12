// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BonusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Bonus

    let pointsName = "points"
    let themedButtonName = "button"
    let themedDescriptionName = "subtitle"
    let themedTitleName = "title"
    let themedImageName = "image"
    let themedBackgroundColorName = "background"
    let themedLinkName = "link"

    let pointsTransformer = OptionalTransformer(transformer: PointsTransformer())
    let themedButtonTransformer = OptionalTransformer(transformer: ThemedButtonTransformer())
    let themedDescriptionTransformer = OptionalTransformer(transformer: ThemedTextTransformer())
    let themedTitleTransformer = OptionalTransformer(transformer: ThemedTextTransformer())
    let themedImageTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let themedBackgroundColorTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let themedLinkTransformer = OptionalTransformer(transformer: ThemedLinkTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let pointsResult = pointsTransformer.transform(source: dictionary[pointsName])
        let themedButtonResult = themedButtonTransformer.transform(source: dictionary[themedButtonName])
        let themedDescriptionResult = themedDescriptionTransformer.transform(source: dictionary[themedDescriptionName])
        let themedTitleResult = themedTitleTransformer.transform(source: dictionary[themedTitleName])
        let themedImageResult = themedImageTransformer.transform(source: dictionary[themedImageName])
        let themedBackgroundColorResult = themedBackgroundColorTransformer.transform(source: dictionary[themedBackgroundColorName])
        let themedLinkResult = themedLinkTransformer.transform(source: dictionary[themedLinkName])

        var errors: [(String, TransformerError)] = []
        pointsResult.error.map { errors.append((pointsName, $0)) }
        themedButtonResult.error.map { errors.append((themedButtonName, $0)) }
        themedDescriptionResult.error.map { errors.append((themedDescriptionName, $0)) }
        themedTitleResult.error.map { errors.append((themedTitleName, $0)) }
        themedImageResult.error.map { errors.append((themedImageName, $0)) }
        themedBackgroundColorResult.error.map { errors.append((themedBackgroundColorName, $0)) }
        themedLinkResult.error.map { errors.append((themedLinkName, $0)) }

        guard
            let points = pointsResult.value,
            let themedButton = themedButtonResult.value,
            let themedDescription = themedDescriptionResult.value,
            let themedTitle = themedTitleResult.value,
            let themedImage = themedImageResult.value,
            let themedBackgroundColor = themedBackgroundColorResult.value,
            let themedLink = themedLinkResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                points: points,
                themedButton: themedButton,
                themedDescription: themedDescription,
                themedTitle: themedTitle,
                themedImage: themedImage,
                themedBackgroundColor: themedBackgroundColor,
                themedLink: themedLink
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let pointsResult = pointsTransformer.transform(destination: value.points)
        let themedButtonResult = themedButtonTransformer.transform(destination: value.themedButton)
        let themedDescriptionResult = themedDescriptionTransformer.transform(destination: value.themedDescription)
        let themedTitleResult = themedTitleTransformer.transform(destination: value.themedTitle)
        let themedImageResult = themedImageTransformer.transform(destination: value.themedImage)
        let themedBackgroundColorResult = themedBackgroundColorTransformer.transform(destination: value.themedBackgroundColor)
        let themedLinkResult = themedLinkTransformer.transform(destination: value.themedLink)

        var errors: [(String, TransformerError)] = []
        pointsResult.error.map { errors.append((pointsName, $0)) }
        themedButtonResult.error.map { errors.append((themedButtonName, $0)) }
        themedDescriptionResult.error.map { errors.append((themedDescriptionName, $0)) }
        themedTitleResult.error.map { errors.append((themedTitleName, $0)) }
        themedImageResult.error.map { errors.append((themedImageName, $0)) }
        themedBackgroundColorResult.error.map { errors.append((themedBackgroundColorName, $0)) }
        themedLinkResult.error.map { errors.append((themedLinkName, $0)) }

        guard
            let points = pointsResult.value,
            let themedButton = themedButtonResult.value,
            let themedDescription = themedDescriptionResult.value,
            let themedTitle = themedTitleResult.value,
            let themedImage = themedImageResult.value,
            let themedBackgroundColor = themedBackgroundColorResult.value,
            let themedLink = themedLinkResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[pointsName] = points
        dictionary[themedButtonName] = themedButton
        dictionary[themedDescriptionName] = themedDescription
        dictionary[themedTitleName] = themedTitle
        dictionary[themedImageName] = themedImage
        dictionary[themedBackgroundColorName] = themedBackgroundColor
        dictionary[themedLinkName] = themedLink
        return .success(dictionary)
    }
}
