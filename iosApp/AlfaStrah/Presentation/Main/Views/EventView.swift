//
//  EventView.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 23/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class EventView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var eventNumberLabel: UILabel!
	@IBOutlet private var accessoryImageView: UIImageView!
	
	private var action: (() -> Void)?

    @IBAction func onTap(_ sender: Any) {
        action?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
		backgroundColor = .Background.backgroundSecondary
		
		accessoryImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
		
        titleLabel <~ Style.Label.primaryHeadline2
        subtitleLabel <~ Style.Label.primaryText
        eventNumberLabel <~ Style.Label.secondaryCaption1
    }

    func set(title: String, subtitle: String, color: UIColor, eventNumber: String, action: @escaping () -> Void) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        eventNumberLabel.text = eventNumber
        subtitleLabel.textColor = color
        self.action = action
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		let image = accessoryImageView.image
		
		accessoryImageView.image = image?.tintedImage(withColor: .Icons.iconSecondary)
	}
}
