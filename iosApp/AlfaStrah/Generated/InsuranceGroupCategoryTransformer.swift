// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceGroupCategoryTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceGroupCategory

    let insuranceCategoryName = "insurance_category"
    let insuranceListName = "insurance_list"
    let sosActivityName = "sos_activity"

    let insuranceCategoryTransformer = InsuranceCategoryMainTransformer()
    let insuranceListTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceShortTransformer(), skipFailures: true)
    let sosActivityTransformer = OptionalTransformer(transformer: SosActivityModelTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceCategoryResult = dictionary[insuranceCategoryName].map(insuranceCategoryTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceListResult = dictionary[insuranceListName].map(insuranceListTransformer.transform(source:)) ?? .failure(.requirement)
        let sosActivityResult = sosActivityTransformer.transform(source: dictionary[sosActivityName])

        var errors: [(String, TransformerError)] = []
        insuranceCategoryResult.error.map { errors.append((insuranceCategoryName, $0)) }
        insuranceListResult.error.map { errors.append((insuranceListName, $0)) }
        sosActivityResult.error.map { errors.append((sosActivityName, $0)) }

        guard
            let insuranceCategory = insuranceCategoryResult.value,
            let insuranceList = insuranceListResult.value,
            let sosActivity = sosActivityResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceCategory: insuranceCategory,
                insuranceList: insuranceList,
                sosActivity: sosActivity
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceCategoryResult = insuranceCategoryTransformer.transform(destination: value.insuranceCategory)
        let insuranceListResult = insuranceListTransformer.transform(destination: value.insuranceList)
        let sosActivityResult = sosActivityTransformer.transform(destination: value.sosActivity)

        var errors: [(String, TransformerError)] = []
        insuranceCategoryResult.error.map { errors.append((insuranceCategoryName, $0)) }
        insuranceListResult.error.map { errors.append((insuranceListName, $0)) }
        sosActivityResult.error.map { errors.append((sosActivityName, $0)) }

        guard
            let insuranceCategory = insuranceCategoryResult.value,
            let insuranceList = insuranceListResult.value,
            let sosActivity = sosActivityResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceCategoryName] = insuranceCategory
        dictionary[insuranceListName] = insuranceList
        dictionary[sosActivityName] = sosActivity
        return .success(dictionary)
    }
}
