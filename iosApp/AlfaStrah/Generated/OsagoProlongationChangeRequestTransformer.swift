// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationChangeRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationChangeRequest

    let insuranceIdName = "insurance_id"
    let infoFieldsName = "info_fields"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let infoFieldsTransformer = ArrayTransformer(from: Any.self, transformer: OsagoProlongationEditedFieldTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let infoFieldsResult = dictionary[infoFieldsName].map(infoFieldsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        infoFieldsResult.error.map { errors.append((infoFieldsName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let infoFields = infoFieldsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                infoFields: infoFields
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let infoFieldsResult = infoFieldsTransformer.transform(destination: value.infoFields)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        infoFieldsResult.error.map { errors.append((infoFieldsName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let infoFields = infoFieldsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[infoFieldsName] = infoFields
        return .success(dictionary)
    }
}
