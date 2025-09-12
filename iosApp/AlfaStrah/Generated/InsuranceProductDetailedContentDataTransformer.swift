// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceProductDetailedContentDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceProductDetailedContentData

    let textName = "text"
    let linkedTextName = "text"
    let textArrayName = "text_list"
    let imageName = "image"

    let textTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let linkedTextTransformer = OptionalTransformer(transformer: LinkedTextTransformer())
    let textArrayTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true))
    let imageTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let textResult = textTransformer.transform(source: dictionary[textName])
        let linkedTextResult = linkedTextTransformer.transform(source: dictionary[linkedTextName])
        let textArrayResult = textArrayTransformer.transform(source: dictionary[textArrayName])
        let imageResult = imageTransformer.transform(source: dictionary[imageName])

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        linkedTextResult.error.map { errors.append((linkedTextName, $0)) }
        textArrayResult.error.map { errors.append((textArrayName, $0)) }
        imageResult.error.map { errors.append((imageName, $0)) }

        guard
            let text = textResult.value,
            let linkedText = linkedTextResult.value,
            let textArray = textArrayResult.value,
            let image = imageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                text: text,
                linkedText: linkedText,
                textArray: textArray,
                image: image
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let textResult = textTransformer.transform(destination: value.text)
        let linkedTextResult = linkedTextTransformer.transform(destination: value.linkedText)
        let textArrayResult = textArrayTransformer.transform(destination: value.textArray)
        let imageResult = imageTransformer.transform(destination: value.image)

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        linkedTextResult.error.map { errors.append((linkedTextName, $0)) }
        textArrayResult.error.map { errors.append((textArrayName, $0)) }
        imageResult.error.map { errors.append((imageName, $0)) }

        guard
            let text = textResult.value,
            let linkedText = linkedTextResult.value,
            let textArray = textArrayResult.value,
            let image = imageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[textName] = text
        dictionary[linkedTextName] = linkedText
        dictionary[textArrayName] = textArray
        dictionary[imageName] = image
        return .success(dictionary)
    }
}
