//
//  Insurance.swift
//  AlfaStrah
//
//  Created by Станислав Старжевский on 11.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import Foundation

// sourcery: transformer
struct Insurance: Entity {
    private enum Constants {
        static let accidentProductId = "34"
        static let yandexCompanyName = "yandex"
    }

    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    // sourcery: transformer.name = "contract_number"
    var contractNumber: String

    // TODO: replace with mapped fields when backend is ready: https://redmadrobot.atlassian.net/browse/AS-5279
    var seriesAndNumber: SeriesAndNumberDocument {
        let seriesLength = 3
        let series = String(contractNumber.dropLast(contractNumber.count - seriesLength))
        let number = String(contractNumber.dropFirst(seriesLength))
        return .init(series: series, number: number)
    }

    // sourcery: transformer.name = "start_date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var startDate: Date

    // sourcery: transformer.name = "end_date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var endDate: Date

    var description: String?

    // sourcery: transformer.name = "InsurancePremium"
    var insurancePremium: String?

    // sourcery: transformer.name = "owner_participants"
    var ownerParticipants: [InsuranceParticipant]

    // sourcery: transformer.name = "insurer_participants"
    var insurerParticipants: [InsuranceParticipant]?

    // sourcery: transformer.name = "insured_participants"
    var insuredParticipants: [InsuranceParticipant]?

    // sourcery: transformer.name = "benefit_participants"
    var benefitParticipants: [InsuranceParticipant]?

    var drivers: [InsuranceParticipant]?

    // sourcery: transformer.name = "car"
    var vehicle: Vehicle?

    // sourcery: transformer.name = "trip_segments"
    var tripSegments: [TripSegment]?

    // sourcery: transformer.name = "product_id"
    var productId: String

    // sourcery: transformer.name = "renew_available"
    var renewAvailable: Bool?

    // sourcery: transformer.name = "renew_status"
    var osagoRenewStatus: Insurance.OsagoRenewStatusKind?

    // sourcery: transformer.name = "renew_url", transformer = "UrlTransformer<Any>()"
    var renewUrl: URL?

    // sourcery: transformer.name = "renew_insurance_id"
    var renewInsuranceId: String?

    // sourcery: transformer.name = "field_group_list"
    var fieldGroupList: [InfoFieldGroup]

    // sourcery: transformer.name = "insured_object"
    var insuredObjectTitle: String

    // sourcery: transformer.name = "emergency_phone"
    var emergencyPhone: Phone

    // sourcery: transformer.name = "sos_activities"
    var sosActivities: [SOSActivity]

    // sourcery: transformer.name = "clinic_id_list"
    var clinicIds: [String]?

    // sourcery: transformer.name = "access_clinic_phone"
    var accessClinicPhone: Bool?

    var type: Insurance.Kind

    // sourcery: transformer.name = "archive_date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var archiveDate: Date

    // sourcery: transformer.name = "file_link", transformer = "UrlTransformer<Any>()"
    var pdfURL: URL?

    // sourcery: transformer.name = "help_file", transformer = "UrlTransformer<Any>()"
    var helpURL: URL?
    
    // sourcery: transformer.name = "help_type"
    var helpType: HelpType?

    // sourcery: transformer.name = "passbook_available"
    var passbookAvailable: Bool?

    // sourcery: transformer.name = "passbook_available_online"
    var passbookAvailableOnline: Bool?

    // sourcery: transformer.name = "insurance_id_outer"
    var insuranceIdOuter: String?

    // sourcery: transformer.name = "insurance_id_mobile_deeplink"
    var mobileDeeplinkID: String?

    // sourcery: transformer.name = "access_telemed"
    var telemedicine: Bool

    // sourcery: transformer.name = "is_insurer"
    var isInsurer: Bool

    // sourcery: transformer.name = "is_child"
    var isChild: Bool?

    var company: Insurance.Company?

    // sourcery: transformer.name = "child_phone"
    var kidsDoctorPhone: Phone?

    var bills: [InsuranceBill]

    // sourcery: transformer.name = "show_bills"
    var shouldShowBills: Bool

    // sourcery: transformer.name = "has_unpaid_bills"
    var hasUnpaidBills: Bool

    // sourcery: transformer.name = "show_garantee_letters"
    var shouldShowGuaranteeLetters: Bool
    
    // sourcery: transformer.name = "is_change_franch_program_available"
    var isFranchiseTransitionAvailable: Bool
    
    // sourcery: transformer.name = "additions"
    var servicesList: [Insurance.ServiceAvailabilty]
    
    // sourcery: enumTransformer
    enum ServiceAvailabilty: String {
        case vzrBonusPolicy = "vzr_bonus_site"
        case vzrFranchiseCerificate = "vzr_bonus_franchise_certificate_site"
        case vzrTermination = "termination"
        case kaskoPolicyExtension = "kasko_expansion_site"
        case vzrBonusRefundCertificate = "vzr_bonus_prepaid_refund"
        case osagoTermination = "web_termination"
        case osagoChange = "web_change"
        case dmsCostRecovery = "dms_compensation_request"
        case healthAcademy = "academzdrav"
        case medicalCard = "medicalfilestorage"
        case manageSubscription = "ns_manage_subscription_site"
        case appointBeneficiary = "ns_appoint_beneficiary_site"
        case editInsuranceAgreement = "insurance_change_site"
    }
    
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum HelpType: String {
        // sourcery: enumTransformer.value = "none", defaultCase
        case none = "none"
        // sourcery: enumTransformer.value = "file"
        case openFile = "file"
        // sourcery: enumTransformer.value = "html_tree"
        case blocks = "html_tree"
        // sourcery: enumTransformer.value = "html_tree_and_file"
        case blocksWithFile = "html_tree_and_file"
    }
    
    // sourcery: enumTransformer
    enum Kind: Int {
        // sourcery: defaultCase
        case unknown = 0
        case kasko = 1
        case osago = 2
        case dms = 3
        case vzr = 4
        case property = 5
        case passengers = 6
        case life = 7
        case accident = 8
        case vzrOnOff = 10
        case flatOnOff = 11
    }

    // sourcery: enumTransformer
    enum OsagoRenewStatusKind: Int {
        // sourcery: defaultCase
        case notAvailable = 0
        case renewAvailable = 1
        case renewInProgress = 2
        case raymentPending = 3
    }

    // sourcery: enumTransformer
    enum Company: String {
        // sourcery: defaultCase
        case unsupported = "unsupported"
        case yandex = "yandex"
    }
	
	// sourcery: transformer.name = "render"
	var render: InsuranceRender?
	
    // MARK: - Trip destinations and intermediate points, calculated from tripSegments
    var tripDeparture: String? {
        tripSegments?.first?.departure
    }

    var tripArrival: String? {
        tripSegments?.last?.arrival
    }

    var tripIntermediatePoints: [String] {
        guard let tripSegments = tripSegments, tripSegments.count > 1 else { return [] }

        var points: Set<String> = []
        for (index, tripSegment) in tripSegments.enumerated() {
            if index == 0 {
                points.insert(tripSegment.arrival)
            } else if index == tripSegments.count - 1 {
                points.insert(tripSegment.departure)
            } else {
                points.insert(tripSegment.arrival)
                points.insert(tripSegment.departure)
            }
        }

        return Array(points)
    }

    var isArchive: Bool {
        endDate.timeIntervalSinceNow <= 0
    }

    // TODO: - Remove this when accident event kind is deployed
    var isAccident: Bool {
        productId == Constants.accidentProductId
    }

    var isYandexEmployeeChild: Bool {
        isChild == true && company == .yandex
    }

    enum DoctorAppointmentType {
        case doctorAppointment
        case interactiveSupport
    }
    
    enum InsuranceEventKind {
        case none
        case auto
        case doctorAppointment(DoctorAppointmentType)
        case passengers
        case accident
        case vzr
        case propetry
    }

    enum RenewablePropertySubtype {
        case remont
        case kindNeighbours
    }

    var renewablePropertySubtype: RenewablePropertySubtype? {
        switch (type, productId) {
            case (.property, "12"):
                return .remont
            case (.property, "4"):
                return .kindNeighbours
            default:
                return nil
        }
    }

    var insuranceEventKind: InsuranceEventKind {
        switch type {
            case .accident:
                return .accident
                
            case .dms:
                if sosActivities.contains(.interactiveSupport) {
                    return .doctorAppointment(.interactiveSupport)
                }
                return .doctorAppointment(.doctorAppointment)
                
            case .kasko, .osago:
                return .auto
                
            case .passengers:
                return .passengers
                
            case .vzr, .vzrOnOff:
                return .vzr
                
            case .property:
                return .propetry

			case .unknown, .flatOnOff, .life:
                return .none
            
        }
    }

    var canCreateInsuranceEvent: Bool {
		if type == .life {
			return sosActivities.contains(.life)
		}
		switch insuranceEventKind {
			case .auto:
				let insuranceEvent = sosActivities.contains(.reportInsuranceEvent) && !isArchive
				let osagoEvent = sosActivities.contains(.reportOSAGOInsuranceEvent) && !isArchive
				return insuranceEvent || osagoEvent
				
			case .passengers:
				// Passangers can create event report even after Insurance is out of date.
				let passengersEvent = sosActivities.contains(.reportPassengersInsuranceEvent)
				let passengersWebEvent = sosActivities.contains(.reportPassengersInsuranceWebEvent)
				return passengersEvent || passengersWebEvent
				
			case .doctorAppointment:
				let doctorAppointment = sosActivities.contains(.doctorAppointment) && !isArchive
				let interactiveSupport = sosActivities.contains(.interactiveSupport) && !isArchive
				return doctorAppointment || interactiveSupport
				
			case .vzr:
				let vzrEvent = sosActivities.contains(.reportVzrInsuranceEvent)
				return vzrEvent
				
			case .accident:
				let accidentEvent = sosActivities.contains(.reportAccidentInsuranceEvent)
				return accidentEvent
				
			case .propetry:
				let propertyEvent = sosActivities.contains(.reportOnWebsite)
				return propertyEvent
				
			case .none:
				return false
		}
    }
    
    var isVzrBonusPolicyAvailable: Bool {
        return servicesList.contains { $0 == .vzrBonusPolicy }
    }
    
    var isVzrFranchiseCerificateAvailable: Bool {
        return servicesList.contains { $0 == .vzrFranchiseCerificate }
    }
    
    var isVzrTerminationAvailable: Bool {
        return servicesList.contains { $0 == .vzrTermination }
    }
    
    var isKaskoPolicyExtensionAvailable: Bool {
        return servicesList.contains { $0 == .kaskoPolicyExtension }
    }
    
    var isVzrRefundCertificateAvailable: Bool {
        return servicesList.contains { $0 == .vzrBonusRefundCertificate }
    }
    
    var isOsagoTerminationAvailable: Bool {
        return servicesList.contains { $0 == .osagoTermination }
    }
    
    var isOsagoChangeAvailable: Bool {
        return servicesList.contains { $0 == .osagoChange }
    }
    
    var isDmsCostRecoveryAvailable: Bool {
        return servicesList.contains { $0 == .dmsCostRecovery }
    }
    
    var isHealthAcademyAvailable: Bool {
        return servicesList.contains { $0 == .healthAcademy }
    }
    
    var isMedicalCardAvailable: Bool {
        return servicesList.contains { $0 == .medicalCard }
    }
    
    var isManageSubscriptionAvailable: Bool {
        return servicesList.contains { $0 == .manageSubscription }
    }
    
    var isAppointBeneficiaryAvailable: Bool {
        return servicesList.contains { $0 == .appointBeneficiary }
    }
    
    var isEditInsuranceAgreementAvailable: Bool {
        return servicesList.contains { $0 == .editInsuranceAgreement }
    }
}
