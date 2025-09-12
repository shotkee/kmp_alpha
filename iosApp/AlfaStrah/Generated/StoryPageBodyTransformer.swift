// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct StoryPageBodyTransformer: Transformer {
    typealias Source = Any
    typealias Destination = StoryPageBody

    let titleName = "title"
    let titleColorName = "title_color"
    let textName = "text"
    let textColorName = "text_color"
    let imageTypeName = "image_type"
    let imageName = "image"
    let backgroundImageTypeName = "background_image_type"
    let backgroundImageName = "background_image"
    let backgroundColorName = "background_color"

    let titleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let titleColorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let textTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let textColorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let imageTypeTransformer = OptionalTransformer(transformer: StoryPageBodyImageTypeTransformer())
    let imageTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let backgroundImageTypeTransformer = StoryPageBodyBackgroundImageTypeTransformer()
    let backgroundImageTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let backgroundColorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = titleTransformer.transform(source: dictionary[titleName])
        let titleColorResult = titleColorTransformer.transform(source: dictionary[titleColorName])
        let textResult = textTransformer.transform(source: dictionary[textName])
        let textColorResult = textColorTransformer.transform(source: dictionary[textColorName])
        let imageTypeResult = imageTypeTransformer.transform(source: dictionary[imageTypeName])
        let imageResult = imageTransformer.transform(source: dictionary[imageName])
        let backgroundImageTypeResult = dictionary[backgroundImageTypeName].map(backgroundImageTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let backgroundImageResult = backgroundImageTransformer.transform(source: dictionary[backgroundImageName])
        let backgroundColorResult = backgroundColorTransformer.transform(source: dictionary[backgroundColorName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        titleColorResult.error.map { errors.append((titleColorName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        textColorResult.error.map { errors.append((textColorName, $0)) }
        imageTypeResult.error.map { errors.append((imageTypeName, $0)) }
        imageResult.error.map { errors.append((imageName, $0)) }
        backgroundImageTypeResult.error.map { errors.append((backgroundImageTypeName, $0)) }
        backgroundImageResult.error.map { errors.append((backgroundImageName, $0)) }
        backgroundColorResult.error.map { errors.append((backgroundColorName, $0)) }

        guard
            let title = titleResult.value,
            let titleColor = titleColorResult.value,
            let text = textResult.value,
            let textColor = textColorResult.value,
            let imageType = imageTypeResult.value,
            let image = imageResult.value,
            let backgroundImageType = backgroundImageTypeResult.value,
            let backgroundImage = backgroundImageResult.value,
            let backgroundColor = backgroundColorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                titleColor: titleColor,
                text: text,
                textColor: textColor,
                imageType: imageType,
                image: image,
                backgroundImageType: backgroundImageType,
                backgroundImage: backgroundImage,
                backgroundColor: backgroundColor
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let titleColorResult = titleColorTransformer.transform(destination: value.titleColor)
        let textResult = textTransformer.transform(destination: value.text)
        let textColorResult = textColorTransformer.transform(destination: value.textColor)
        let imageTypeResult = imageTypeTransformer.transform(destination: value.imageType)
        let imageResult = imageTransformer.transform(destination: value.image)
        let backgroundImageTypeResult = backgroundImageTypeTransformer.transform(destination: value.backgroundImageType)
        let backgroundImageResult = backgroundImageTransformer.transform(destination: value.backgroundImage)
        let backgroundColorResult = backgroundColorTransformer.transform(destination: value.backgroundColor)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        titleColorResult.error.map { errors.append((titleColorName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        textColorResult.error.map { errors.append((textColorName, $0)) }
        imageTypeResult.error.map { errors.append((imageTypeName, $0)) }
        imageResult.error.map { errors.append((imageName, $0)) }
        backgroundImageTypeResult.error.map { errors.append((backgroundImageTypeName, $0)) }
        backgroundImageResult.error.map { errors.append((backgroundImageName, $0)) }
        backgroundColorResult.error.map { errors.append((backgroundColorName, $0)) }

        guard
            let title = titleResult.value,
            let titleColor = titleColorResult.value,
            let text = textResult.value,
            let textColor = textColorResult.value,
            let imageType = imageTypeResult.value,
            let image = imageResult.value,
            let backgroundImageType = backgroundImageTypeResult.value,
            let backgroundImage = backgroundImageResult.value,
            let backgroundColor = backgroundColorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[titleColorName] = titleColor
        dictionary[textName] = text
        dictionary[textColorName] = textColor
        dictionary[imageTypeName] = imageType
        dictionary[imageName] = image
        dictionary[backgroundImageTypeName] = backgroundImageType
        dictionary[backgroundImageName] = backgroundImage
        dictionary[backgroundColorName] = backgroundColor
        return .success(dictionary)
    }
}
