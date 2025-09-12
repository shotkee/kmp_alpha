//
//  UpdateAppViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11/09/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class UpdateAppViewController: ViewController, SessionServiceDependency, MobileDeviceTokenServiceDependency {
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var actionButton: RoundEdgeButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!
    
    @IBAction private func appStoreTap() {
        guard
            let urlString = appStoreLink?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlString)
        else { return }

        UIApplication.shared.open(url)
    }

    struct Input {
        let appAvailable: AppAvailable
    }
    
    struct Output {
        let onClose: () -> Void
    }
    
    var input: Input!
    var output: Output!

    var sessionService: UserSessionService!
    var mobileDeviceTokenService: MobileDeviceTokenService!

    private var appStoreLink: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        iconImageView.tintColor = Style.Color.main
        actionButton <~ Style.Button.redInvertRoundButton
        titleLabel <~ Style.Label.primaryHeadline1
        messageLabel <~ Style.Label.secondaryText
        messageLabel.text = nil
        actionButton.setTitle(NSLocalizedString("auth_update_app", comment: ""), for: .normal)

        configure(for: input.appAvailable)
    }

    private func hideUI(_ isHidden: Bool) {
        titleLabel.isHidden = isHidden
        messageLabel.isHidden = isHidden
        actionButton.isHidden = isHidden
    }

    private func configure(for appAvailable: AppAvailable) {
        switch appAvailable.status {
            case .fullyAvailable:
                hideUI(true)
                output.onClose()
            case .partlyBlocked:
                addCloseButton { [weak self] in
                    guard let self = self
                    else { return }
                    self.output.onClose()
                }
                titleLabel.text = appAvailable.title
                messageLabel.text = appAvailable.message
                appStoreLink = appAvailable.link
                hideUI(false)
            case .totalyBlocked:
                titleLabel.text = appAvailable.title
                messageLabel.text = appAvailable.message
                appStoreLink = appAvailable.link
                hideUI(false)
                output.onClose()
        }
    }
}
