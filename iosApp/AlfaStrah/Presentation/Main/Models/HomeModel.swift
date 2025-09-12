//
//  HomeModel.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 06/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

enum HomeModel {
    enum WidgetSections {
        case currentlyActiveInsurances
        case notification
		case demo
        case stories
        case insurance
        case promo
        case faq
        case vzrDisclaimer
		case enterBDUI
    }

    enum InsuranceCategory {
        case auto
        case health
        case stuff
        case travel
        case pass
    }

    enum NotificationItem {
        case notification(_ appNotification: AppNotification)
        case alphaPoint
    }
}
