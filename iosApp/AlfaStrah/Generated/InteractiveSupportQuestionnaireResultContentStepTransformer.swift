// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InteractiveSupportQuestionnaireResultContentStepTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportQuestionnaireResultContent.Step

    let imageName = "image"
    let imageThemedName = "image_themed"
    let textName = "text"

    let imageTransformer = UrlTransformer<Any>()
    let imageThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let textTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let imageResult = dictionary[imageName].map(imageTransformer.transform(source:)) ?? .failure(.requirement)
        let imageThemedResult = imageThemedTransformer.transform(source: dictionary[imageThemedName])
        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        imageResult.error.map { errors.append((imageName, $0)) }
        imageThemedResult.error.map { errors.append((imageThemedName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }

        guard
            let image = imageResult.value,
            let imageThemed = imageThemedResult.value,
            let text = textResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                image: image,
                imageThemed: imageThemed,
                text: text
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let imageResult = imageTransformer.transform(destination: value.image)
        let imageThemedResult = imageThemedTransformer.transform(destination: value.imageThemed)
        let textResult = textTransformer.transform(destination: value.text)

        var errors: [(String, TransformerError)] = []
        imageResult.error.map { errors.append((imageName, $0)) }
        imageThemedResult.error.map { errors.append((imageThemedName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }

        guard
            let image = imageResult.value,
            let imageThemed = imageThemedResult.value,
            let text = textResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[imageName] = image
        dictionary[imageThemedName] = imageThemed
        dictionary[textName] = text
        return .success(dictionary)
    }
}
