//
//  LoyaltyStatusView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 5/15/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class LoyaltyStatusView: UIView {
    @IBOutlet private var currentStatusImageView: UIImageView!
    @IBOutlet private var currentStatusTitleLabel: UILabel!
    @IBOutlet private var currentStatusInfoLabel: UILabel!
    @IBOutlet private var currentStatusArrowImageView: UIImageView!
    @IBOutlet private var bronzeStarImageView: UIImageView!
    @IBOutlet private var silverStarImageView: UIImageView!
    @IBOutlet private var goldStarImageView: UIImageView!
    @IBOutlet private var bronzeToSilverLineView: UIView!
    @IBOutlet private var silverToGoldLineView: UIView!
    @IBOutlet private var bronzeTitleLabel: UILabel!
    @IBOutlet private var silverTitleLabel: UILabel!
    @IBOutlet private var goldTitleLabel: UILabel!
    @IBOutlet private var bronzeBonusPercentageLabel: UILabel!
    @IBOutlet private var silverBonusPercentageLabel: UILabel!
    @IBOutlet private var goldBonusPercentageLabel: UILabel!
    @IBOutlet private var bronzeInfoLabel: UILabel!
    @IBOutlet private var silverInfoLabel: UILabel!
    @IBOutlet private var goldInfoLabel: UILabel!
    @IBOutlet private var fullInfoView: UIView!
    private var isFullSize: Bool = false {
        didSet {
            guard isFullSize != oldValue else { return }

            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
        updateUI()
    }

    private func setupUI() {
		backgroundColor = .Background.backgroundSecondary
		
        currentStatusTitleLabel <~ Style.Label.primaryHeadline1
        currentStatusInfoLabel <~ Style.Label.secondaryCaption1
        bronzeTitleLabel <~ Style.Label.primaryHeadline3
        silverTitleLabel <~ Style.Label.primaryHeadline3
        goldTitleLabel <~ Style.Label.primaryHeadline3
        bronzeBonusPercentageLabel <~ Style.Label.primaryHeadline3
        silverBonusPercentageLabel <~ Style.Label.primaryHeadline3
        goldBonusPercentageLabel <~ Style.Label.primaryHeadline3
        bronzeInfoLabel <~ Style.Label.primaryCaption1
        silverInfoLabel <~ Style.Label.primaryCaption1
        goldInfoLabel <~ Style.Label.primaryCaption1
		currentStatusImageView.image = .Icons.star.tintedImage(withColor: .Icons.iconSecondary)
        bronzeStarImageView.image = UIImage(named: "icon-loyalty-bronze-star")
        silverStarImageView.image = UIImage(named: "icon-loyalty-silver-star")
        goldStarImageView.image = UIImage(named: "icon-loyalty-gold-star")
        bronzeTitleLabel.text = NSLocalizedString("alfa_points_bronze_status", comment: "")
        silverTitleLabel.text = NSLocalizedString("alfa_points_silver_status", comment: "")
        goldTitleLabel.text = NSLocalizedString("alfa_points_gold_status", comment: "")
        bronzeBonusPercentageLabel.text
            = LoyaltyModel
                .bonusAmountPercentage(.bronze)
                .map { String(format: NSLocalizedString("alfa_points_percentage", comment: ""), Int($0)) }
        silverBonusPercentageLabel.text
            = LoyaltyModel
                .bonusAmountPercentage(.silver)
                .map { String(format: NSLocalizedString("alfa_points_percentage", comment: ""), Int($0)) }
        goldBonusPercentageLabel.text
            = LoyaltyModel
                .bonusAmountPercentage(.gold)
                .map { String(format: NSLocalizedString("alfa_points_percentage", comment: ""), Int($0)) }
        bronzeInfoLabel.text = LoyaltyModel.loyaltyStatusInfo(.bronze)
        silverInfoLabel.text = LoyaltyModel.loyaltyStatusInfo(.silver)
        goldInfoLabel.text = LoyaltyModel.loyaltyStatusInfo(.gold)
    }

    private func updateUI() {
		let arrowImage = UIImage(
			named: isFullSize
				? "ico-accessory-up-arrow"
				: "ico-accessory-down-arrow"
		)?.tintedImage(withColor: .Icons.iconSecondary)
		
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.currentStatusArrowImageView.image = arrowImage
            self.fullInfoView.alpha = self.isFullSize ? 1 : 0
            self.fullInfoView.isHidden = !self.isFullSize
        }
    }

    func configure(loyaltyModel: LoyaltyModel) {
        currentStatusTitleLabel.text = String(
            format: NSLocalizedString("alfa_points_current_status", comment: ""),
            loyaltyModel.status
        )
        currentStatusInfoLabel.text = loyaltyModel.statusDescription
        switch loyaltyModel.timelineStatus {
            case .undefined:
				bronzeStarImageView.tintColor = .Icons.iconSecondary
                bronzeTitleLabel.textColor = .Icons.iconSecondary
                bronzeBonusPercentageLabel.textColor = .Icons.iconSecondary
                silverStarImageView.tintColor = .Icons.iconSecondary
                silverTitleLabel.textColor = .Icons.iconSecondary
                silverBonusPercentageLabel.textColor = .Icons.iconSecondary
                goldStarImageView.tintColor = .Icons.iconSecondary
                goldTitleLabel.textColor = .Icons.iconSecondary
                goldBonusPercentageLabel.textColor = .Icons.iconSecondary
                bronzeToSilverLineView.backgroundColor = .Icons.iconSecondary
                silverToGoldLineView.backgroundColor = .Icons.iconSecondary
            case .bronze:
                bronzeStarImageView.tintColor = .Icons.iconAccent
                bronzeTitleLabel.textColor = .Icons.iconAccent
                bronzeBonusPercentageLabel.textColor = .Icons.iconAccent
                silverStarImageView.tintColor = .Icons.iconSecondary
                silverTitleLabel.textColor = .Icons.iconSecondary
                silverBonusPercentageLabel.textColor = .Icons.iconSecondary
                goldStarImageView.tintColor = .Icons.iconSecondary
                goldTitleLabel.textColor = .Icons.iconSecondary
                goldBonusPercentageLabel.textColor = .Icons.iconSecondary
                bronzeToSilverLineView.backgroundColor = .Icons.iconSecondary
                silverToGoldLineView.backgroundColor = .Icons.iconSecondary
            case .silver:
                bronzeStarImageView.tintColor = .Icons.iconAccent
				bronzeTitleLabel.textColor = .Icons.iconPrimary
                bronzeBonusPercentageLabel.textColor = .Icons.iconPrimary
                silverStarImageView.tintColor = .Icons.iconAccent
                silverTitleLabel.textColor = .Icons.iconAccent
                silverBonusPercentageLabel.textColor = .Icons.iconAccent
                goldStarImageView.tintColor = .Icons.iconSecondary
                goldTitleLabel.textColor = .Icons.iconSecondary
                goldBonusPercentageLabel.textColor = .Icons.iconSecondary
                bronzeToSilverLineView.backgroundColor = .Icons.iconAccent
                silverToGoldLineView.backgroundColor = .Icons.iconSecondary
            case .gold:
                bronzeStarImageView.tintColor = .Icons.iconAccent
                bronzeTitleLabel.textColor = .Icons.iconPrimary
                bronzeBonusPercentageLabel.textColor = .Icons.iconPrimary
                silverStarImageView.tintColor = .Icons.iconAccent
                silverTitleLabel.textColor = .Icons.iconPrimary
                silverBonusPercentageLabel.textColor = .Icons.iconPrimary
                goldStarImageView.tintColor = .Icons.iconAccent
                goldTitleLabel.textColor = .Icons.iconAccent
                goldBonusPercentageLabel.textColor = .Icons.iconAccent
                bronzeToSilverLineView.backgroundColor = .Icons.iconAccent
                silverToGoldLineView.backgroundColor = .Icons.iconAccent
        }
    }

    @IBAction private func statusTap(_ sender: UIButton) {
        isFullSize.toggle()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		let currentStatusImage = currentStatusImageView.image
		currentStatusImageView.image = currentStatusImage?.tintedImage(withColor: .Icons.iconSecondary)
		
		let currentStatusArrowImage = currentStatusArrowImageView.image
		currentStatusArrowImageView.image = currentStatusArrowImage?.tintedImage(withColor: .Icons.iconSecondary)
	}
}
