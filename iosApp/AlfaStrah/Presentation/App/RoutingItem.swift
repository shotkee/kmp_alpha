//
//  RoutingItem.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10/10/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation

enum RoutingItem {
    case tabBar(TabBarSection)
    case settings
    case sos
    case rateApp
    case login
	case signIn
    case logout
    case alfaPoints
    case insurancesList
    case telemedecine
    case kaskoProlongation(String)
    case eventReport(InsuranceEventFlow.EventReportId, Insurance)
    case vzrOnOffInsurance
    case buyInsurance
    case notifications(URL)
    case pincode
	case offices
	case insuranceBill(_ insuranceId: String, _ billId: Int)
}

enum TabBarSection {
    case home
    case chat
    case products
    case profile
}
