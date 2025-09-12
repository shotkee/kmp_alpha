//
//  BonusHeaderView.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 3/6/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class BonusHeaderView: UIView {
    private enum Constants {
        static let cornerRadius: CGFloat = 19
        static let statusBackgroundCornerRadius: CGFloat = 13
    }

    struct Input {
        let loyaltyModel: (_ completion: @escaping (LoyaltyModel) -> Void) -> Void
    }

    struct Output {
        let onTap: () -> Void
    }

    struct Notify {
        let shouldUpdate: () -> Void
    }

    var input: Input!
    var output: Output!

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        shouldUpdate: { [weak self] in
            self?.updateUI()
        }
    )

    @IBOutlet private var bonusTitleLabel: UILabel!
    @IBOutlet private var bonusScoreAmountLabel: UILabel!
    @IBOutlet private var alfaIconImageView: UIImageView!
    @IBOutlet private var bonusScorePointsLabel: UILabel!
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var tillNextStatusLabel: UILabel!
    @IBOutlet private var tillNextStatusAmountLabel: UILabel!
    @IBOutlet private var statusBackgroundView: UIVisualEffectView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var arrowImageView: UIImageView!

    private let alfaPointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
        updateUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        backgroundImageView.layer.cornerRadius = Constants.cornerRadius
        backgroundImageView.image = UIImage(named: "user-profile-bonus-header-background")
        backgroundImageView.clipsToBounds = true
        statusBackgroundView.layer.cornerRadius = Constants.statusBackgroundCornerRadius
        statusBackgroundView.clipsToBounds = true
        bonusTitleLabel <~ Style.Label.contrastText
        bonusTitleLabel.text = NSLocalizedString("user_profile_bonus_account", comment: "")
        bonusScoreAmountLabel <~ Style.Label.contrastTitle1
        bonusScorePointsLabel <~ Style.Label.contrastTitle1
        tillNextStatusLabel <~ Style.Label.contrastText
        tillNextStatusAmountLabel <~ Style.Label.contrastHeadline2
        statusLabel <~ Style.Label.contrastText
        
        arrowImageView.image = .Icons.arrow
        arrowImageView.tintColor = .Icons.iconContrast
        
        alfaIconImageView.image = .Icons.alfa
        alfaIconImageView.backgroundColor = .clear
        alfaIconImageView.contentMode = .scaleAspectFit

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageBackgroundTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    private func updateUI() {
        input?.loyaltyModel { loyaltyModel in
            self.bonusScoreAmountLabel.text = self.alfaPointsFormatter.string(from: NSNumber(value: loyaltyModel.amount))
            let scoreFormat = NSLocalizedString("alfa_points_score", comment: "")
            let scoreString = String.localizedStringWithFormat(scoreFormat, Int(loyaltyModel.amount))
            let pointsFormat = NSLocalizedString("user_profile_points_value", comment: "")
            let pointsString = String.localizedStringWithFormat(pointsFormat, scoreString)
            self.bonusScorePointsLabel.text = pointsString
            self.tillNextStatusLabel.isHidden = !loyaltyModel.nextStatusAvailable
            self.tillNextStatusAmountLabel.isHidden = !loyaltyModel.nextStatusAvailable
            self.tillNextStatusLabel.text = String(
                format: NSLocalizedString("user_profile_till_next_status", comment: ""),
                loyaltyModel.nextStatus ?? ""
            )
            self.tillNextStatusAmountLabel.text = AppLocale.price(from: NSNumber(value: loyaltyModel.nextStatusMoney))
            self.statusLabel.text = loyaltyModel.status
        }
    }

    @objc private func imageBackgroundTap(_ sender: Any?) {
        output.onTap()
    }
}
