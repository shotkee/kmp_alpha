//
//  InsuranceView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class ShortInsuranceView: UIView {
    @IBOutlet private var insuranceTitle: UILabel!
    @IBOutlet private var expirationLabel: UILabel!
    @IBOutlet private var tagLabel: UILabel!
    @IBOutlet private var warningLabelContainerView: UIView!
    @IBOutlet private var warningLabel: UILabel!
    @IBOutlet private var prolongButton: RoundEdgeButton!
    @IBOutlet private var prolongButtonContainerView: UIView!
    @IBOutlet private var tagLabelWidtConstraint: NSLayoutConstraint!

    var output: Output!

    struct Output {
        let insuranceTap: () -> Void
        let prolongTap: () -> Void
    }

    @IBAction private func insuranceTap(_ sender: UITapGestureRecognizer) {
        output.insuranceTap()
    }

    @IBAction private func prolongTap(_ sender: UIButton) {
        output.prolongTap()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = .Background.backgroundSecondary
        
        insuranceTitle <~ Style.Label.primaryHeadline2
        expirationLabel <~ Style.Label.secondaryCaption1
        tagLabel <~ Style.Label.secondaryCaption1
        prolongButton <~ Style.Button.redInvertRoundButton
        prolongButton.setTitle(NSLocalizedString("insurance_renew_without_changes", comment: ""), for: .normal)
        tagLabel.textAlignment = .center
        tagLabel.clipsToBounds = true
        tagLabel.layer.cornerRadius = 4
    }

    func set(
        title: String,
        subtitle: String,
        styleChange: Bool,
        tag: String?,
        showRenewButton: Bool,
        warning: String?,
        output: Output
    ) {
        self.output = output
        insuranceTitle.text = title
        insuranceTitle.textColor = styleChange
            ? .Text.textPrimary
            : .Text.textAccent
        expirationLabel.text = subtitle
        expirationLabel.textColor = styleChange
            ? .Text.textSecondary
            : .Text.textAccent
        prolongButtonContainerView.isHidden = !showRenewButton
        tagLabel.text = tag
        tagLabel.isHidden = tag == nil
        tagLabelWidtConstraint.constant = tag != nil ? 50 : 0

        warningLabelContainerView.isHidden = warning == nil
        warningLabel.text = warning
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		prolongButton <~ Style.Button.redInvertRoundButton
	}
}
