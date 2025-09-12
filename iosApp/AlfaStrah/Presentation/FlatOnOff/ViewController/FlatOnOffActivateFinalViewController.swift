//
//  FlatOnOffActivateFinalViewController.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 17.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class FlatOnOffActivateFinalViewController: ViewController, UITextViewDelegate {
    @IBOutlet private var addressTitleLabel: UILabel!
    @IBOutlet private var addressValueLabel: UILabel!
    @IBOutlet private var periodTitleLabel: UILabel!
    @IBOutlet private var periodValueLabel: UILabel!
    @IBOutlet private var checkboxButton: UIButton!
    @IBOutlet private var agreementTermsTextView: UITextView!
    @IBOutlet private var activateButton: UIButton!

    struct Input {
        let insurance: Insurance
        let calculation: FlatOnOffProtectionCalculation
    }

    struct Output {
        let activate: (_ completion: @escaping (Result<Void, AlfastrahError>) -> Void) -> Void
    }

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        title = input.insurance.title

        addressTitleLabel <~ Style.Label.secondaryText
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("insurance_expiration_days", comment: ""), input.calculation.days
        )
        let daysFormat = NSLocalizedString("flat_on_off_activate_activation_title", comment: "")
        addressTitleLabel.text = String.localizedStringWithFormat(daysFormat, daysString)

        addressValueLabel <~ Style.Label.primaryHeadline3
        addressValueLabel.text = input.insurance.description

        periodTitleLabel <~ Style.Label.secondaryText
        periodTitleLabel.text = NSLocalizedString("flat_on_off_activate_period_title", comment: "")

        periodValueLabel <~ Style.Label.primaryHeadline3
        let periodFormat = NSLocalizedString("flat_on_off_active_period", comment: "")
        periodValueLabel.text = String.localizedStringWithFormat(
            periodFormat,
            AppLocale.shortDateString(input.calculation.startDate),
            AppLocale.shortDateString(input.calculation.endDate)
        )

        checkboxButton.setImage(UIImage(named: "ico-unchecked-checkbox"), for: .normal)
        checkboxButton.setImage(UIImage(named: "ico-checked-checkbox"), for: .selected)
        checkboxButton.isSelected = false

        let termsString = (NSLocalizedString("flat_on_off_agreement_terms_text", comment: "") <~ Style.TextAttributes.grayInfoText).mutable
        let rangeOfTermsLink = NSString(string: termsString.string)
            .range(of: NSLocalizedString("flat_on_off_terms_agreement_link", comment: ""))
        termsString.addAttributes(
            [ .link: input.calculation.contractURL ],
            range: rangeOfTermsLink
        )
        let rangeOfInsuranceLink = NSString(string: termsString.string)
            .range(of: NSLocalizedString("flat_on_off_agreement_insurance_terms_link", comment: ""))
        termsString.addAttributes(
            [ .link: input.calculation.insuranceURL ],
            range: rangeOfInsuranceLink
        )
        agreementTermsTextView.attributedText = termsString
        agreementTermsTextView.delegate = self

        activateButton <~ Style.Button.ActionRedRounded(title: NSLocalizedString("common_activate", comment: ""))
        activateButton.isEnabled = checkboxButton.isSelected

        addZeroView()
    }

    @IBAction private func toggleCheckbox() {
        checkboxButton.isSelected.toggle()
        activateButton.isEnabled = checkboxButton.isSelected
    }

    @IBAction private func activate() {
        let hide = showLoadingIndicator(
            message: NSLocalizedString("flat_on_off_activate_loading_message", comment: ""),
            in: parent
        )
        output.activate { result in
            hide(nil)
            guard let error = result.error else { return }

            switch error.businessErrorKind {
                case .startChat:
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .unreachableErrorOnly, action: { [weak self] in self?.activate() })),
                        buttons: OperationStatusView.ButtonConfiguration.mainScreenOtChat
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
                    self.showZeroView()
                default:
                    self.processError(error)
            }
        }
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
