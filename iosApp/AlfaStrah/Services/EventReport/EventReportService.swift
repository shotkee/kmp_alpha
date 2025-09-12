//
//  EventReportService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

protocol EventReportService: Updatable {
    // MARK: - Passengers event reports

    func passengersEventReports(insuranceId: String, completion: @escaping (Result<[EventReport], AlfastrahError>) -> Void)
    func markPassengersEventWithNoPhotos(eventReportId: String, completion: @escaping (Result<FileUploadResponse, AlfastrahError>) -> Void)
    func passengersEventReport(reportId: String, completion: @escaping (Result<EventReport, AlfastrahError>) -> Void)
    func risks(insuranceId: String, completion: @escaping (Result<RisksResponse, AlfastrahError>) -> Void)
    func createPassengersEvent(_ event: CreatePassengersEventReport,
        completion: @escaping (Result<PassengersEventResponse, AlfastrahError>) -> Void
    )
    func passengersEventReportUrl(_ insuranceId: String?, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func vzrEventReportDeeplink(_ insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)

    // MARK: - AutoEvent event reports

    func kaskoEventReports(insuranceId: String, completion: @escaping (Result<[EventReportAuto], AlfastrahError>) -> Void)
    func osagoEventReports(insuranceId: String, completion: @escaping (Result<[EventReportAuto], AlfastrahError>) -> Void)
    func createKaskoEvent(_ event: CreateAutoEventReport, completion: @escaping (Result<String, AlfastrahError>) -> Void)
    func createOsagoEvent(_ event: CreateAutoEventReport, completion: @escaping (Result<String, AlfastrahError>) -> Void)
    func autoEventReport(
        reportId: InsuranceEventFlow.EventReportId,
        completion: @escaping (Result<EventReportAuto, AlfastrahError>) -> Void
    )
    func checkEuroProtocolAvailability(completion: @escaping (Result<Bool, AlfastrahError>) -> Void)

    // MARK: - Accident event reports

    func accidentEventReports(insuranceId: String, completion: @escaping (Result<[EventReportAccident], AlfastrahError>) -> Void)
    func createAccidentEvent(_ event: CreateAccidentEventReport, completion: @escaping (Result<String, AlfastrahError>) -> Void)
    func accidentEventReportRules(_ insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask
    func updateAccidentEventBankInfo(
        id: String,
        bik: String,
        accountNumber: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    )

    // MARK: - AutoEvent drafts

    func autoEventDrafts() -> [AutoEventDraft]
    func saveAutoEventDraft(_ draft: AutoEventDraft)
    func deleteAutoEventDraft(_ draft: AutoEventDraft)

    // MARK: - Passengers drafts

    func passengersDrafts() -> [PassengersEventDraft]
    func savePassengerDraft(_ draft: PassengersEventDraft)
    func deletePassengerDraft(_ draft: PassengersEventDraft)
    
    func urlForPaymentApplicationPdf( insuranceId: String, eventReportId: String) -> URL

    func subscribeForDraftUpdates(listener: @escaping () -> Void) -> Subscription
}
