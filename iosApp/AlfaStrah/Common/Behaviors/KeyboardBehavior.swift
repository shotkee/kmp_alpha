//
//  KeyboardBehavior.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

/// Generic keyboard handler.
class KeyboardBehavior {
    var action: ((_ frame: CGRect, _ options: UIView.AnimationOptions, _ duration: TimeInterval) -> Void)?
    var animations: ((_ frame: CGRect, _ options: UIView.AnimationOptions, _ duration: TimeInterval) -> Void)?
    var animationCompletion: ((Bool) -> Void)?

    /// Adds keyboard notification handlers. Should be called when showing view controller.
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardSizeChanged),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    /// Removes keyboard notification handlers. Should be called when hiding view controller.
    func unsubscribe() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    /// Callback for keyboard size changed notification.
    @objc func keyboardSizeChanged(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else {
            return
        }

        let options = UIView.AnimationOptions(rawValue: curve << 16)
        action?(frame, options, duration)

        if let animations = animations {
            UIView.animate(withDuration: duration, delay: 0, options: options,
                animations: {
                    animations(frame, options, duration)
                },
                    completion: animationCompletion
            )
        }
    }
}
