// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceProductTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceProduct

    let idName = "product_id"
    let titleName = "title"
    let textName = "text"
    let tagListName = "tag_list"
    let imageName = "image"
    let detailedImageName = "detailed_image"
    let detailedContentName = "detailed_content"
    let detailedButtonName = "detailed_button"

    let idTransformer = NumberTransformer<Any, Int64>()
    let titleTransformer = CastTransformer<Any, String>()
    let textTransformer = CastTransformer<Any, String>()
    let tagListTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceProductTagTransformer(), skipFailures: true)
    let imageTransformer = UrlTransformer<Any>()
    let detailedImageTransformer = UrlTransformer<Any>()
    let detailedContentTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceProductDetailedContentTransformer(), skipFailures: true)
    let detailedButtonTransformer = OptionalTransformer(transformer: InsuranceProductDetailedButtonTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let tagListResult = dictionary[tagListName].map(tagListTransformer.transform(source:)) ?? .failure(.requirement)
        let imageResult = dictionary[imageName].map(imageTransformer.transform(source:)) ?? .failure(.requirement)
        let detailedImageResult = dictionary[detailedImageName].map(detailedImageTransformer.transform(source:)) ?? .failure(.requirement)
        let detailedContentResult = dictionary[detailedContentName].map(detailedContentTransformer.transform(source:)) ?? .failure(.requirement)
        let detailedButtonResult = detailedButtonTransformer.transform(source: dictionary[detailedButtonName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        tagListResult.error.map { errors.append((tagListName, $0)) }
        imageResult.error.map { errors.append((imageName, $0)) }
        detailedImageResult.error.map { errors.append((detailedImageName, $0)) }
        detailedContentResult.error.map { errors.append((detailedContentName, $0)) }
        detailedButtonResult.error.map { errors.append((detailedButtonName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let text = textResult.value,
            let tagList = tagListResult.value,
            let image = imageResult.value,
            let detailedImage = detailedImageResult.value,
            let detailedContent = detailedContentResult.value,
            let detailedButton = detailedButtonResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                text: text,
                tagList: tagList,
                image: image,
                detailedImage: detailedImage,
                detailedContent: detailedContent,
                detailedButton: detailedButton
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let textResult = textTransformer.transform(destination: value.text)
        let tagListResult = tagListTransformer.transform(destination: value.tagList)
        let imageResult = imageTransformer.transform(destination: value.image)
        let detailedImageResult = detailedImageTransformer.transform(destination: value.detailedImage)
        let detailedContentResult = detailedContentTransformer.transform(destination: value.detailedContent)
        let detailedButtonResult = detailedButtonTransformer.transform(destination: value.detailedButton)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        tagListResult.error.map { errors.append((tagListName, $0)) }
        imageResult.error.map { errors.append((imageName, $0)) }
        detailedImageResult.error.map { errors.append((detailedImageName, $0)) }
        detailedContentResult.error.map { errors.append((detailedContentName, $0)) }
        detailedButtonResult.error.map { errors.append((detailedButtonName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let text = textResult.value,
            let tagList = tagListResult.value,
            let image = imageResult.value,
            let detailedImage = detailedImageResult.value,
            let detailedContent = detailedContentResult.value,
            let detailedButton = detailedButtonResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[textName] = text
        dictionary[tagListName] = tagList
        dictionary[imageName] = image
        dictionary[detailedImageName] = detailedImage
        dictionary[detailedContentName] = detailedContent
        dictionary[detailedButtonName] = detailedButton
        return .success(dictionary)
    }
}
