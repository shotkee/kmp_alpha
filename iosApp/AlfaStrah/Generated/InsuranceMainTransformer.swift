// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceMainTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceMain

    let insuranceGroupListName = "insurance_group_list"
    let sosListName = "sos_list"
    let sosEmergencyCommunicationName = "emergency_connection_screen"

    let insuranceGroupListTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceGroupTransformer(), skipFailures: true)
    let sosListTransformer = ArrayTransformer(from: Any.self, transformer: SosModelTransformer(), skipFailures: true)
    let sosEmergencyCommunicationTransformer = OptionalTransformer(transformer: SosEmergencyCommunicationTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceGroupListResult = dictionary[insuranceGroupListName].map(insuranceGroupListTransformer.transform(source:)) ?? .failure(.requirement)
        let sosListResult = dictionary[sosListName].map(sosListTransformer.transform(source:)) ?? .failure(.requirement)
        let sosEmergencyCommunicationResult = sosEmergencyCommunicationTransformer.transform(source: dictionary[sosEmergencyCommunicationName])

        var errors: [(String, TransformerError)] = []
        insuranceGroupListResult.error.map { errors.append((insuranceGroupListName, $0)) }
        sosListResult.error.map { errors.append((sosListName, $0)) }
        sosEmergencyCommunicationResult.error.map { errors.append((sosEmergencyCommunicationName, $0)) }

        guard
            let insuranceGroupList = insuranceGroupListResult.value,
            let sosList = sosListResult.value,
            let sosEmergencyCommunication = sosEmergencyCommunicationResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceGroupList: insuranceGroupList,
                sosList: sosList,
                sosEmergencyCommunication: sosEmergencyCommunication
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceGroupListResult = insuranceGroupListTransformer.transform(destination: value.insuranceGroupList)
        let sosListResult = sosListTransformer.transform(destination: value.sosList)
        let sosEmergencyCommunicationResult = sosEmergencyCommunicationTransformer.transform(destination: value.sosEmergencyCommunication)

        var errors: [(String, TransformerError)] = []
        insuranceGroupListResult.error.map { errors.append((insuranceGroupListName, $0)) }
        sosListResult.error.map { errors.append((sosListName, $0)) }
        sosEmergencyCommunicationResult.error.map { errors.append((sosEmergencyCommunicationName, $0)) }

        guard
            let insuranceGroupList = insuranceGroupListResult.value,
            let sosList = sosListResult.value,
            let sosEmergencyCommunication = sosEmergencyCommunicationResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceGroupListName] = insuranceGroupList
        dictionary[sosListName] = sosList
        dictionary[sosEmergencyCommunicationName] = sosEmergencyCommunication
        return .success(dictionary)
    }
}
