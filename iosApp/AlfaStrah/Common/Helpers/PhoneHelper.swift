//
//  PhoneHelper.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import CoreTelephony

final class PhoneHelper: NSObject {
    // Show custom action sheet with actions to call or copy phone number
    static func handlePhone(plain: String, humanReadable: String) {
        guard let topViewController = UIHelper.topViewController() else { return }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let letters = NSCharacterSet.letters
        if humanReadable.rangeOfCharacter(from: letters) == nil {
            actionSheet.title = humanReadable
        } else {
            actionSheet.title = plain
        }

        if canCall(plain) {
            let callAction = UIAlertAction(title: NSLocalizedString("common_call", comment: ""), style: .default) { _ in
                callPhone(plain: plain)
            }
            actionSheet.addAction(callAction)
        }
        let copyAction = UIAlertAction(title: NSLocalizedString("common_copy", comment: ""), style: .default) { _ in
            UIPasteboard.general.string = humanReadable
        }
        actionSheet.addAction(copyAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
        actionSheet.addAction(cancelAction)
        topViewController.present(actionSheet, animated: true, completion: nil)
    }

    // Show custom confirmation alert to perform a phone call
    private static func callPhone(plain: String) {
        guard let url = URL(string: "telprompt://" + plain) else { return }

        UIApplication.shared.open(url, completionHandler: nil)
    }

    // Checks ability to call a phone number
    static func canCall(_ phone: String) -> Bool {
        deviceCanCall() && URL(string: "telprompt://" + phone) != nil
    }

    // Checks device ability to perform calls
    static func deviceCanCall() -> Bool {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return false }

        switch CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode {
            case .none:
                return false
            case .some(let code) where code.isEmpty:
                return false
            case .some:
                return true
        }
    }

    /// Show custom action sheet with phone numbers with call action, if device can call, and copy action, if not
    static func handlePhones(_ phones: [Phone]) {
        guard let topViewController = UIHelper.topViewController() else { return }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        var actions = [UIAlertAction]()

        phones.forEach { phone in
            let callAction = UIAlertAction(
                title: String(
                    format: NSLocalizedString("common_call_action", comment: ""),
                    phone.humanReadable
                ),
                style: .default
            ) { _ in
                if deviceCanCall() {
                    self.callPhone(plain: phone.plain)
                }
            }
			callAction.setValue(UIColor.Text.textPrimary, forKey: "titleTextColor")
            actions.append(callAction)
        }
        actions.forEach { actionSheet.addAction($0) }
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
        actionSheet.addAction(cancelAction)
        topViewController.present(actionSheet, animated: true, completion: nil)
    }
}
