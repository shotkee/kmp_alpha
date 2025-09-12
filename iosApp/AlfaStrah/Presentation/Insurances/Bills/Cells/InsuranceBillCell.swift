//
//  InsuranceBillCell.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class InsuranceBillCell: UITableViewCell {
    static var id: Reusable<InsuranceBillCell> = .fromClass()

    @IBOutlet private var checkboxContainer: UIView!
	@IBOutlet private var checkBoxButton: CommonCheckboxButton!
	
    @IBOutlet private var billNumberLabel: UILabel!
    @IBOutlet private var moneyAmountLabel: UILabel!
    @IBOutlet private var statusView: UIView!
    @IBOutlet private var grayCheckmarkImageView: UIImageView!
    @IBOutlet private var redDotView: UIView!
    @IBOutlet private var paidStatusLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
		checkBoxButton.isUserInteractionEnabled = false // catch touches on cell
		
        billNumberLabel <~ Style.Label.secondaryCaption1
        moneyAmountLabel <~ Style.Label.primaryHeadline3
        dateLabel <~ Style.Label.secondaryCaption1

		grayCheckmarkImageView.image = .Icons.tick.tintedImage(withColor: .Icons.iconSecondary)
    }

    func set(insuranceBill: InsuranceBill, isSelecting: Bool) {
        billNumberLabel.text = formatBillNumber(for: insuranceBill)
        moneyAmountLabel.text = formatPaymentAmount(insuranceBill.moneyAmount)

        let shouldDisplayRedDotInsteadOfCheckmark: Bool
        if insuranceBill.canBePaidInGroup {
            shouldDisplayRedDotInsteadOfCheckmark = true
        } else {
            shouldDisplayRedDotInsteadOfCheckmark = insuranceBill.shouldBePaidOff
        }
        redDotView.isHidden = !shouldDisplayRedDotInsteadOfCheckmark
        grayCheckmarkImageView.isHidden = shouldDisplayRedDotInsteadOfCheckmark

        paidStatusLabel.text = insuranceBill.statusText
		paidStatusLabel.textColor = insuranceBill.shouldBeHighlighted ? .Text.textAccent : .Text.textSecondary

        dateLabel.text = AppLocale.shortDateString(insuranceBill.creationDate)

        setCheckboxSelectionEnabled(isSelecting)

		checkBoxButton.isHidden = !insuranceBill.canBeSelected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

		checkBoxButton.isSelected = selected
    }

    private func setCheckboxSelectionEnabled(_ isSelecting: Bool) {
        checkboxContainer.isHidden = !isSelecting
    }
}
