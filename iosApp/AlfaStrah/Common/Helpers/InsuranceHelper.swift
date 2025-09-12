//
//  InsuranceHelper.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation

struct InsuranceHelper {
    static private var distanceFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter
    }()

    static func formatted(distanceMeters: Int) -> (value: String, symbol: String) {
        formatted(distanceMeters: Double(distanceMeters))
    }

    static func formatted(distanceMeters: Float) -> (value: String, symbol: String) {
        formatted(distanceMeters: Double(distanceMeters))
    }

    static func formatted(distanceMeters: Double) -> (value: String, symbol: String) {
        distanceFormatter.locale = AppLocale.currentLocale
        var distance = max(distanceMeters, 0)
        let distanceSymbol: String
        if distance < 1000 {
            distance = round(distance)
            distanceSymbol = NSLocalizedString("common_distance_unit_m", comment: "")
        } else {
            distance /= 1000
            distanceSymbol = NSLocalizedString("common_distance_unit_km", comment: "")
        }
        let distanceString = distanceFormatter.string(for: distance) ?? "\(distance)"

        return (value: distanceString, symbol: distanceSymbol)
    }

    static func groupInsurances(_ insurances: [Insurance], with insuranceCategories: [InsuranceCategory]) -> [GroupedInsurances] {
        var groupedInsurances: [InsuranceCategory: [Insurance]] = [:]

        for insurance in insurances {
            guard let category = insuranceCategories.first(where: { $0.productIds.contains(insurance.productId) }) else { continue }

            groupedInsurances[category, default: []].append(insurance)
        }

        return groupedInsurances
            .map { GroupedInsurances(category: $0.key, insurances: $0.value) }
            .sorted { $0.category.sortPriority < $1.category.sortPriority }
    }

    static func groupInsurances(_ insurances: [Insurance], category: InsuranceCategory, sosActivity: SOSActivity) -> GroupedInsurances {
        let insurances = filterInsurances(insurances, for: category).filter {
            sosActivityAvailable(sosActivity, for: category, in: $0.sosActivities)
        }
        return GroupedInsurances(category: category, insurances: insurances)
    }

    static func sosActivityAvailable(_ sosActivity: SOSActivity, for categoty: InsuranceCategory, in sosActivities: [SOSActivity]) -> Bool {
        let contains = sosActivities.contains(sosActivity)
        if sosActivity == .reportInsuranceEvent && !contains {
            switch categoty.kind {
                case .passengers:
                    return sosActivities.contains(.reportPassengersInsuranceEvent)
                case .auto:
                    return sosActivities.contains(.reportOSAGOInsuranceEvent)
                default:
                    break
            }
        }

        return contains
    }

    static func filterInsurances(_ insurances: [Insurance], for category: InsuranceCategory) -> [Insurance] {
        insurances
            .filter { category.productIds.contains($0.productId) }
            .sorted { $0.endDate < $1.endDate }
    }

    static func groupInsuranceSearchPolicyRequests(
        _ requests: [InsuranceSearchPolicyRequest],
        insuranceCategories: [InsuranceCategory],
        searchPolicyProducts: [InsuranceSearchPolicyProduct]
    ) -> [GroupedInsuranceSearchPolicyRequest] {
        var groupedRequests: [InsuranceCategory: [GroupedInsuranceSearchPolicyRequest.RequestInfo]] = [:]

        for searchPolicyRequest in requests {
            guard
                let category = insuranceCategories.first(where: { $0.productIds.contains(searchPolicyRequest.productId) }),
                let product = searchPolicyProducts.first(where: { $0.id == searchPolicyRequest.productId })
            else { continue }

            groupedRequests[category, default: []].append(.init(searchPolicyRequest: searchPolicyRequest, product: product))
        }

        return groupedRequests
            .map { GroupedInsuranceSearchPolicyRequest(category: $0.key, requestsInfo: $0.value) }
            .sorted { $0.category.sortPriority < $1.category.sortPriority }
    }

    /// Insurance expiration time left logic
    static func timeLeftString(for insurance: Insurance, category: InsuranceCategory) -> String? {
        let timeLeft = insurance.endDate.timeIntervalSinceNow
        let daysLeft = AppLocale.daysCount(fromDate: Date(), toDate: insurance.endDate, absolute: false)
        if timeLeft > 0, daysLeft <= category.daysLeft {
            return String(format: NSLocalizedString("insurance_valid_before_value", comment: ""),
                AppLocale.shortDateString(insurance.endDate))
        } else if timeLeft < 0 {
            return String(format: NSLocalizedString("insurance_expired_value", comment: ""), AppLocale.shortDateString(insurance.endDate))
        } else {
            return nil
        }
    }

    static func image(for type: InsuranceCategoryMain.CategoryType) -> UIImage? {
        switch type {
            case .auto, .unsupported:
                return .Icons.car
            case .health:
                return .Icons.medicalCase
            case .life:
				return .Icons.shieldAlfa
					.tintedImage(withColor: .Icons.iconAccent)
					.overlay(with: .Icons.shield.tintedImage(withColor: .Icons.iconContrast))
            case .passengers:
                return UIImage(named: "icon-insurances-ticket")
            case .property:
                return .Icons.home
            case .travel:
                return UIImage(named: "icon-insurances-plane")
        }
    }

    static func image(for type: SOSActivityKind) -> UIImage? {
        switch type {
            case .call:
				return .Icons.call
                
            case .callback:
				return .Icons.callBack

			case .life:
				return .Icons.question
            case
                .autoInsuranceEvent,
                .unsupported:
                return .Icons.car
                
            case
                .doctorAppointment,
                .interactiveSupport:
                return .Icons.medicalCase
                
            case .voipCall:
                return UIImage(named: "icon-sos-action-voipCall")
            case
                .passengersInsuranceEvent,
                .passengersInsuranceWebEvent:
                return UIImage(named: "icon-insurances-plane")
                
            case .onlinePayment:
				return .Icons.shieldAlfa
					.tintedImage(withColor: .Icons.iconAccent)
                
            case .vzrInsuranceEvent:
                return UIImage(named: "icon-insurances-plane")
                
            case .accidentInsuranceEvent:
                return .Icons.medicalCase
                
            case .onWebsite:
                return .Icons.home
                
        }
    }
	
	static func overlayForImage(for type: SOSActivityKind) -> UIImage? {
		switch type {
			case
				.call,
				.callback,
				.life,
				.autoInsuranceEvent,
				.unsupported,
				.doctorAppointment,
				.interactiveSupport,
				.voipCall,
				.passengersInsuranceEvent,
				.passengersInsuranceWebEvent,
				.vzrInsuranceEvent,
				.accidentInsuranceEvent,
				.onWebsite:

				return nil
			case .onlinePayment:
				return .Icons.shield.tintedImage(withColor: .Icons.iconContrast)
		}
	}

    static func defaultInsuranceUrlOfType(product: Product) -> URL? {
        let path: String
        switch product {
            case .kasko:
                path = "http://www.alfastrah.ru/individuals/auto/kasko/calc/"
            case .travel:
                path = "https://www.alfastrah.ru/individuals/travel/vzr/?utm_campaign=VZR_points&tag=mobileApp_points"
            case .remont:
                path = "http://www.alfastrah.ru/individuals/housing/flat/?utm_campaign=Alfa_Remont_points&tag=mobileApp_points"
            case .kindNeighbours:
                path = "http://www.alfastrah.ru/individuals/housing/protection/?utm_campaign=Dobrye_Sosedi_points&tag=mobileApp_points"
            case .osago:
                path = "http://www.alfastrah.ru/individuals/auto/eosago/calc/"
            case .antiOnko:
                path = "https://www.alfastrah.ru/individuals/life/antionko/calc/?utm_campaign=AntiOnko_points&tag=mobileApp_points"
            case .kidsAndSport:
                path = "https://www.alfastrah.ru/individuals/life/child-sport/"
            case .additionalDefence:
                path = "https://www.alfastrah.ru/individuals/life/additional-protection/"
        }
        guard let url = URL(string: path) else { return nil }

        return urlWithMobileFlagFrom(url: url)
    }

    private static func urlWithMobileFlagFrom(url: URL) -> URL {
        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let newItem = URLQueryItem(name: "mobile_client", value: "iOS")
        var queryItems = component?.queryItems ?? []
        queryItems.append(newItem)
        component?.queryItems = queryItems
        return component?.url ?? url
    }
}
