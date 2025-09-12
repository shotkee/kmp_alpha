//
// CampaignDetailViewController
// AlfaStrah
//
// Created by Eugene Egorov on 20 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class CampaignDetailViewController: ViewController, AccountServiceDependency {
    var accountService: AccountService!

    var campaign: Campaign!

    @IBOutlet private var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("campaign_title", comment: "")
        update()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ico-nav-cancel"), style: .plain,
                target: self, action: #selector(close))
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    private func update() {
        let iconUrl = URL(string: campaign.imageUrl)
        let action = campaign.url.map { url -> () -> Void in
            return { [weak self] in
                guard let self = self else { return }

                if self.accountService.isDemo {
                    DemoAlertHelper().showDemoAlert(from: self)
                } else if let controller = SafariViewController.viewController(for: url) {
                    self.present(controller, animated: true)
                }
            }
        }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let campaignView = CampaignDetailView.fromNib()
        container?.resolve(campaignView)
        campaignView.set(
            title: campaign.title,
            description: campaign.fullDescription,
            iconUrl: iconUrl,
            action: action
        )
        stackView.addArrangedSubview(campaignView)
    }
}
