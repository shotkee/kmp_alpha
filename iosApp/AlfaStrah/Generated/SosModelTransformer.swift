// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosModelTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosModel

    let kindName = "type"
    let insuranceCategoryName = "insurance_category"
    let sosPhoneName = "sos_phone"
    let isActiveName = "is_active"
    let isHealthFlowName = "is_health_flow"
    let insuranceCountName = "insurance_count"
    let instructionListName = "instruction_list"
    let sosActivityListName = "sos_activity_list"

    let kindTransformer = SosModelSosModelKindTransformer()
    let insuranceCategoryTransformer = OptionalTransformer(transformer: InsuranceCategoryMainTransformer())
    let sosPhoneTransformer = OptionalTransformer(transformer: SosPhoneTransformer())
    let isActiveTransformer = NumberTransformer<Any, Bool>()
    let isHealthFlowTransformer = NumberTransformer<Any, Bool>()
    let insuranceCountTransformer = NumberTransformer<Any, Int>()
    let instructionListTransformer = ArrayTransformer(from: Any.self, transformer: InstructionTransformer(), skipFailures: true)
    let sosActivityListTransformer = ArrayTransformer(from: Any.self, transformer: SosActivityModelTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let kindResult = dictionary[kindName].map(kindTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceCategoryResult = insuranceCategoryTransformer.transform(source: dictionary[insuranceCategoryName])
        let sosPhoneResult = sosPhoneTransformer.transform(source: dictionary[sosPhoneName])
        let isActiveResult = dictionary[isActiveName].map(isActiveTransformer.transform(source:)) ?? .failure(.requirement)
        let isHealthFlowResult = dictionary[isHealthFlowName].map(isHealthFlowTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceCountResult = dictionary[insuranceCountName].map(insuranceCountTransformer.transform(source:)) ?? .failure(.requirement)
        let instructionListResult = dictionary[instructionListName].map(instructionListTransformer.transform(source:)) ?? .failure(.requirement)
        let sosActivityListResult = dictionary[sosActivityListName].map(sosActivityListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        kindResult.error.map { errors.append((kindName, $0)) }
        insuranceCategoryResult.error.map { errors.append((insuranceCategoryName, $0)) }
        sosPhoneResult.error.map { errors.append((sosPhoneName, $0)) }
        isActiveResult.error.map { errors.append((isActiveName, $0)) }
        isHealthFlowResult.error.map { errors.append((isHealthFlowName, $0)) }
        insuranceCountResult.error.map { errors.append((insuranceCountName, $0)) }
        instructionListResult.error.map { errors.append((instructionListName, $0)) }
        sosActivityListResult.error.map { errors.append((sosActivityListName, $0)) }

        guard
            let kind = kindResult.value,
            let insuranceCategory = insuranceCategoryResult.value,
            let sosPhone = sosPhoneResult.value,
            let isActive = isActiveResult.value,
            let isHealthFlow = isHealthFlowResult.value,
            let insuranceCount = insuranceCountResult.value,
            let instructionList = instructionListResult.value,
            let sosActivityList = sosActivityListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                kind: kind,
                insuranceCategory: insuranceCategory,
                sosPhone: sosPhone,
                isActive: isActive,
                isHealthFlow: isHealthFlow,
                insuranceCount: insuranceCount,
                instructionList: instructionList,
                sosActivityList: sosActivityList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let kindResult = kindTransformer.transform(destination: value.kind)
        let insuranceCategoryResult = insuranceCategoryTransformer.transform(destination: value.insuranceCategory)
        let sosPhoneResult = sosPhoneTransformer.transform(destination: value.sosPhone)
        let isActiveResult = isActiveTransformer.transform(destination: value.isActive)
        let isHealthFlowResult = isHealthFlowTransformer.transform(destination: value.isHealthFlow)
        let insuranceCountResult = insuranceCountTransformer.transform(destination: value.insuranceCount)
        let instructionListResult = instructionListTransformer.transform(destination: value.instructionList)
        let sosActivityListResult = sosActivityListTransformer.transform(destination: value.sosActivityList)

        var errors: [(String, TransformerError)] = []
        kindResult.error.map { errors.append((kindName, $0)) }
        insuranceCategoryResult.error.map { errors.append((insuranceCategoryName, $0)) }
        sosPhoneResult.error.map { errors.append((sosPhoneName, $0)) }
        isActiveResult.error.map { errors.append((isActiveName, $0)) }
        isHealthFlowResult.error.map { errors.append((isHealthFlowName, $0)) }
        insuranceCountResult.error.map { errors.append((insuranceCountName, $0)) }
        instructionListResult.error.map { errors.append((instructionListName, $0)) }
        sosActivityListResult.error.map { errors.append((sosActivityListName, $0)) }

        guard
            let kind = kindResult.value,
            let insuranceCategory = insuranceCategoryResult.value,
            let sosPhone = sosPhoneResult.value,
            let isActive = isActiveResult.value,
            let isHealthFlow = isHealthFlowResult.value,
            let insuranceCount = insuranceCountResult.value,
            let instructionList = instructionListResult.value,
            let sosActivityList = sosActivityListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[kindName] = kind
        dictionary[insuranceCategoryName] = insuranceCategory
        dictionary[sosPhoneName] = sosPhone
        dictionary[isActiveName] = isActive
        dictionary[isHealthFlowName] = isHealthFlow
        dictionary[insuranceCountName] = insuranceCount
        dictionary[instructionListName] = instructionList
        dictionary[sosActivityListName] = sosActivityList
        return .success(dictionary)
    }
}
