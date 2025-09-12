// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CheckOsagoBlockTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CheckOsagoBlock

    let firstTitleName = "first_title"
    let firstDescriptionName = "first_description"
    let firstButtonTextName = "first_button_text"
    let innerTitleName = "inner_title"
    let innerDescriptionName = "inner_description"
    let innerInformationName = "inner_information"
    let innerButtonTextName = "inner_button_text"
    let urlName = "url"

    let firstTitleTransformer = CastTransformer<Any, String>()
    let firstDescriptionTransformer = CastTransformer<Any, String>()
    let firstButtonTextTransformer = CastTransformer<Any, String>()
    let innerTitleTransformer = CastTransformer<Any, String>()
    let innerDescriptionTransformer = CastTransformer<Any, String>()
    let innerInformationTransformer = CastTransformer<Any, String>()
    let innerButtonTextTransformer = CastTransformer<Any, String>()
    let urlTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let firstTitleResult = dictionary[firstTitleName].map(firstTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let firstDescriptionResult = dictionary[firstDescriptionName].map(firstDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let firstButtonTextResult = dictionary[firstButtonTextName].map(firstButtonTextTransformer.transform(source:)) ?? .failure(.requirement)
        let innerTitleResult = dictionary[innerTitleName].map(innerTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let innerDescriptionResult = dictionary[innerDescriptionName].map(innerDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let innerInformationResult = dictionary[innerInformationName].map(innerInformationTransformer.transform(source:)) ?? .failure(.requirement)
        let innerButtonTextResult = dictionary[innerButtonTextName].map(innerButtonTextTransformer.transform(source:)) ?? .failure(.requirement)
        let urlResult = dictionary[urlName].map(urlTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        firstTitleResult.error.map { errors.append((firstTitleName, $0)) }
        firstDescriptionResult.error.map { errors.append((firstDescriptionName, $0)) }
        firstButtonTextResult.error.map { errors.append((firstButtonTextName, $0)) }
        innerTitleResult.error.map { errors.append((innerTitleName, $0)) }
        innerDescriptionResult.error.map { errors.append((innerDescriptionName, $0)) }
        innerInformationResult.error.map { errors.append((innerInformationName, $0)) }
        innerButtonTextResult.error.map { errors.append((innerButtonTextName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let firstTitle = firstTitleResult.value,
            let firstDescription = firstDescriptionResult.value,
            let firstButtonText = firstButtonTextResult.value,
            let innerTitle = innerTitleResult.value,
            let innerDescription = innerDescriptionResult.value,
            let innerInformation = innerInformationResult.value,
            let innerButtonText = innerButtonTextResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                firstTitle: firstTitle,
                firstDescription: firstDescription,
                firstButtonText: firstButtonText,
                innerTitle: innerTitle,
                innerDescription: innerDescription,
                innerInformation: innerInformation,
                innerButtonText: innerButtonText,
                url: url
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let firstTitleResult = firstTitleTransformer.transform(destination: value.firstTitle)
        let firstDescriptionResult = firstDescriptionTransformer.transform(destination: value.firstDescription)
        let firstButtonTextResult = firstButtonTextTransformer.transform(destination: value.firstButtonText)
        let innerTitleResult = innerTitleTransformer.transform(destination: value.innerTitle)
        let innerDescriptionResult = innerDescriptionTransformer.transform(destination: value.innerDescription)
        let innerInformationResult = innerInformationTransformer.transform(destination: value.innerInformation)
        let innerButtonTextResult = innerButtonTextTransformer.transform(destination: value.innerButtonText)
        let urlResult = urlTransformer.transform(destination: value.url)

        var errors: [(String, TransformerError)] = []
        firstTitleResult.error.map { errors.append((firstTitleName, $0)) }
        firstDescriptionResult.error.map { errors.append((firstDescriptionName, $0)) }
        firstButtonTextResult.error.map { errors.append((firstButtonTextName, $0)) }
        innerTitleResult.error.map { errors.append((innerTitleName, $0)) }
        innerDescriptionResult.error.map { errors.append((innerDescriptionName, $0)) }
        innerInformationResult.error.map { errors.append((innerInformationName, $0)) }
        innerButtonTextResult.error.map { errors.append((innerButtonTextName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let firstTitle = firstTitleResult.value,
            let firstDescription = firstDescriptionResult.value,
            let firstButtonText = firstButtonTextResult.value,
            let innerTitle = innerTitleResult.value,
            let innerDescription = innerDescriptionResult.value,
            let innerInformation = innerInformationResult.value,
            let innerButtonText = innerButtonTextResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[firstTitleName] = firstTitle
        dictionary[firstDescriptionName] = firstDescription
        dictionary[firstButtonTextName] = firstButtonText
        dictionary[innerTitleName] = innerTitle
        dictionary[innerDescriptionName] = innerDescription
        dictionary[innerInformationName] = innerInformation
        dictionary[innerButtonTextName] = innerButtonText
        dictionary[urlName] = url
        return .success(dictionary)
    }
}
