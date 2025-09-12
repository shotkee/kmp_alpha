//
// NotificationInfoFieldView
// AlfaStrah
//
// Created by Eugene Egorov on 22 November 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit

class NotificationInfoFieldView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!

    func set(title: String?, subtitle: String?) {
        titleLabel.text = title
        contentLabel.text = subtitle
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupUI()
	}
	
	private func setupUI() {
		if let titleLabel {
			titleLabel <~ Style.Label.secondaryText
		}
		
		if let contentLabel {
			contentLabel <~ Style.Label.primaryText
		}
	}
}
