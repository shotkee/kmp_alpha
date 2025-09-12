// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceGroupTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceGroup

    let objectNameName = "object_name"
    let objectTypeName = "object_type"
    let insuranceGroupCategoryListName = "insurance_group_category_list"

    let objectNameTransformer = CastTransformer<Any, String>()
    let objectTypeTransformer = CastTransformer<Any, String>()
    let insuranceGroupCategoryListTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceGroupCategoryTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let objectNameResult = dictionary[objectNameName].map(objectNameTransformer.transform(source:)) ?? .failure(.requirement)
        let objectTypeResult = dictionary[objectTypeName].map(objectTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceGroupCategoryListResult = dictionary[insuranceGroupCategoryListName].map(insuranceGroupCategoryListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        objectNameResult.error.map { errors.append((objectNameName, $0)) }
        objectTypeResult.error.map { errors.append((objectTypeName, $0)) }
        insuranceGroupCategoryListResult.error.map { errors.append((insuranceGroupCategoryListName, $0)) }

        guard
            let objectName = objectNameResult.value,
            let objectType = objectTypeResult.value,
            let insuranceGroupCategoryList = insuranceGroupCategoryListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                objectName: objectName,
                objectType: objectType,
                insuranceGroupCategoryList: insuranceGroupCategoryList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let objectNameResult = objectNameTransformer.transform(destination: value.objectName)
        let objectTypeResult = objectTypeTransformer.transform(destination: value.objectType)
        let insuranceGroupCategoryListResult = insuranceGroupCategoryListTransformer.transform(destination: value.insuranceGroupCategoryList)

        var errors: [(String, TransformerError)] = []
        objectNameResult.error.map { errors.append((objectNameName, $0)) }
        objectTypeResult.error.map { errors.append((objectTypeName, $0)) }
        insuranceGroupCategoryListResult.error.map { errors.append((insuranceGroupCategoryListName, $0)) }

        guard
            let objectName = objectNameResult.value,
            let objectType = objectTypeResult.value,
            let insuranceGroupCategoryList = insuranceGroupCategoryListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[objectNameName] = objectName
        dictionary[objectTypeName] = objectType
        dictionary[insuranceGroupCategoryListName] = insuranceGroupCategoryList
        return .success(dictionary)
    }
}
