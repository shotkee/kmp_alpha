// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicServiceHoursOptionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicServiceHoursOption

    let codeName = "code"
    let titleName = "title"

    let codeTransformer = CastTransformer<Any, String>()
    let titleTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let codeResult = dictionary[codeName].map(codeTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        codeResult.error.map { errors.append((codeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }

        guard
            let code = codeResult.value,
            let title = titleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                code: code,
                title: title
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let codeResult = codeTransformer.transform(destination: value.code)
        let titleResult = titleTransformer.transform(destination: value.title)

        var errors: [(String, TransformerError)] = []
        codeResult.error.map { errors.append((codeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }

        guard
            let code = codeResult.value,
            let title = titleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[codeName] = code
        dictionary[titleName] = title
        return .success(dictionary)
    }
}
