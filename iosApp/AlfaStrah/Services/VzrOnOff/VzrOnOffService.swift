//
//  VzrOnOffService.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/8/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

protocol VzrOnOffService {
    func insurances(_ completion: @escaping (Result<[VzrOnOffInsurance], AlfastrahError>) -> Void)
    func dashboard(insuranceId: String, completion: @escaping (Result<VzrOnOffDashboardInfo, AlfastrahError>) -> Void)
    func timePackages(insuranceId: String, completion: @escaping (Result<[VzrOnOffPurchaseItem], AlfastrahError>) -> Void)
    func tripsHistory(insuranceId: String, completion: @escaping (Result<[VzrOnOffTrip], AlfastrahError>) -> Void)
    func purchaseHistory(insuranceId: String, completion: @escaping (Result<[VzrOnOffPurchaseHistoryItem], AlfastrahError>) -> Void)
    func landingUrl(_ completion: @escaping (Result<String, AlfastrahError>) -> Void)
    func programTerms(insuranceId: String, completion: @escaping (Result<VzrOnOffProgramTerms, AlfastrahError>) -> Void)
    func activateTrip(
        insuranceId: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<VzrOnOffActivateTripResponse, AlfastrahError>) -> Void
    )
    func purchaseLink(insuranceId: String, purchaseItemId: String, completion: @escaping (Result<String, AlfastrahError>) -> Void)
    func activeTripInsurance(useCache: Bool, completion: @escaping (Result<VzrOnOffInsurance?, AlfastrahError>) -> Void)
    func requestPermissionsIfNeeded()
    func vzrTerminateUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func vzrBonusesUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func vzrBonusFranchiseCerificatesUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func vzrBonusRefundUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func vzrReports(insuranceId: String, completion: @escaping (Result<[InsuranceReportVZR], AlfastrahError>) -> Void)
    func vzrReportDetailed(reportId: Int64, completion: @escaping (Result<InsuranceReportVZRDetailed, AlfastrahError>) -> Void)
}
