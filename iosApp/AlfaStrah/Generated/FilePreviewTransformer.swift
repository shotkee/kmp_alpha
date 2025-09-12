// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FilePreviewTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FilePreview

    let smallImageUrlName = "small_image_url"
    let bigImageUrlName = "big_image_url"
    let urlName = "url"

    let smallImageUrlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let bigImageUrlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let urlTransformer = UrlTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let smallImageUrlResult = smallImageUrlTransformer.transform(source: dictionary[smallImageUrlName])
        let bigImageUrlResult = bigImageUrlTransformer.transform(source: dictionary[bigImageUrlName])
        let urlResult = dictionary[urlName].map(urlTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        smallImageUrlResult.error.map { errors.append((smallImageUrlName, $0)) }
        bigImageUrlResult.error.map { errors.append((bigImageUrlName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let smallImageUrl = smallImageUrlResult.value,
            let bigImageUrl = bigImageUrlResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                smallImageUrl: smallImageUrl,
                bigImageUrl: bigImageUrl,
                url: url
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let smallImageUrlResult = smallImageUrlTransformer.transform(destination: value.smallImageUrl)
        let bigImageUrlResult = bigImageUrlTransformer.transform(destination: value.bigImageUrl)
        let urlResult = urlTransformer.transform(destination: value.url)

        var errors: [(String, TransformerError)] = []
        smallImageUrlResult.error.map { errors.append((smallImageUrlName, $0)) }
        bigImageUrlResult.error.map { errors.append((bigImageUrlName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let smallImageUrl = smallImageUrlResult.value,
            let bigImageUrl = bigImageUrlResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[smallImageUrlName] = smallImageUrl
        dictionary[bigImageUrlName] = bigImageUrl
        dictionary[urlName] = url
        return .success(dictionary)
    }
}
