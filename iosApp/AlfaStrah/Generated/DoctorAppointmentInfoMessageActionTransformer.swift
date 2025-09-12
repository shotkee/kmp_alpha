// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DoctorAppointmentInfoMessageActionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorAppointmentInfoMessageAction

    let titleName = "title"
    let typeName = "action"
    let textHexColorName = "button_text_color"
    let backgroundHexColorName = "button_color"

    let titleTransformer = CastTransformer<Any, String>()
    let typeTransformer = DoctorAppointmentInfoMessageActionActionTypeTransformer()
    let textHexColorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let backgroundHexColorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let textHexColorResult = textHexColorTransformer.transform(source: dictionary[textHexColorName])
        let backgroundHexColorResult = backgroundHexColorTransformer.transform(source: dictionary[backgroundHexColorName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        textHexColorResult.error.map { errors.append((textHexColorName, $0)) }
        backgroundHexColorResult.error.map { errors.append((backgroundHexColorName, $0)) }

        guard
            let title = titleResult.value,
            let type = typeResult.value,
            let textHexColor = textHexColorResult.value,
            let backgroundHexColor = backgroundHexColorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                type: type,
                textHexColor: textHexColor,
                backgroundHexColor: backgroundHexColor
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let typeResult = typeTransformer.transform(destination: value.type)
        let textHexColorResult = textHexColorTransformer.transform(destination: value.textHexColor)
        let backgroundHexColorResult = backgroundHexColorTransformer.transform(destination: value.backgroundHexColor)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        textHexColorResult.error.map { errors.append((textHexColorName, $0)) }
        backgroundHexColorResult.error.map { errors.append((backgroundHexColorName, $0)) }

        guard
            let title = titleResult.value,
            let type = typeResult.value,
            let textHexColor = textHexColorResult.value,
            let backgroundHexColor = backgroundHexColorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[typeName] = type
        dictionary[textHexColorName] = textHexColor
        dictionary[backgroundHexColorName] = backgroundHexColor
        return .success(dictionary)
    }
}
