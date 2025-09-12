//
// CampaignDetailView
// AlfaStrah
//
// Created by Eugene Egorov on 20 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class CampaignDetailView: UIView, ImageLoaderDependency {
    var imageLoader: ImageLoader!

    private var action: (() -> Void)?

    @IBOutlet private var iconImageView: NetworkImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        actionButton.setTitle(NSLocalizedString("common_details", comment: ""), for: .normal)
		actionButton.setTitleColor(.Text.textAccent, for: .normal)
		
		titleLabel <~ Style.Label.primaryHeadline1
		descriptionLabel <~ Style.Label.primaryText
    }

    func set(title: String?, description: String?, iconUrl: URL?, action: (() -> Void)?) {
        titleLabel.text = title
        descriptionLabel.text = description

        if let url = iconUrl {
            iconImageView.imageLoader = imageLoader
            iconImageView.imageUrl = url
        }

        actionButton.isHidden = action == nil
        self.action = action
    }

    @IBAction private func actionTap() {
        action?()
    }
}
