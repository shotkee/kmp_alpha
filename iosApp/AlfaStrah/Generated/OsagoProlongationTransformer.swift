// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongation

    let stateName = "state"
    let calculateInfoName = "calc_info"
    let errorInfoName = "error_info"
    let editInfoName = "edit_info"

    let stateTransformer = OsagoProlongationStateTypeTransformer()
    let calculateInfoTransformer = OptionalTransformer(transformer: OsagoProlongationCalculateInfoTransformer())
    let errorInfoTransformer = OptionalTransformer(transformer: OsagoProlongationErrorInfoTransformer())
    let editInfoTransformer = OptionalTransformer(transformer: OsagoProlongationEditInfoTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let stateResult = dictionary[stateName].map(stateTransformer.transform(source:)) ?? .failure(.requirement)
        let calculateInfoResult = calculateInfoTransformer.transform(source: dictionary[calculateInfoName])
        let errorInfoResult = errorInfoTransformer.transform(source: dictionary[errorInfoName])
        let editInfoResult = editInfoTransformer.transform(source: dictionary[editInfoName])

        var errors: [(String, TransformerError)] = []
        stateResult.error.map { errors.append((stateName, $0)) }
        calculateInfoResult.error.map { errors.append((calculateInfoName, $0)) }
        errorInfoResult.error.map { errors.append((errorInfoName, $0)) }
        editInfoResult.error.map { errors.append((editInfoName, $0)) }

        guard
            let state = stateResult.value,
            let calculateInfo = calculateInfoResult.value,
            let errorInfo = errorInfoResult.value,
            let editInfo = editInfoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                state: state,
                calculateInfo: calculateInfo,
                errorInfo: errorInfo,
                editInfo: editInfo
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let stateResult = stateTransformer.transform(destination: value.state)
        let calculateInfoResult = calculateInfoTransformer.transform(destination: value.calculateInfo)
        let errorInfoResult = errorInfoTransformer.transform(destination: value.errorInfo)
        let editInfoResult = editInfoTransformer.transform(destination: value.editInfo)

        var errors: [(String, TransformerError)] = []
        stateResult.error.map { errors.append((stateName, $0)) }
        calculateInfoResult.error.map { errors.append((calculateInfoName, $0)) }
        errorInfoResult.error.map { errors.append((errorInfoName, $0)) }
        editInfoResult.error.map { errors.append((editInfoName, $0)) }

        guard
            let state = stateResult.value,
            let calculateInfo = calculateInfoResult.value,
            let errorInfo = errorInfoResult.value,
            let editInfo = editInfoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[stateName] = state
        dictionary[calculateInfoName] = calculateInfo
        dictionary[errorInfoName] = errorInfo
        dictionary[editInfoName] = editInfo
        return .success(dictionary)
    }
}
