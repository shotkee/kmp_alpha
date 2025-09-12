//
//  GuaranteeLettersFilterCell.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 03.05.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class GuaranteeLettersFilterCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var roundedBackground: UIView!

    static let id: Reusable<GuaranteeLettersFilterCell> = .fromClass()

    func configure(title: String)
    {
        titleLabel.text = title
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        titleLabel.textColor = selected
			? .Text.textContrast
			: .Text.textPrimary

        roundedBackground.backgroundColor = selected
			? .Background.backgroundAccent
			: .clear

		updateBorderColor()
    }
	
	private func updateBorderColor() {
		roundedBackground.layer.borderColor = isSelected
			? UIColor.clear.cgColor
			: UIColor.Stroke.strokeBorder.cgColor
	}
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateBorderColor()
	}
}
