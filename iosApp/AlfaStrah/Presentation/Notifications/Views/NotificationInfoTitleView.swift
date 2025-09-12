//
// NotificationInfoTitleView
// AlfaStrah
//
// Created by Eugene Egorov on 22 November 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit

class NotificationInfoTitleView: UIView {
    @IBOutlet private var titleLabel: UILabel!

    func set(title: String?) {
        titleLabel.text = title
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupUI()
	}
	
	private func setupUI() {
		if let titleLabel {
			titleLabel <~ Style.Label.primaryText
		}
	}
}
