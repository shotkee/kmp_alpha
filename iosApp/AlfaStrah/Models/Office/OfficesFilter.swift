//
//  OfficesFilter.swift
//  AlfaStrah
//
//  Created by Darya Viter on 14.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Foundation

struct OfficesFilter {
    enum OfficeFilterType {
        case city(_ cities: [City])
        case searchString(_ string: String)
        case sale
        case claim
        case osagoClaim
        case cardPay
        case telematicsInstall
        case openNow

        var filterName: String {
            switch self {
                case .city: return NSLocalizedString("filter_name_cities", comment: "")
                case .searchString: return NSLocalizedString("filter_name_searchString", comment: "")
                case .sale: return NSLocalizedString("filter_name_sale", comment: "")
                case .claim: return NSLocalizedString("filter_name_claim", comment: "")
                case .osagoClaim: return NSLocalizedString("filter_name_osagoClaim", comment: "")
                case .cardPay: return NSLocalizedString("filter_name_cardPay", comment: "")
                case .telematicsInstall: return NSLocalizedString("filter_name_telematicsInstall", comment: "")
                case .openNow: return NSLocalizedString("filter_name_openNow", comment: "")
            }
        }
    }

    private(set) var officeFilters: [OfficeFilterType] = []

    mutating func clearFilters() {
        officeFilters = []
    }

    mutating func addFilter(_ officeFilterType: OfficeFilterType) {
        switch officeFilterType {
            case .city(let cities):
                remove([ .city([]) ])
                if !cities.isEmpty {
                    officeFilters.append(officeFilterType)
                }
            case .searchString(let string):
                remove([ .searchString("") ])
                if !string.isEmpty {
                    officeFilters.append(officeFilterType)
                }
            case .sale:
                remove([ .sale ])
                officeFilters.append(.sale)
            case .claim:
                remove([ .claim ])
                officeFilters.append(.claim)
            case .osagoClaim:
                remove([ .osagoClaim ])
                officeFilters.append(.osagoClaim)
            case .cardPay:
                remove([ .cardPay ])
                officeFilters.append(.cardPay)
            case .telematicsInstall:
                remove([ .telematicsInstall ])
                officeFilters.append(.telematicsInstall)
            case .openNow:
                remove([ .openNow ])
                officeFilters.append(.openNow)
        }
    }

    func filter(offices: [Office]) -> [Office] {
        var filteredOffices = offices
        officeFilters.forEach { filterType in
            switch filterType {
                case .searchString(string: let string):
                    guard !string.isEmpty else { return }

                    filteredOffices = filteredOffices.filter { $0.contains(string) }
                case .city(cities: let cities):
                    guard !cities.isEmpty else { return }

                    filteredOffices = filteredOffices.filter { office in cities.contains { $0.id == office.cityId } }
                case .sale:
                    filteredOffices = filteredOffices.filter { $0.purchaseActive }
                case .claim:
                    filteredOffices = filteredOffices.filter { $0.damageClaimAvailable }
                case .osagoClaim:
                    filteredOffices = filteredOffices.filter { $0.osagoClaimAvailable }
                case .cardPay:
                    filteredOffices = filteredOffices.filter { $0.cardPaymentAvailable }
                case .telematicsInstall:
                    filteredOffices = filteredOffices.filter { $0.telematicsInstallAvailable }
                case .openNow:
                    filteredOffices = filteredOffices.filter { office in
                        guard let officeWorkHours = office.getWorkTimeDates() else { return false }

                        let startTimeDateHour = AppLocale.dateComponentsOfDay(officeWorkHours.todayStartTime).hour ?? 0
                        let closeTimeDateHour = AppLocale.dateComponentsOfDay(officeWorkHours.todayCloseTime).hour ?? 0
                        let currentHour = AppLocale.dateComponentsOfDay(Date()).hour ?? 0

                        return office.isWorkToday && startTimeDateHour <= currentHour && closeTimeDateHour > currentHour
                    }
            }
        }
        return filteredOffices
    }

    mutating func remove(_ filterType: [OfficeFilterType]) {
        officeFilters = officeFilters.filter { filter in !filterType.contains { $0.filterName == filter.filterName } }
    }

    func filterListContains(_ filterType: OfficeFilterType) -> Bool {
        officeFilters.contains { $0.filterName == filterType.filterName }
    }

    func getSearchString() -> String? {
        guard let type = officeFilters.first(where: { $0.filterName == OfficeFilterType.searchString("").filterName })
        else { return nil }

        switch type {
            case .searchString(let string):
                return string
            case .city, .cardPay, .claim, .openNow, .osagoClaim, .sale, .telematicsInstall:
                return nil
        }
    }

    func getCitiesFromFilter() -> [City]? {
        guard let type = officeFilters.first(where: { $0.filterName == OfficeFilterType.city([]).filterName })
        else { return nil }

        switch type {
            case .city(let cities):
                return cities
            case .cardPay, .claim, .openNow, .osagoClaim, .sale, .searchString, .telematicsInstall:
                return nil
        }
    }
}
