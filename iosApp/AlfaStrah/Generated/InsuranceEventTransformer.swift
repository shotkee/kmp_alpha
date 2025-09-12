// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceEventTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceEvent

    let idName = "id"
    let reportName = "report"

    let idTransformer = IdTransformer<Any>()
    let reportTransformer = EventReportTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let reportResult = dictionary[reportName].map(reportTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        reportResult.error.map { errors.append((reportName, $0)) }

        guard
            let id = idResult.value,
            let report = reportResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                report: report
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let reportResult = reportTransformer.transform(destination: value.report)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        reportResult.error.map { errors.append((reportName, $0)) }

        guard
            let id = idResult.value,
            let report = reportResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[reportName] = report
        return .success(dictionary)
    }
}
