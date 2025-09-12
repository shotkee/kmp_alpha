// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct PhoneTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Phone

    let plainName = "plain"
    let humanReadableName = "human_readable"
    let voipCallName = "internet_call"

    let plainTransformer = CastTransformer<Any, String>()
    let humanReadableTransformer = CastTransformer<Any, String>()
    let voipCallTransformer = OptionalTransformer(transformer: VoipCallTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let plainResult = dictionary[plainName].map(plainTransformer.transform(source:)) ?? .failure(.requirement)
        let humanReadableResult = dictionary[humanReadableName].map(humanReadableTransformer.transform(source:)) ?? .failure(.requirement)
        let voipCallResult = voipCallTransformer.transform(source: dictionary[voipCallName])

        var errors: [(String, TransformerError)] = []
        plainResult.error.map { errors.append((plainName, $0)) }
        humanReadableResult.error.map { errors.append((humanReadableName, $0)) }
        voipCallResult.error.map { errors.append((voipCallName, $0)) }

        guard
            let plain = plainResult.value,
            let humanReadable = humanReadableResult.value,
            let voipCall = voipCallResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                plain: plain,
                humanReadable: humanReadable,
                voipCall: voipCall
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let plainResult = plainTransformer.transform(destination: value.plain)
        let humanReadableResult = humanReadableTransformer.transform(destination: value.humanReadable)
        let voipCallResult = voipCallTransformer.transform(destination: value.voipCall)

        var errors: [(String, TransformerError)] = []
        plainResult.error.map { errors.append((plainName, $0)) }
        humanReadableResult.error.map { errors.append((humanReadableName, $0)) }
        voipCallResult.error.map { errors.append((voipCallName, $0)) }

        guard
            let plain = plainResult.value,
            let humanReadable = humanReadableResult.value,
            let voipCall = voipCallResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[plainName] = plain
        dictionary[humanReadableName] = humanReadable
        dictionary[voipCallName] = voipCall
        return .success(dictionary)
    }
}
