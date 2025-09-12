//
//  RestEventReportLoggerService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy
import os

class RestEventReportLoggerService: EventReportLoggerService {
    private let rest: FullRestClient
    private let store: Store

    init(rest: FullRestClient, store: Store) {
        self.rest = rest
        self.store = store
    }

    func applicationDidBecomeActiveEvent() {
        addLog("⬆️ Application did become active event", eventReportId: nil)

        sendAttachmentEventLogs(cachedAttachmentEventLogs())
    }

    func applicationDidEnterBackgroundEvent() {
        addLog("⬇️ Application did enter background event.", eventReportId: nil)
    }

    func applicationWillTerminateEvent() {
        addLog("❌ Application will terminate event.", eventReportId: nil)
    }

    // MARK: - Event logger

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy, HH:mm:ss"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    func addLog(_ message: String, eventReportId: String?) {
        if let eventReportId = eventReportId {
            addLog(message, eventReportId: eventReportId)
        } else {
            // Add log to all event report records
            for log in cachedAttachmentEventLogs() {
                addLog(message, eventReportId: log.eventReportId)
            }
        }
    }

    func logAttachmentSavingFalure(_ message: String) {
        let message = "[\(RestEventReportLoggerService.dateFormatter.string(from: Date()))]: Photo saving error: \(message)"
        let log = AttachmentSavingFailureLog(message: message)
        try? store.write { transaction in
            try transaction.upsert(log)
        }
    }

    private func addLog(_ message: String, eventReportId: String) {
        var log: AttachmentEventLog?
        try? self.store.read { transaction in
            let logs: [AttachmentEventLog] = try transaction.select(predicate: NSPredicate(format: "eventReportId = %@ AND closed == false",
                eventReportId))
            log = logs.first
        }

        var newLog = log ?? AttachmentEventLog(eventReportId: eventReportId, message: "", closed: false)
        newLog.message += "[\(RestEventReportLoggerService.dateFormatter.string(from: Date()))]: "
        newLog.message += message
        newLog.message += "\n"

        save(log: newLog)
    }

    private func save(log: AttachmentEventLog) {
        try? self.store.write { transaction in
            try transaction.upsert(log)
        }
    }

    private func cachedAttachmentEventLogs() -> [AttachmentEventLog] {
        var logs: [AttachmentEventLog] = []
        try? store.read { transaction in
            logs = try transaction.select()
        }
        return logs
    }

    private func cachedAttachmentSavingFailureLogs() -> [AttachmentSavingFailureLog] {
        var logs: [AttachmentSavingFailureLog] = []
        try? store.read { transaction in
            logs = try transaction.select()
        }
        return logs
    }

    private func sendAttachmentEventLogs(_ logs: [AttachmentEventLog]) {
        if let log = logs.first {
            sendAttachmentEventLog(log, logs: Array(logs.dropFirst())) { logs in
                self.sendAttachmentEventLogs(logs)
            }
        }
    }

    private func sendAttachmentEventLog(
        _ log: AttachmentEventLog,
        logs: [AttachmentEventLog],
        completion: @escaping ([AttachmentEventLog]) -> Void
    ) {
        var newLog = log
        newLog.closed = true
        save(log: newLog)
        let message = log.message + cachedAttachmentSavingFailureLogs().reduce("") { $0 + "\n" + $1.message }
        rest.create(
            path: "event_reports/\(log.eventReportId)/log",
            id: nil,
            object: [ "message": message ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: VoidTransformer()
        ) { result in
            switch result {
                case .success:
                    self.delete(log: log)
                    self.clearAttachmentSavingFalureLogs()
                    completion(logs)
                case .failure(let error):
                    self.addLog("❌ Logs upload failure. Error: \(error)",
                    eventReportId: log.eventReportId)
                    completion(logs)
            }
        }
    }

    private func delete(log: AttachmentEventLog) {
        try? store.write { transaction in
            try transaction.delete(type: AttachmentEventLog.self, predicate: NSPredicate(format: "eventReportId = %@ AND closed == true",
                log.eventReportId))
        }
    }

    private func clearAttachmentSavingFalureLogs() {
        try? store.write { transaction in
            try transaction.delete(type: AttachmentSavingFailureLog.self)
        }
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        try? store.write { transaction in
            try transaction.delete(type: AttachmentEventLog.self)
        }
    }
}
