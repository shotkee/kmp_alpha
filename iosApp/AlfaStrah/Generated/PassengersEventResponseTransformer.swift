// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct PassengersEventResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = PassengersEventResponse

    let eventReportIdName = "event_report_id"
    let riskDocumentListName = "risk_document_list"

    let eventReportIdTransformer = IdTransformer<Any>()
    let riskDocumentListTransformer = ArrayTransformer(from: Any.self, transformer: RiskDocumentTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let eventReportIdResult = dictionary[eventReportIdName].map(eventReportIdTransformer.transform(source:)) ?? .failure(.requirement)
        let riskDocumentListResult = dictionary[riskDocumentListName].map(riskDocumentListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        eventReportIdResult.error.map { errors.append((eventReportIdName, $0)) }
        riskDocumentListResult.error.map { errors.append((riskDocumentListName, $0)) }

        guard
            let eventReportId = eventReportIdResult.value,
            let riskDocumentList = riskDocumentListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                eventReportId: eventReportId,
                riskDocumentList: riskDocumentList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let eventReportIdResult = eventReportIdTransformer.transform(destination: value.eventReportId)
        let riskDocumentListResult = riskDocumentListTransformer.transform(destination: value.riskDocumentList)

        var errors: [(String, TransformerError)] = []
        eventReportIdResult.error.map { errors.append((eventReportIdName, $0)) }
        riskDocumentListResult.error.map { errors.append((riskDocumentListName, $0)) }

        guard
            let eventReportId = eventReportIdResult.value,
            let riskDocumentList = riskDocumentListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[eventReportIdName] = eventReportId
        dictionary[riskDocumentListName] = riskDocumentList
        return .success(dictionary)
    }
}
