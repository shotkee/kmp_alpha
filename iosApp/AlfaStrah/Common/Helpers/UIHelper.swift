//
//  UIHelper.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class UIHelper {
    /// Returns top modal view controller.
    static func findTopModal(controller: UIViewController) -> UIViewController {
        var result = controller

        if let controller = controller as? UITabBarController {
            if let modalController = controller.presentedViewController {
                result = modalController
            } else if let activeController = controller.selectedViewController {
                result = activeController
            }
        } else if let controller = controller as? UINavigationController {
            if let modalController = controller.presentedViewController {
                result = modalController
            } else if let activeController = controller.topViewController {
                result = activeController
            }
        } else if let modalController = controller.presentedViewController {
            result = modalController
        }

        if result !== controller {
            result = findTopModal(controller: result)
        }

        return result
    }

    static func topViewController() -> UIViewController? {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController.map(findTopModal)
    }

    static func openApplicationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(settingsUrl)
    }

    /// Shows geolocation requirement notification.
    static func showLocationRequiredAlert(from controller: UIViewController, locationServicesEnabled: Bool) {
        if locationServicesEnabled {
            let message = NSLocalizedString("location_denied", comment: "")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("common_settings_button", comment: ""), style: .default) { _ in
                UIHelper.openApplicationSettings()
            })
            controller.present(alert, animated: true, completion: nil)
        } else {
            let message = NSLocalizedString("location_restricted", comment: "")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("common_ok_button", comment: ""), style: .cancel, handler: nil))
            controller.present(alert, animated: true, completion: nil)
        }
    }

    static func showCalendarRequiredAlert(from controller: UIViewController) {
        let title = NSLocalizedString("calendar_access_denied_title", comment: "")
        let message = NSLocalizedString("calendar_access_denied_message", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("common_settings_button", comment: ""), style: .default) { _ in
            UIHelper.openApplicationSettings()
        })
        controller.present(alert, animated: true, completion: nil)
    }

    static func showMicrophoneRequiredAlert(from controller: ViewController) {
        let message = NSLocalizedString("microphone_access_require_message", comment: "")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("common_settings_button", comment: ""), style: .default) { _ in
            UIHelper.openApplicationSettings()
        })
      
        controller.present(alert, animated: true, completion: nil)
    }
}
