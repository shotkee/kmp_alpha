//
//  InsuranceBillViewController.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 13.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import UIKit

class InsuranceBillViewController: ViewController {
    struct Input {
        var insuranceBill: InsuranceBill
    }
    struct Output {
        let payOffInsuranceBill: () -> Void
        let submitDisagreement: () -> Void
        let updateBillInfo: () -> Void
    }

    var input: Input!
    var output: Output!
    
    struct Notify {
        let insuranceBillUpdated: (InsuranceBill) -> Void
    }
    
    private(set) lazy var notify = Notify(
        insuranceBillUpdated: { [weak self] insuranceBill in
            self?.input.insuranceBill = insuranceBill
            
            self?.updateData()
        }
    )
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var statusView: InsuranceBillPropertyView!
    @IBOutlet private var creationDateView: InsuranceBillPropertyView!
    @IBOutlet private var paymentDateView: InsuranceBillPropertyView!
    @IBOutlet private var paymentSumView: InsuranceBillPropertyView!
    @IBOutlet private var recipientView: InsuranceBillPropertyView!
    @IBOutlet private var detailsTitleLabel: UILabel!
    @IBOutlet private var detailsLabel: UILabel!
    @IBOutlet private var detailsCollapsedIndicatorIcon: UIImageView!
    @IBOutlet private var detailsCollapsedHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomButtonsContainer: UIView!
    @IBOutlet private var payOffButton: RoundEdgeButton!
    @IBOutlet private var disagreeButton: RoundEdgeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        output.updateBillInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentInset.bottom = bottomButtonsContainer.bounds.height
    }

    private func updateData() {
        title = formatBillNumber(for: input.insuranceBill)

        headerLabel.text = input.insuranceBill.info
		headerLabel <~ Style.Label.primarySubhead

        statusView.set(
            name: NSLocalizedString("insurance_bill_status", comment: ""),
            value: input.insuranceBill.statusText,
            icon: Self.getStatusIcon(for: input.insuranceBill)
        )
        creationDateView.set(
            name: NSLocalizedString("insurance_bill_creation_date", comment: ""),
            value: AppLocale.dateString(input.insuranceBill.creationDate),
            icon: nil
        )
        if let paymentDate = input.insuranceBill.paymentDate {
            paymentDateView.set(
                name: NSLocalizedString("insurance_bill_payment_date", comment: ""),
                value: AppLocale.dateString(paymentDate),
                icon: nil
            )
        } else {
            paymentDateView.isHidden = true
        }
        paymentSumView.set(
            name: NSLocalizedString("insurance_bill_sum_to_pay_in_roubles", comment: ""),
            value: formatPaymentAmount(input.insuranceBill.moneyAmount),
            icon: nil
        )

        recipientView.set(
            name: NSLocalizedString("insurance_bill_recipient", comment: ""),
            value: input.insuranceBill.recipientName,
            icon: nil
        )
		
		detailsTitleLabel <~ Style.Label.primaryHeadline1
        detailsTitleLabel.text = NSLocalizedString("insurance_bill_details", comment: "")
		
		detailsLabel <~ Style.Label.secondaryCaption1
        detailsLabel.text = input.insuranceBill.description

        payOffButton.setTitle(
            NSLocalizedString("insurance_bill_pay_off", comment: ""),
            for: .normal
        )
        payOffButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        payOffButton.isHidden = !input.insuranceBill.shouldBePaidOff
        
        disagreeButton.setTitle(
            NSLocalizedString("insurance_bill_disagree", comment: ""),
            for: .normal
        )
        disagreeButton <~ Style.RoundedButton.grayBackgroundMedium
        disagreeButton.titleLabel?.numberOfLines = 0
        disagreeButton.titleLabel?.textAlignment = .center

        disagreeButton.isHidden = !input.insuranceBill.canSubmitDisagreement
    }

    private static func getStatusIcon(for insuranceBill: InsuranceBill) -> UIImage? {
        return insuranceBill.shouldBePaidOff
			? .Icons.clock.tintedImage(withColor: .Icons.iconSecondary)
			: .Icons.tick.tintedImage(withColor: .Icons.iconAccent)
    }
	
    private func setBillDetailsCollapsed(_ collapseDetails: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [],
            animations: {
                self.detailsCollapsedHeightConstraint.isActive = collapseDetails
                self.detailsLabel.alpha = collapseDetails ? 0 : 1
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.detailsCollapsedIndicatorIcon.image = collapseDetails
					? UIImage(named: "ico-accessory-down-arrow")?.tintedImage(withColor: .Icons.iconSecondary)
                    : UIImage(named: "ico-accessory-up-arrow")?.tintedImage(withColor: .Icons.iconSecondary)
        })
    }

    @IBAction func expandDetailsButtonTap(_ sender: UIButton) {
        let wasCollapsed = detailsCollapsedHeightConstraint.isActive
        setBillDetailsCollapsed(!wasCollapsed)
    }

    @IBAction func payOffButtonTap(_ sender: UIButton) {
        output.payOffInsuranceBill()
    }
    
    @IBAction func disagreeButtonTap() {
        output.submitDisagreement()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		let detailsCollapsedIndicatorIconImage = detailsCollapsedIndicatorIcon.image
		
		detailsCollapsedIndicatorIcon.image = detailsCollapsedIndicatorIconImage?.tintedImage(withColor: .Icons.iconSecondary)
		
		statusView.set(
			name: NSLocalizedString("insurance_bill_status", comment: ""),
			value: input.insuranceBill.statusText,
			icon: Self.getStatusIcon(for: input.insuranceBill)
		)
	}
}

func formatBillNumber(for insuranceBill: InsuranceBill) -> String {
    String(
        format: NSLocalizedString("insurance_bill_no", comment: ""),
        insuranceBill.number
    )
}

func formatPaymentAmount(_ moneyAmount: Double) -> String {
    moneySumFormatter.string(from: NSNumber(value: moneyAmount)) ?? ""
}

private let moneySumFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = AppLocale.currentLocale
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.alwaysShowsDecimalSeparator = true
    formatter.decimalSeparator = "."
    formatter.groupingSeparator = " "
    return formatter
}()
