// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryInstructionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryInstruction

    let insurancePlanName = "details"
    let conditionsName = "step_list"
    let noticeName = "what_to_do_info"

    let insurancePlanTransformer = OptionalTransformer(transformer: DmsCostRecoveryInsurancePlanTransformer())
    let conditionsTransformer = ArrayTransformer(from: Any.self, transformer: DmsCostRecoveryConditionTransformer(), skipFailures: true)
    let noticeTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insurancePlanResult = insurancePlanTransformer.transform(source: dictionary[insurancePlanName])
        let conditionsResult = dictionary[conditionsName].map(conditionsTransformer.transform(source:)) ?? .failure(.requirement)
        let noticeResult = noticeTransformer.transform(source: dictionary[noticeName])

        var errors: [(String, TransformerError)] = []
        insurancePlanResult.error.map { errors.append((insurancePlanName, $0)) }
        conditionsResult.error.map { errors.append((conditionsName, $0)) }
        noticeResult.error.map { errors.append((noticeName, $0)) }

        guard
            let insurancePlan = insurancePlanResult.value,
            let conditions = conditionsResult.value,
            let notice = noticeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insurancePlan: insurancePlan,
                conditions: conditions,
                notice: notice
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insurancePlanResult = insurancePlanTransformer.transform(destination: value.insurancePlan)
        let conditionsResult = conditionsTransformer.transform(destination: value.conditions)
        let noticeResult = noticeTransformer.transform(destination: value.notice)

        var errors: [(String, TransformerError)] = []
        insurancePlanResult.error.map { errors.append((insurancePlanName, $0)) }
        conditionsResult.error.map { errors.append((conditionsName, $0)) }
        noticeResult.error.map { errors.append((noticeName, $0)) }

        guard
            let insurancePlan = insurancePlanResult.value,
            let conditions = conditionsResult.value,
            let notice = noticeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insurancePlanName] = insurancePlan
        dictionary[conditionsName] = conditions
        dictionary[noticeName] = notice
        return .success(dictionary)
    }
}
