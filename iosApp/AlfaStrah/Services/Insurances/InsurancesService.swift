//
//  InsurancesService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import Legacy

enum InsuranceOwnerKind {
    case me
    case forMe
}

protocol InsurancesService: Updatable {
    func cachedInsurances() -> [Insurance]
    func cachedInsurances(owner: InsuranceOwnerKind, includeArchive: Bool) -> [Insurance]
    func cachedInsurance(id: String) -> Insurance?
    func cachedInsuranceCategories() -> [InsuranceCategory]
    func cachedShortInsurances(forced: Bool) -> InsuranceMain?
    func cacheAnonymousSos(
        sosList: [SosModel],
        sosEmergencyCommunication: SosEmergencyCommunication?
    )
    func cachedAnonymousSos() -> AnonymousSos?
    
    func cachedSosInsured() -> [SosInsured]
    
    func resetPassengersInsurances()
    
    func subscribeForSingleInsuranceUpdate(listener: @escaping (Insurance) -> Void) -> Subscription
    
    func insurance(useCache: Bool, ids: [String], completion: @escaping (Result<[Insurance], AlfastrahError>) -> Void)
    func insurances(useCache: Bool, completion: @escaping (Result<InsuranceMain, AlfastrahError>) -> Void)
    func activateBoxProduct(
        _ insuranceActivateRequest: InsuranceActivateRequest,
        completion: @escaping (Result<InsuranceActivateResponse, AlfastrahError>) -> Void
    )
    func insurance(useCache: Bool, id: String, completion: @escaping (Result<Insurance, AlfastrahError>) -> Void)
    func updateInsurance(id: String)
    func allInsurances(completion: @escaping (Result<[Insurance], AlfastrahError>) -> Void)
    func insurances(owner: InsuranceOwnerKind, includeArchive: Bool,
        completion: @escaping (Result<[Insurance], AlfastrahError>) -> Void)
    func insuranceCategories(completion: @escaping (Result<[InsuranceCategory], AlfastrahError>) -> Void)
    func insuranceProducts(completion: @escaping (Result<[InsuranceProduct], AlfastrahError>) -> Void)
    func insuranceProductDealers(ownershipType: OwnershipType, completion: @escaping (Result<[InsuranceDealer], AlfastrahError>) -> Void)
    func insuranceProductDealerPrices(dealerId: String, completion: @escaping (Result<[Money], AlfastrahError>) -> Void)
    func insuranceSearchPolicyRequests(completion: @escaping (Result<[InsuranceSearchPolicyRequest], AlfastrahError>) -> Void)
    func insuranceSearchPolicyProducts(completion: @escaping (Result<[InsuranceSearchPolicyProduct], AlfastrahError>) -> Void)
    func insuranceSearchPolicyRequestCreate(policyId: String, insuranceNumber: String, date: Date?, photo: UIImage?,
        completion: @escaping (Result<InsuranceSearch, AlfastrahError>) -> Void)
    func insuranceSearchPolicyRequestNotify(policyId: String, completion: @escaping (Result<Void, AlfastrahError>) -> Void)
	func cachedShortInsurance(by id: String) -> InsuranceShort?

    // MARK: - URL

    /**
     Поддерживаемые к пролонгации на сайте типы полисов:
     ВЗР; Добрые соседи; Альфа-Ремонт; АльфаЭстейтКомплекс; ХотьПотоп; Муниципальное страхование
     - returns: Renew URL
     */
    @discardableResult
    func insuranceRenewUrl(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask
    @discardableResult
    func renewOnWebInsurance(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask
    func osagoChangeUrl(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask
    func osagoTerminationUrl(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask
    func reportOnWebsiteUrl(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask
    @discardableResult
    func insuranceFromListedProductsDeeplinkUrl(
        productId: String,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) -> NetworkTask
    @discardableResult
    func insuranceFromPreviousPurchaseDeeplinkUrl(
        productId: String,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) -> NetworkTask
    func renewUrlTerms(insuranceID: String, completion: @escaping (Result<OsagoProlongationURLs, AlfastrahError>) -> Void)
    func renewPrice(insuranceID: String, completion: @escaping (Result<InsuranceCalculation, AlfastrahError>) -> Void)
    func renewPriceProperty(insuranceID: String, completion: @escaping (Result<PropertyRenewCalcResponse, AlfastrahError>) -> Void)
    func renewInsurance(
        insuranceID: String,
        points: Int,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    )
    func telemedicineUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func telemedicineUrl(
        notificationId: String,
        insuranceId: String?,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    )
    func emergencyHelp(
        useCache: Bool,
        completion: @escaping (Result<[SosInsured], AlfastrahError>) -> Void
    )
    func cancelEmergencyHelp()
    func updateCache(for insurance: Insurance)
	func addConfidant(name: String, phone: String, completion: @escaping (Result<InfoMessage, AlfastrahError>) -> Void)
	func deleteConfidant(completion: @escaping (Result<InfoMessage, AlfastrahError>) -> Void)
	func checkOsagoBlock(completion: @escaping (Result<CheckOsagoBlock, AlfastrahError>) -> Void)
}
