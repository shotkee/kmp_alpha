// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InteractiveSupportDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportData

    let insuranceIdName = "insurance_id"
    let insuranceTitleName = "insurance_title"
    let insurerName = "insurer"
    let insuredName = "insured"
    let startScreenDataName = "start_screen_data"

    let insuranceIdTransformer = NumberTransformer<Any, Int>()
    let insuranceTitleTransformer = CastTransformer<Any, String>()
    let insurerTransformer = CastTransformer<Any, String>()
    let insuredTransformer = CastTransformer<Any, String>()
    let startScreenDataTransformer = InteractiveSupportStartScreenDataTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceTitleResult = dictionary[insuranceTitleName].map(insuranceTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let insurerResult = dictionary[insurerName].map(insurerTransformer.transform(source:)) ?? .failure(.requirement)
        let insuredResult = dictionary[insuredName].map(insuredTransformer.transform(source:)) ?? .failure(.requirement)
        let startScreenDataResult = dictionary[startScreenDataName].map(startScreenDataTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        insuranceTitleResult.error.map { errors.append((insuranceTitleName, $0)) }
        insurerResult.error.map { errors.append((insurerName, $0)) }
        insuredResult.error.map { errors.append((insuredName, $0)) }
        startScreenDataResult.error.map { errors.append((startScreenDataName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let insuranceTitle = insuranceTitleResult.value,
            let insurer = insurerResult.value,
            let insured = insuredResult.value,
            let startScreenData = startScreenDataResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                insuranceTitle: insuranceTitle,
                insurer: insurer,
                insured: insured,
                startScreenData: startScreenData
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let insuranceTitleResult = insuranceTitleTransformer.transform(destination: value.insuranceTitle)
        let insurerResult = insurerTransformer.transform(destination: value.insurer)
        let insuredResult = insuredTransformer.transform(destination: value.insured)
        let startScreenDataResult = startScreenDataTransformer.transform(destination: value.startScreenData)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        insuranceTitleResult.error.map { errors.append((insuranceTitleName, $0)) }
        insurerResult.error.map { errors.append((insurerName, $0)) }
        insuredResult.error.map { errors.append((insuredName, $0)) }
        startScreenDataResult.error.map { errors.append((startScreenDataName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let insuranceTitle = insuranceTitleResult.value,
            let insurer = insurerResult.value,
            let insured = insuredResult.value,
            let startScreenData = startScreenDataResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[insuranceTitleName] = insuranceTitle
        dictionary[insurerName] = insurer
        dictionary[insuredName] = insured
        dictionary[startScreenDataName] = startScreenData
        return .success(dictionary)
    }
}
