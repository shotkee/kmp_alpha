//
//  RestEventReportService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

class RestEventReportService: EventReportService {
    private let rest: FullRestClient
    private let store: Store
    private let notificationsService: LocalNotificationsService
    private let attachmentService: AttachmentService

    init(rest: FullRestClient, store: Store, notificationsService: LocalNotificationsService, attachmentService: AttachmentService) {
        self.rest = rest
        self.store = store
        self.notificationsService = notificationsService
        self.attachmentService = attachmentService
    }

    func createPassengersEvent(_ event: CreatePassengersEventReport,
        completion: @escaping (Result<PassengersEventResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/event_reports/risks/create",
            id: nil,
            object: event,
            headers: [:],
            requestTransformer: CreatePassengersEventReportTransformer(),
            responseTransformer: ResponseTransformer(transformer: PassengersEventResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func markPassengersEventWithNoPhotos(
        eventReportId: String,
        completion: @escaping (Result<FileUploadResponse, AlfastrahError>
    ) -> Void) {
        var requestArray: [Multipart] = []
        requestArray.append(Multipart(name: "documents_count", string: "\(0)"))

        rest.create(
            path: "event_reports/\(eventReportId)/risks/document",
            id: nil,
            object: requestArray,
            headers: [:],
            requestSerializer: MultipartSerializer(),
            responseSerializer: JsonModelTransformerHttpSerializer(
                transformer: ResponseTransformer(transformer: FileUploadResponseTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func createKaskoEvent(_ event: CreateAutoEventReport, completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        rest.create(
            path: "/event_reports/create_kasko",
            id: nil,
            object: event,
            headers: [:],
            requestTransformer: CreateAutoEventReportTransformer(),
            responseTransformer: ResponseTransformer(
                key: "event_report_kasko_id",
                transformer: CastTransformer<Any, String>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func createOsagoEvent(_ event: CreateAutoEventReport, completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        rest.create(
            path: "/event_reports/create_osago",
            id: nil,
            object: event,
            headers: [:],
            requestTransformer: CreateAutoEventReportTransformer(),
            responseTransformer: ResponseTransformer(
                key: "event_report_osago_id",
                transformer: CastTransformer<Any, String>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func passengersEventReports(insuranceId: String, completion: @escaping (Result<[EventReport], AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/\(insuranceId)/event_reports",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "event_report_list",
                transformer: ArrayTransformer(transformer: EventReportTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func kaskoEventReports(insuranceId: String, completion: @escaping (Result<[EventReportAuto], AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/\(insuranceId)/event_reports_kasko",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "event_report_list",
                transformer: ArrayTransformer(transformer: EventReportAutoTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func osagoEventReports(insuranceId: String, completion: @escaping (Result<[EventReportAuto], AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/\(insuranceId)/event_reports_osago",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "event_report_list",
                transformer: ArrayTransformer(transformer: EventReportAutoTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func createAccidentEvent(_ event: CreateAccidentEventReport, completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        rest.create(
            path: "api/event_reports/ns/create",
            id: nil,
            object: event,
            headers: [:],
            requestTransformer: CreateAccidentEventReportTransformer(),
            responseTransformer: ResponseTransformer(
                key: "event_report_ns_id",
                transformer: CastTransformer<Any, String>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func accidentEventReports(insuranceId: String, completion: @escaping (Result<[EventReportAccident], AlfastrahError>) -> Void) {
        rest.read(
            path: "api/event_reports/ns/list",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "event_report_list",
                transformer: ArrayTransformer(transformer: EventReportAccidentTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func accidentEventReportRules(_ insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask {
        rest.read(
            path: "api/event_reports/ns/program",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func updateAccidentEventBankInfo(
        id: String,
        bik: String,
        accountNumber: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/event_reports/ns/\(id)/payout",
            id: nil,
            object: BankInfoPayload(bik: bik, accountNumber: accountNumber),
            headers: [:],
            requestTransformer: BankInfoPayloadTransformer(),
            responseTransformer: ResponseTransformer(
                key: "success",
                transformer: CastTransformer<Any, Bool>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func passengersEventReport(reportId: String, completion: @escaping (Result<EventReport, AlfastrahError>) -> Void) {
        rest.read(
            path: "event_reports/passenger/\(reportId)",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "event_reponse", transformer: EventReportTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func autoEventReport(
        reportId: InsuranceEventFlow.EventReportId,
        completion: @escaping (Result<EventReportAuto, AlfastrahError>) -> Void
    ) {
        let pathString: String?
        let idString: String?
        switch reportId {
            case .kasko(let id):
                pathString = "event_reports/kasko/"
                idString = id
            case .osago(let id):
                pathString = "event_reports/osago/"
                idString = id
            case .passengers:
                pathString = nil
                idString = nil
        }
        guard
            let path = pathString,
            let id = idString
        else { return }

        rest.read(
            path: path.appending(id),
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "event_report", transformer: EventReportAutoTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func risks(insuranceId: String, completion: @escaping (Result<RisksResponse, AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/\(insuranceId)/risks",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: RisksResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func passengersEventReportUrl(_ insuranceId: String?, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/insurances/passengers/accident/deeplink/",
            id: nil,
            parameters: insuranceId
                .map { [ "insurance_id": $0 ] }
                ?? [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func vzrEventReportDeeplink(_ insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "event_reports/trip/deeplink",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "deeplink", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func checkEuroProtocolAvailability(completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/insurances/osagosdk/available",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "available", transformer: CastTransformer<Any, Bool>()),
            completion: mapCompletion { completion($0) }
        )
    }

    private var draftUpdateSubscriptions: Subscriptions<Void> = Subscriptions()

    func subscribeForDraftUpdates(listener: @escaping () -> Void) -> Subscription {
        draftUpdateSubscriptions.add(listener)
    }

    // MARK: - AutoEvent drafts

    func autoEventDrafts() -> [AutoEventDraft] {
        var drafts: [AutoEventDraft] = []
        try? store.read { transaction in
            drafts = try transaction.select()
        }

        return drafts
    }

    func saveAutoEventDraft(_ draft: AutoEventDraft) {
        if let oldDraft = autoEventDrafts().first, oldDraft.id != draft.id {
            deleteAutoEventDraft(oldDraft)
        }
        try? self.store.write { transaction in
            try transaction.upsert(draft)
        }
        attachmentService.saveDraftPhotos(draft.files)

        draftUpdateSubscriptions.fire(())
        notificationsService.removeNotifications(kind: .draftIncompleteVehicle)
        notificationsService.createLocalNotification(kind: .draftIncompleteVehicle)
    }

    func deleteAutoEventDraft(_ draft: AutoEventDraft) {
        try? store.write { transaction in
            try transaction.delete(type: AutoEventDraft.self, id: draft.id)
        }
        notificationsService.removeNotifications(kind: .draftIncompleteVehicle)
        attachmentService.deleteDraftPhotos(draft.files)
    }

    // MARK: - Passengers drafts

    func passengersDrafts() -> [PassengersEventDraft] {
        var drafts: [PassengersEventDraft] = []
        try? store.read { transaction in
            drafts = try transaction.select()
        }
        return drafts
    }

    func savePassengerDraft(_ draft: PassengersEventDraft) {
        deletePassengerDraft(draft)
        try? self.store.write { transaction in
            try transaction.insert(draft)
        }

        draftUpdateSubscriptions.fire(())
        notificationsService.removeNotifications(kind: .draftIncompletePassenger)
        notificationsService.createLocalNotification(kind: .draftIncompletePassenger)
    }

    func deletePassengerDraft(_ draft: PassengersEventDraft) {
        try? store.write { transaction in
            try transaction.delete(type: PassengersEventDraft.self, id: draft.id)
        }

        notificationsService.removeNotifications(kind: .draftIncompletePassenger)
    }
    
    func urlForPaymentApplicationPdf(
        insuranceId: String,
        eventReportId: String
    ) -> URL
    {
        var url = rest.baseURL.appendingPathComponent(
            "/api/event_reports/ns/claim"
        )
        
        return url.appendingQuery(items: ["insurance_id": insuranceId, "event_report_id": eventReportId])
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
            try transaction.delete(type: AutoEventDraft.self)
            try transaction.delete(type: PassengersEventDraft.self)
        }
    }
}
