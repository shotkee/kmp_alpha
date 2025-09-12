// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DoctorVisitsResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorVisitsResponse

    let visitsName = "visit_list"
    let totalName = "total_count"

    let visitsTransformer = ArrayTransformer(from: Any.self, transformer: DoctorVisitTransformer(), skipFailures: true)
    let totalTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let visitsResult = dictionary[visitsName].map(visitsTransformer.transform(source:)) ?? .failure(.requirement)
        let totalResult = dictionary[totalName].map(totalTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        visitsResult.error.map { errors.append((visitsName, $0)) }
        totalResult.error.map { errors.append((totalName, $0)) }

        guard
            let visits = visitsResult.value,
            let total = totalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                visits: visits,
                total: total
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let visitsResult = visitsTransformer.transform(destination: value.visits)
        let totalResult = totalTransformer.transform(destination: value.total)

        var errors: [(String, TransformerError)] = []
        visitsResult.error.map { errors.append((visitsName, $0)) }
        totalResult.error.map { errors.append((totalName, $0)) }

        guard
            let visits = visitsResult.value,
            let total = totalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[visitsName] = visits
        dictionary[totalName] = total
        return .success(dictionary)
    }
}
