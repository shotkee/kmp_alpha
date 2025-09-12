//
//  SetPinCodeViewController.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/21/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

final class SetPinCodeViewController: ViewController {
    struct Output {
        let submitCode: (String) -> Void
    }

    var output: Output!

    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var subTipLabel: UILabel!
    @IBOutlet private var warningLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var codeInputView: RMRCircleCodeInputView!
    @IBOutlet private var numPadContainer: UIView!
    @IBOutlet private var viewsToAnimate: [UIView]!

    private var shouldKeyboardAppear: Bool = false
    private var pinCodeString: String?
    private let keyboardBehavior: KeyboardBehavior = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        shouldKeyboardAppear = true
        codeInputView.gotFullCode = handleFirstInputCompleted(_:)
        infoLabel.text = NSLocalizedString("set_pin_screen_tip", comment: "")
        subTipLabel.text = NSLocalizedString("set_pin_screen_sub_tip", comment: "")

        keyboardBehavior.animations = { [weak self] frame, _, _ in
            guard let self = self else { return }

            self.warningLabelBottomConstraint.constant = frame.height
            self.view.layoutIfNeeded()
        }
        if traitCollection.userInterfaceIdiom == .pad {
            configureNumPadControl()
        }
		
		infoLabel <~ Style.Label.primaryHeadline1
		subTipLabel <~ Style.Label.secondaryText
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardBehavior.subscribe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard shouldKeyboardAppear || traitCollection.userInterfaceIdiom != .pad else { return }

        shouldKeyboardAppear = false
        codeInputView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardBehavior.unsubscribe()
        shouldKeyboardAppear = true
        codeInputView.resignFirstResponder()
    }

    private func handleFirstInputCompleted(_ fullCode: String) {
        pinCodeString = fullCode
        animateCodeInfoView { [weak self] in
            guard let self = self else { return }

            self.infoLabel.text = NSLocalizedString("set_pin_repeat_code", comment: "")
            self.codeInputView.clear()
            self.codeInputView.gotFullCode = self.handleSecondInputCompleted(_:)
        }
    }

    private func handleSecondInputCompleted(_ fullCode: String) {
        if pinCodeString == fullCode {
            submitCode(fullCode)
        } else {
            ErrorHelper.show(
                error: nil,
                text: NSLocalizedString("set_pin_error_not_equal_code", comment: ""),
                alertPresenter: alertPresenter
            )
            pinCodeString = nil
            animateCodeInfoView { [weak self] in
                guard let self = self else { return }

                self.infoLabel.text = NSLocalizedString("set_pin_screen_tip", comment: "")
                self.codeInputView.clear()
                self.codeInputView.gotFullCode = self.handleFirstInputCompleted(_:)
            }
        }
    }

    private func animateCodeInfoView(_ updates: @escaping () -> Void) {
        let horizontalOffset = -view.bounds.width
        numPadContainer.isUserInteractionEnabled = false
        animateInputBlockViews(horizontalOffset) { [weak self] _ in
            guard let self = self else { return }

            updates()
            self.animateInputBlockViews(0) { _ in
                self.numPadContainer.isUserInteractionEnabled = true
            }
        }
    }

    private func animateInputBlockViews(_ padding: CGFloat, completion: @escaping (Bool) -> Void) {
        var animationDelay: TimeInterval = 0
        for (index, view) in viewsToAnimate.enumerated() {
            UIView.animate(withDuration: 0.35, delay: animationDelay, options: [],
                animations: {
                    view.transform = CGAffineTransform(translationX: padding, y: 0)
                },
                completion: index + 1 < viewsToAnimate.count ? nil : completion
            )
            animationDelay += 0.026
        }
    }

    private func configureNumPadControl() {
        let numPadControl: NumPadControl = .fromNib()
        numPadControl.translatesAutoresizingMaskIntoConstraints = false
        numPadControl.customTitle = ""
        numPadContainer.addSubview(numPadControl)

        NSLayoutConstraint.activate([
            numPadControl.centerXAnchor.constraint(equalTo: numPadContainer.centerXAnchor),
            numPadControl.centerYAnchor.constraint(equalTo: numPadContainer.centerYAnchor),
            numPadControl.topAnchor.constraint(equalTo: numPadContainer.topAnchor, constant: 20),
            numPadControl.bottomAnchor.constraint(equalTo: numPadContainer.bottomAnchor, constant: -20)
        ])

        numPadControl.buttonTapped = { [weak self] pressedButton in
            guard let self = self else { return }

            if pressedButton.rawValue <= NumPadButtonType.button9.rawValue {
                let padNum = "\(pressedButton.rawValue)"
                let currentCode = self.codeInputView.currentValue
                self.codeInputView.changeCurrentCode(currentCode.appending(padNum))
            } else if pressedButton == .buttonRemove {
                let currentCode = self.codeInputView.currentValue
                if !currentCode.isEmpty {
                    self.codeInputView.changeCurrentCode(String(currentCode.dropLast()))
                }
            }
        }
    }

    private func submitCode(_ fullCode: String) {
        codeInputView.resignFirstResponder()
        output.submitCode(fullCode)
    }
}
