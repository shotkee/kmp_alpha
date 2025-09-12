//
//  FlatOnOffAgreementViewController.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 14.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class FlatOnOffAgreementViewController: ViewController, UITextViewDelegate {
    struct Input {
        let package: FlatOnOffPurchaseItem
    }

    struct Output {
        let purchasePackage: () -> Void
    }

    @IBOutlet private var topInfoLabel: UILabel!
    @IBOutlet private var packageTitleLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var checkboxButton: UIButton!
    @IBOutlet private var agreementTermsTextView: UITextView!
    @IBOutlet private var buyButton: UIButton!

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("vzr_buy_day_packages_title", comment: "")
        topInfoLabel <~ Style.Label.primaryCaption1
        topInfoLabel.text = NSLocalizedString("vzr_agreement_info", comment: "")
        packageTitleLabel <~ Style.Label.secondaryText
        packageTitleLabel.text = input.package.title
        priceLabel <~ Style.Label.primaryHeadline3
        priceLabel.text = AppLocale.price(from: NSNumber(value: input.package.price), currencyCode: "RUB")
        checkboxButton.setImage(UIImage(named: "ico-unchecked-checkbox"), for: .normal)
        checkboxButton.setImage(UIImage(named: "ico-checked-checkbox"), for: .selected)
        checkboxButton.isSelected = false
        let termsString = (NSLocalizedString("flat_on_off_agreement_terms_text", comment: "") <~ Style.TextAttributes.grayInfoText).mutable
        let rangeOfTermsLink = NSString(string: termsString.string)
            .range(of: NSLocalizedString("flat_on_off_terms_agreement_link", comment: ""))
        termsString.addAttributes(
            [ .link: input.package.contractUrl ],
            range: rangeOfTermsLink
        )
        let rangeOfInsuranceLink = NSString(string: termsString.string)
            .range(of: NSLocalizedString("flat_on_off_agreement_insurance_terms_link", comment: ""))
        termsString.addAttributes(
            [ .link: input.package.insuranceUrl ],
            range: rangeOfInsuranceLink
        )
        agreementTermsTextView.attributedText = termsString
        agreementTermsTextView.delegate = self
        buyButton <~ Style.Button.ActionRedRounded(title: NSLocalizedString("common_purchase", comment: ""))
        buyButton.isEnabled = checkboxButton.isSelected
    }

    @IBAction private func checkButtonTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        buyButton.isEnabled = checkboxButton.isSelected
    }

    @IBAction private func purchaseTap(_ sender: UIButton) {
        output.purchasePackage()
    }

    // MARK: - UITextViewDelegate

    func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        SafariViewController.open(url, from: self)
        return false
    }
}
