// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicTreatmentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicTreatment

    let idName = "id"
    let titleName = "title"
    let hasFranchiseName = "has_franchise"
    let franchisePercentageName = "franchise_size"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let hasFranchiseTransformer = NumberTransformer<Any, Bool>()
    let franchisePercentageTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let hasFranchiseResult = dictionary[hasFranchiseName].map(hasFranchiseTransformer.transform(source:)) ?? .failure(.requirement)
        let franchisePercentageResult = franchisePercentageTransformer.transform(source: dictionary[franchisePercentageName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        hasFranchiseResult.error.map { errors.append((hasFranchiseName, $0)) }
        franchisePercentageResult.error.map { errors.append((franchisePercentageName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let hasFranchise = hasFranchiseResult.value,
            let franchisePercentage = franchisePercentageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                hasFranchise: hasFranchise,
                franchisePercentage: franchisePercentage
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let hasFranchiseResult = hasFranchiseTransformer.transform(destination: value.hasFranchise)
        let franchisePercentageResult = franchisePercentageTransformer.transform(destination: value.franchisePercentage)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        hasFranchiseResult.error.map { errors.append((hasFranchiseName, $0)) }
        franchisePercentageResult.error.map { errors.append((franchisePercentageName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let hasFranchise = hasFranchiseResult.value,
            let franchisePercentage = franchisePercentageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[hasFranchiseName] = hasFranchise
        dictionary[franchisePercentageName] = franchisePercentage
        return .success(dictionary)
    }
}
