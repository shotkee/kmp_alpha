//
//  AboutAppViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 5/16/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class AboutAppViewController: ViewController {
    @IBOutlet private var conditionsYandexMapsLabel: UILabel!
    @IBOutlet private var privacyPolicyLabel: UILabel!
    @IBOutlet private var introductionAppLabel: UILabel!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var versionLabel: UILabel!
    @IBOutlet private var rateAppLabel: UILabel!
    @IBOutlet private var proceedToAlfaSiteLabel: UILabel!
	@IBOutlet private var contentStackView: UIStackView!
	
	private lazy var rateAppHelper = RateAppBehavior()
	
	override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    struct Output {
        let openAppStore: (_ completion: @escaping (Result<String, AlfastrahError>) -> Void) -> Void
        let openIntroductionView: () -> Void
        let linkTap: (URL) -> Void
    }

    var output: Output!
    
    struct Input {
        let getPersonalDataUsageTermsUrls: (@escaping (PersonalDataUsageAndPrivacyPolicyURLs) -> Void) -> Void
    }
    
    var input: Input!

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
		contentStackView.backgroundColor = .Background.backgroundSecondary
		
        title = NSLocalizedString("about_app_title", comment: "")
		logoImageView.image = .Icons.alfa.resized(newWidth: 43)
        versionLabel <~ Style.Label.secondaryText
        versionLabel.text = String(format: NSLocalizedString("about_app_version", comment: ""), AppInfoService.applicationShortVersion)
        rateAppLabel <~ Style.Label.primaryText
        rateAppLabel.text = NSLocalizedString("about_app_rate_app", comment: "")
        proceedToAlfaSiteLabel <~ Style.Label.primaryText
        proceedToAlfaSiteLabel.text = NSLocalizedString("about_app_proceed_to_site", comment: "")
        conditionsYandexMapsLabel <~ Style.Label.primaryText
        conditionsYandexMapsLabel.text = NSLocalizedString("about_app_conditions_yandex_maps", comment: "")
        privacyPolicyLabel <~ Style.Label.primaryText
        privacyPolicyLabel.text = NSLocalizedString("about_app_privacy_policy", comment: "")
        introductionAppLabel <~ Style.Label.primaryText
        introductionAppLabel.text = NSLocalizedString("about_app_introduction", comment: "")
    }
    
    private enum PrivacyPolicyType {
        case yandexMaps
        case privacyPolicy
    }
    
    private func openWebPrivacyPolicyURL(_ privacyPolicyType: PrivacyPolicyType) {
        input.getPersonalDataUsageTermsUrls { [weak self] data in
            switch privacyPolicyType {
                case .yandexMaps:
                    self?.output.linkTap(data.yandexMapsPolicyUrl)
                case .privacyPolicy:
                    self?.output.linkTap(data.privacyPolicyUrl)
            }
        }
    }

    @IBAction private func rateTap(_ sender: UIButton) {
        let hide = showLoadingIndicator(message: nil)

        output.openAppStore { result in
            hide { }
            if case .failure(let error) = result {
                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
    @IBAction func introductionTap(_ sender: Any) {
        output.openIntroductionView()
    }
    
    @IBAction func privacyPolicyTap(_ sender: Any) {
        openWebPrivacyPolicyURL(.privacyPolicy)
    }
    
    @IBAction func proceedTap(_ sender: UIButton) {
        SafariViewController.open(kRMRContactsAlphaSite, from: self)
    }
    
    @IBAction func yandexMapTap(_ sender: Any) {
        openWebPrivacyPolicyURL(.yandexMaps)
    }
}
