// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceType

    let titleName = "title_insurance_type"
    let phonesName = "call_phone"
    let voipCallsName = "call_internet"

    let titleTransformer = CastTransformer<Any, String>()
    let phonesTransformer = ArrayTransformer(from: Any.self, transformer: PhoneTransformer(), skipFailures: true)
    let voipCallsTransformer = ArrayTransformer(from: Any.self, transformer: VoipCallTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let phonesResult = dictionary[phonesName].map(phonesTransformer.transform(source:)) ?? .failure(.requirement)
        let voipCallsResult = dictionary[voipCallsName].map(voipCallsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        phonesResult.error.map { errors.append((phonesName, $0)) }
        voipCallsResult.error.map { errors.append((voipCallsName, $0)) }

        guard
            let title = titleResult.value,
            let phones = phonesResult.value,
            let voipCalls = voipCallsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                phones: phones,
                voipCalls: voipCalls
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let phonesResult = phonesTransformer.transform(destination: value.phones)
        let voipCallsResult = voipCallsTransformer.transform(destination: value.voipCalls)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        phonesResult.error.map { errors.append((phonesName, $0)) }
        voipCallsResult.error.map { errors.append((voipCallsName, $0)) }

        guard
            let title = titleResult.value,
            let phones = phonesResult.value,
            let voipCalls = voipCallsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[phonesName] = phones
        dictionary[voipCallsName] = voipCalls
        return .success(dictionary)
    }
}
