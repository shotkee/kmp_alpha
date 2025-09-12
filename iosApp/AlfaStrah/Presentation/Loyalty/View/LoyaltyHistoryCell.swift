//
//  LoyaltyHistoryCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 5/26/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class LoyaltyHistoryCell: UITableViewCell {
    private enum Constants {
        static let bottomOffsetDefault: CGFloat = 24
        static let bottomOffsetSmall: CGFloat = 15
    }

    static let id: Reusable<LoyaltyHistoryCell> = .fromNib()
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var contractNumberLabel: UILabel!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var operationCanceledLabel: UILabel!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
		clearStyle()
		
        dateLabel <~ Style.Label.primaryHeadline3
        amountLabel <~ Style.Label.accentHeadline3
        descriptionLabel <~ Style.Label.secondaryText
        contractNumberLabel <~ Style.Label.primaryText
        operationCanceledLabel <~ Style.Label.accentCaption1
        operationCanceledLabel.text = NSLocalizedString("alfa_points_operation_canceled", comment: "")
		separatorView.backgroundColor = .Stroke.divider
    }

    func configure(loyaltyOperation: LoyaltyOperation) {
        dateLabel.text = AppLocale.dateString(loyaltyOperation.date)
        var amountText: String
        switch loyaltyOperation.loyaltyType {
            case .addition?:
                amountText = "+"
            case .spending?:
                amountText = "-"
            case .none:
                amountText = ""
        }
        amountText += "\(AppLocale.formattedNumber(from: NSNumber(value: Int(loyaltyOperation.amount)))) "
        let scoreFormat = NSLocalizedString("alfa_points_score", comment: "")
        amountText += String.localizedStringWithFormat(scoreFormat, Int(loyaltyOperation.amount))
        amountLabel.text = amountText
        descriptionLabel.text = loyaltyOperation.description
        contractNumberLabel.text = loyaltyOperation.contractNumber
        bottomConstraint.constant = loyaltyOperation.contractNumber?.isEmpty == false
            ? Constants.bottomOffsetDefault
            : Constants.bottomOffsetSmall
        let isOperationCanceled = loyaltyOperation.status == .canceled
        operationCanceledLabel.isHidden = !isOperationCanceled
		amountLabel.textColor = isOperationCanceled ? .Text.textSecondary : .Text.textAccent
    }
}
