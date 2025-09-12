// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosInsuredTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosInsured

    let titleName = "title"
    let fullNameName = "full_name"
    let insuranceTypesName = "insurance_types"

    let titleTransformer = CastTransformer<Any, String>()
    let fullNameTransformer = CastTransformer<Any, String>()
    let insuranceTypesTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceTypeTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let fullNameResult = dictionary[fullNameName].map(fullNameTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceTypesResult = dictionary[insuranceTypesName].map(insuranceTypesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        fullNameResult.error.map { errors.append((fullNameName, $0)) }
        insuranceTypesResult.error.map { errors.append((insuranceTypesName, $0)) }

        guard
            let title = titleResult.value,
            let fullName = fullNameResult.value,
            let insuranceTypes = insuranceTypesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                fullName: fullName,
                insuranceTypes: insuranceTypes
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let fullNameResult = fullNameTransformer.transform(destination: value.fullName)
        let insuranceTypesResult = insuranceTypesTransformer.transform(destination: value.insuranceTypes)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        fullNameResult.error.map { errors.append((fullNameName, $0)) }
        insuranceTypesResult.error.map { errors.append((insuranceTypesName, $0)) }

        guard
            let title = titleResult.value,
            let fullName = fullNameResult.value,
            let insuranceTypes = insuranceTypesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[fullNameName] = fullName
        dictionary[insuranceTypesName] = insuranceTypes
        return .success(dictionary)
    }
}
