// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosPhoneTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosPhone

    let titleName = "title"
    let descriptionName = "description"
    let phoneName = "phone"
    let voipCallName = "internet_call"

    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let phoneTransformer = CastTransformer<Any, String>()
    let voipCallTransformer = OptionalTransformer(transformer: VoipCallTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let voipCallResult = voipCallTransformer.transform(source: dictionary[voipCallName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        voipCallResult.error.map { errors.append((voipCallName, $0)) }

        guard
            let title = titleResult.value,
            let description = descriptionResult.value,
            let phone = phoneResult.value,
            let voipCall = voipCallResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                description: description,
                phone: phone,
                voipCall: voipCall
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let voipCallResult = voipCallTransformer.transform(destination: value.voipCall)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        voipCallResult.error.map { errors.append((voipCallName, $0)) }

        guard
            let title = titleResult.value,
            let description = descriptionResult.value,
            let phone = phoneResult.value,
            let voipCall = voipCallResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[phoneName] = phone
        dictionary[voipCallName] = voipCall
        return .success(dictionary)
    }
}
