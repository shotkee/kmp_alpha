//
//  AlertPresenter.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

/// Alert presenter protocol.
@objc protocol AlertPresenter {
    /// Shows an alert.
    /// - parameter alert: alert to show
    /// - returns: identity that can be used to hide alert
    @discardableResult
    func show(alert: NotificationAlert) -> NotificationAlertIdentity

    /// Hides an alert.
    /// - parameter id: notification alert identity that is returned when alert is being shown
    func hide(id: NotificationAlertIdentity)

    /// Hides all alerts.
    func hideAll()
}
