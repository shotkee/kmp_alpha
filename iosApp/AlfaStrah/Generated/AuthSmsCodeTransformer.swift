// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AuthSmsCodeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AuthSmsCode

    let phoneName = "phone"
    let codeLengthName = "code_length"
    let codeTimeName = "code_time"

    let phoneTransformer = PhoneTransformer()
    let codeLengthTransformer = CastTransformer<Any, String>()
    let codeTimeTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let codeLengthResult = dictionary[codeLengthName].map(codeLengthTransformer.transform(source:)) ?? .failure(.requirement)
        let codeTimeResult = dictionary[codeTimeName].map(codeTimeTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        phoneResult.error.map { errors.append((phoneName, $0)) }
        codeLengthResult.error.map { errors.append((codeLengthName, $0)) }
        codeTimeResult.error.map { errors.append((codeTimeName, $0)) }

        guard
            let phone = phoneResult.value,
            let codeLength = codeLengthResult.value,
            let codeTime = codeTimeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                phone: phone,
                codeLength: codeLength,
                codeTime: codeTime
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let codeLengthResult = codeLengthTransformer.transform(destination: value.codeLength)
        let codeTimeResult = codeTimeTransformer.transform(destination: value.codeTime)

        var errors: [(String, TransformerError)] = []
        phoneResult.error.map { errors.append((phoneName, $0)) }
        codeLengthResult.error.map { errors.append((codeLengthName, $0)) }
        codeTimeResult.error.map { errors.append((codeTimeName, $0)) }

        guard
            let phone = phoneResult.value,
            let codeLength = codeLengthResult.value,
            let codeTime = codeTimeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[phoneName] = phone
        dictionary[codeLengthName] = codeLength
        dictionary[codeTimeName] = codeTime
        return .success(dictionary)
    }
}
