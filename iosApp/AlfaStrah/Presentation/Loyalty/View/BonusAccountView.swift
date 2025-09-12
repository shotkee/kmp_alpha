//
//  BonusAccountView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 5/14/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class BonusAccountView: UIView {
    struct Input {
        let accountId: String
        let alfaPoints: LoyaltyModel
    }

    struct Output {
        let programDetails: () -> Void
        let details: () -> Void
    }

    var input: Input! {
        didSet {
            updateUI()
        }
    }

    var output: Output!

    @IBOutlet private var bonusAccountNumberLabel: UILabel!
    @IBOutlet private var pointsAmountLabel: UILabel!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var totalPointsLabel: UILabel!
    @IBOutlet private var totalPointsAmountLabel: UILabel!
    @IBOutlet private var verticalSeparatorView: UIView!
    @IBOutlet private var spentPointsLabel: UILabel!
    @IBOutlet private var spentPointsAmountLabel: UILabel!
    @IBOutlet private var transactionsInfoLabel: UILabel!
    @IBOutlet private var programDetailsButton: RoundEdgeButton!
    @IBOutlet private var detailsButton: UIButton!
    @IBOutlet private var detailsImageView: UIImageView!
    @IBOutlet private var detailsLabel: UILabel!
    @IBOutlet private var detailsArrowImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
		backgroundColor = .Background.backgroundSecondary
        bonusAccountNumberLabel <~ Style.Label.secondaryCaption1
        pointsAmountLabel <~ Style.Label.primaryTitle2
        pointsLabel <~ Style.Label.primaryHeadline2
        totalPointsLabel <~ Style.Label.secondaryCaption1
        totalPointsLabel.text = NSLocalizedString("alfa_points_total_points", comment: "")
        totalPointsAmountLabel <~ Style.Label.primaryText
		verticalSeparatorView.backgroundColor = .Stroke.divider
        spentPointsLabel <~ Style.Label.secondaryCaption1
        spentPointsLabel.text = NSLocalizedString("alfa_points_spent_points", comment: "")
        spentPointsAmountLabel <~ Style.Label.primaryText
        transactionsInfoLabel <~ Style.Label.secondaryCaption1
        transactionsInfoLabel.text = NSLocalizedString("alfa_points_transactions_info", comment: "")
        programDetailsButton <~ Style.RoundedButton.redBordered
        programDetailsButton.setTitle(NSLocalizedString("alfa_points_program_details", comment: ""), for: .normal)
		detailsImageView.image = .Icons.document.tintedImage(withColor: .Icons.iconSecondary)
        detailsLabel <~ Style.Label.primaryText
        detailsLabel.text = NSLocalizedString("alfa_points_details", comment: "")
		detailsArrowImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
    }

    private func updateUI() {
        bonusAccountNumberLabel.text = String(format: NSLocalizedString("alfa_points_bonus_account_number", comment: ""), input.accountId)
        let scoreFormat = NSLocalizedString("alfa_points_score", comment: "")
        pointsAmountLabel.text = "\(Int(input.alfaPoints.amount))"
        pointsLabel.text = "-" + String.localizedStringWithFormat(scoreFormat, Int(input.alfaPoints.amount))
        totalPointsAmountLabel.text = "\(Int(input.alfaPoints.added)) "
            + String.localizedStringWithFormat(scoreFormat, Int(input.alfaPoints.added))
        spentPointsAmountLabel.text = "\(Int(input.alfaPoints.spent)) "
            + String.localizedStringWithFormat(scoreFormat, Int(input.alfaPoints.spent))
    }

    @IBAction private func detailsTap(_ sender: UIButton) {
        output.details()
    }

    @IBAction private func programDetailsTap(_ sender: UIButton) {
        output.programDetails()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let accessoryImage = detailsArrowImageView.image
		detailsArrowImageView.image = accessoryImage?.tintedImage(withColor: .Icons.iconSecondary)
		
		let detailsImage = detailsImageView.image
		detailsImageView.image = detailsImage?.tintedImage(withColor: .Icons.iconSecondary)
	}
}
