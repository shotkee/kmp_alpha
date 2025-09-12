//
//  SosCallBackViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class SosCallBackViewController: ViewController, UITextFieldDelegate {
    struct Input {
        var insurance: InsuranceShort
        var userPhone: Phone?
        var selectedPosition: () -> LocationInfo
    }

    struct Output {
        var pickLocation: () -> Void
        var callback: (Callback) -> Void
    }

    struct Notify {
        var locationUpdated: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        locationUpdated: { [weak self] in
            self?.updateLocationView()
        }
    )

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var callbackButton: RoundEdgeButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var bottomLayoutConstraint: NSLayoutConstraint!

    private let keyboardBehavior = KeyboardBehavior()
    private let commentView: CommonNoteView = .init()
    private let phoneView: PhoneView = PhoneView()
    private let locationView: LocationInfoView = .fromNib()
    private var comment = ""

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .Background.backgroundContent

        title = NSLocalizedString("sos_callback_title", comment: "")

		callbackButton <~ Style.RoundedButton.redBackground
		callbackButton.setTitle(NSLocalizedString("sos_callback_action_button", comment: ""), for: .normal)

        keyboardBehavior.animations = { [weak self] frame, _, _ in
            guard let `self` = self else { return }

            let frameInView = self.view.convert(frame, from: nil)
            let offset = max(self.view.bounds.maxY - frameInView.minY - self.view.safeAreaInsets.bottom, 0)
            self.bottomLayoutConstraint.constant = offset
            self.view.layoutIfNeeded()

            if offset >= 0.1 {
                var firtResponderView: UIView?
                if self.phoneView.isFirstResponder {
                    firtResponderView = self.phoneView
                } else if self.commentView.isFirstResponder {
                    firtResponderView = self.commentView
                }
                if let view = firtResponderView {
                    let frame = view.convert(view.bounds, to: self.scrollView)
                    self.scrollView.scrollRectToVisible(frame, animated: true)
                }
            }
        }

        updateUI()
        fillDefaultPhoneNumber()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardBehavior.subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(false)
        keyboardBehavior.unsubscribe()
    }

    private func updateUI() {
        stackView.subviews.forEach { $0.removeFromSuperview() }

        let insuranceInfoView = CommonInsuranceInfoTitleView.fromNib()
        insuranceInfoView.set(
            title: input.insurance.title,
            subtitle: input.insurance.description ?? ""
        )
        stackView.addArrangedSubview(insuranceInfoView)

        locationView.mapTapAction = { [weak self] in
            self?.output.pickLocation()
        }
        stackView.addArrangedSubview(locationView)

        phoneView.phoneInput.descriptionLabel.font = Style.Font.text
		phoneView.phoneInput.descriptionColor = .Text.textSecondary
        phoneView.onTextDidChange = { [weak self] _ in
            self?.checkDataReady()
        }
        stackView.addArrangedSubview(phoneView)

        commentView.textViewChangedCallback = { [weak self] textView in
            self?.comment = textView.text
        }
        commentView.set(
            title: NSLocalizedString("sos_comment", comment: ""),
            note: "",
            placeholder: NSLocalizedString("sos_comment_placeholder", comment: ""),
            margins: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        )
        stackView.addArrangedSubview(commentView)
    }

    private func updateLocationView() {
        locationView.configure(
            coordinate: input.selectedPosition().position?.clLocationCoordinate,
            address: input.selectedPosition().address,
            isInsuranceEvent: true
        )
    }

    private func fillDefaultPhoneNumber() {
        phoneView.updatePhone(number: input.userPhone?.humanReadable ?? "")
    }

    private func checkDataReady() {
        let phoneIsDone = phoneView.plainPhone.count == 10
        callbackButton.isEnabled = phoneIsDone
    }

    @IBAction func callbackTap(_ sender: UIButton) {
        view.endEditing(false)
        let callback = Callback(
            coordinate: input.selectedPosition().position,
            phone: phoneView.plainPhone,
            message: comment,
            address: input.selectedPosition().address,
            insuranceId: input.insurance.id
        )
        output.callback(callback)
    }
}
