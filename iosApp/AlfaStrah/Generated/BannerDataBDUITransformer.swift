// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BannerDataBDUITransformer: Transformer {
    typealias Source = Any
    typealias Destination = BannerDataBDUI

    let titleName = "title"
    let textName = "text"
    let buttonTitleName = "button_text"

    let titleTransformer = CastTransformer<Any, String>()
    let textTransformer = CastTransformer<Any, String>()
    let buttonTitleTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let buttonTitleResult = dictionary[buttonTitleName].map(buttonTitleTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        buttonTitleResult.error.map { errors.append((buttonTitleName, $0)) }

        guard
            let title = titleResult.value,
            let text = textResult.value,
            let buttonTitle = buttonTitleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                text: text,
                buttonTitle: buttonTitle
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let textResult = textTransformer.transform(destination: value.text)
        let buttonTitleResult = buttonTitleTransformer.transform(destination: value.buttonTitle)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        buttonTitleResult.error.map { errors.append((buttonTitleName, $0)) }

        guard
            let title = titleResult.value,
            let text = textResult.value,
            let buttonTitle = buttonTitleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[textName] = text
        dictionary[buttonTitleName] = buttonTitle
        return .success(dictionary)
    }
}
