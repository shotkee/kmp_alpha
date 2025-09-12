//
//  RemontNeighboursRenewUnavailableViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 9/23/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

// swiftlint:disable:next type_name
class RemontNeighboursRenewUnavailableViewController: ViewController {
    struct Output {
        let call: () -> Void
        let chat: () -> Void
        let prolong: () -> Void
        let toMainScreen: () -> Void
    }

    var output: Output!

    @IBOutlet private var unavailableImageView: UIImageView!
    @IBOutlet private var unavailableTitleLabel: UILabel!
    @IBOutlet private var unavailableInfoLabel: UILabel!
    @IBOutlet private var callButtonImageView: UIImageView!
    @IBOutlet private var callButtonLabel: UILabel!
    @IBOutlet private var chatButtonImageView: UIImageView!
    @IBOutlet private var chatButtonLabel: UILabel!
    @IBOutlet private var prolongButton: RoundEdgeButton!
    @IBOutlet private var toMainScreenButton: RoundEdgeButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        unavailableImageView.image = UIImage(named: "icon-prolongation-unavailable")
        unavailableTitleLabel <~ Style.Label.primaryHeadline1
        unavailableTitleLabel.text = NSLocalizedString("insurance_renew_unavailable_screen_title", comment: "")
        unavailableInfoLabel <~ Style.Label.secondaryText
        unavailableInfoLabel.text = NSLocalizedString("insurance_renew_unavailable_screen_info", comment: "")
        callButtonImageView.image = UIImage(named: "icon-insurances-phone")
        callButtonLabel <~ Style.Label.secondaryText
        callButtonLabel.text = NSLocalizedString("common_call", comment: "")
        chatButtonImageView.image = UIImage(named: "icon-sos-action-chat")
        chatButtonLabel <~ Style.Label.secondaryText
        chatButtonLabel.text = NSLocalizedString("insurance_renew_unavailable_chat_button", comment: "")
        prolongButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        prolongButton.setTitle(NSLocalizedString("insurance_renew_unavailable_prolong_button", comment: ""), for: .normal)
		toMainScreenButton <~ Style.RoundedButton.redTitleMediumWithoutBorder
        toMainScreenButton.setTitle(NSLocalizedString("insurance_renew_unavailable_to_main_screen_button", comment: ""), for: .normal)
    }

    @IBAction private func prolongTap(_ sender: UIButton) {
        output.prolong()
    }

    @IBAction private func toMainScreenTap(_ sender: UIButton) {
        output.toMainScreen()
    }

    @IBAction private func callTap(_ sender: UIButton) {
        output.call()
    }

    @IBAction private func chatTap(_ sender: UIButton) {
        output.chat()
    }
}
