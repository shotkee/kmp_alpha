//
//  ClinicsTreatmentCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ClinicsTreatmentCell: UITableViewCell {
    static let id: Reusable<ClinicsTreatmentCell> = .fromNib()

    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var roundedBackground: UIView!

    private var normalIcon: UIImage?
    private var selectedIcon: UIImage?

	override func awakeFromNib() {
		super.awakeFromNib()

		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
	}
	
    func set(
        normalIcon: UIImage?,
        selectedIcon: UIImage? = nil,
        title: String,
        isFilterActive: Bool
    ) {
        self.normalIcon = normalIcon
        self.selectedIcon = selectedIcon

        iconImageView.image = normalIcon
        iconImageView.isHidden = normalIcon == nil

        titleLabel.text = title

        setSelected(isFilterActive)
    }

    private func setSelected(_ selected: Bool) {
        iconImageView.image = selected
            ? (selectedIcon ?? normalIcon)
            : normalIcon

        titleLabel.textColor = selected
			? .Text.textContrast
			: .Text.textPrimary

        roundedBackground.backgroundColor = selected
			? .Background.backgroundAccent
			: .clear

        roundedBackground.layer.borderColor = selected
            ? UIColor.clear.cgColor
			: UIColor.Stroke.strokeBorder.cgColor
    }
}
