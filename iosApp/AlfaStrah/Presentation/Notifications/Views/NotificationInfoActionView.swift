//
// NotificationInfoActionView
// AlfaStrah
//
// Created by Eugene Egorov on 22 November 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit

class NotificationInfoActionView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var actionIconImageView: UIImageView!

    private var action: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTap))
        addGestureRecognizer(tapGesture)
		
		setupUI()
    }
	
	private func setupUI() {
		if let titleLabel {
			titleLabel <~ Style.Label.primaryHeadline1
		}
		
		if let subtitleLabel {
			subtitleLabel <~ Style.Label.secondaryText
		}
	}

    func set(title: String?, subtitle: String?, icon: UIImage?, action: (() -> Void)?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionIconImageView.image = icon
        self.action = action
    }

    @objc private func actionTap() {
        action?()
    }
}
