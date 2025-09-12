//
//  VzrOnOffFinalTermsViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/29/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffFinalTermsViewController: ViewController, UITextViewDelegate {
    struct Input {
        let insuredPersonName: (@escaping (Result<String, AlfastrahError>) -> Void) -> Void
        let programTerms: (@escaping (Result<VzrOnOffProgramTerms, AlfastrahError>) -> Void) -> Void
        let tripDaysCount: Int
        let startDate: Date
        let endDate: Date
    }

    struct Output {
        let activate: () -> Void
    }

    @IBOutlet private var daysInfoLabel: UILabel!
    @IBOutlet private var insurerNameLabel: UILabel!
    @IBOutlet private var dateIntervalInfoLabel: UILabel!
    @IBOutlet private var dateIntervalLabel: UILabel!
    @IBOutlet private var checkboxButton: UIButton!
    @IBOutlet private var agreementTermsTextView: UITextView!
    @IBOutlet private var activateButton: UIButton!

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("vzr_final_terms_screen_title", comment: "")
        daysInfoLabel <~ Style.Label.primaryText
        daysInfoLabel.text = String(
            format: NSLocalizedString("vzr_final_terms_activate_format", comment: ""),
            AppLocale.days(from: input.tripDaysCount) ?? ""
        )
        insurerNameLabel <~ Style.Label.primaryHeadline1
        dateIntervalInfoLabel <~ Style.Label.secondaryCaption1
        dateIntervalInfoLabel.text = NSLocalizedString("vzr_final_terms_date_title", comment: "")
        dateIntervalLabel <~ Style.Label.primaryHeadline1
        dateIntervalLabel.text = String(
            format: NSLocalizedString("vzr_date_interval_format", comment: ""),
            AppLocale.shortDateString(input.startDate),
            AppLocale.shortDateString(input.endDate)
        )
        checkboxButton.setImage(UIImage(named: "ico-unchecked-checkbox"), for: .normal)
        checkboxButton.setImage(UIImage(named: "ico-checked-checkbox"), for: .selected)
        checkboxButton.isSelected = false
        let termsString = (NSLocalizedString("vzr_final_terms_terms_text", comment: "") <~ Style.TextAttributes.grayInfoText).mutable
        agreementTermsTextView.attributedText = termsString
        agreementTermsTextView.delegate = self
        activateButton <~ Style.Button.ActionRedRounded(title: NSLocalizedString("common_activate", comment: ""))
        activateButton.isEnabled = checkboxButton.isSelected
        addZeroView()
        refresh()
    }

    private func refresh() {
        showZeroView()
        zeroView?.update(viewModel: .init(kind: .loading))
        let dispatchGroup = DispatchGroup()
        var userName: String?
        var lastProgramInfo: VzrOnOffProgramTerms?
        var lastError: AlfastrahError?

        dispatchGroup.enter()
        input.insuredPersonName { result in
            dispatchGroup.leave()
            switch result {
                case .success(let name):
                    userName = name
                case .failure(let error):
                    lastError = error
            }
        }
        dispatchGroup.enter()
        input.programTerms { result in
            dispatchGroup.leave()
            switch result {
                case .success(let programInfo):
                    lastProgramInfo = programInfo
                case .failure(let error):
                    lastError = error
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            if let name = userName, let programInfo = lastProgramInfo, lastError == nil {
                self.hideZeroView()

                self.insurerNameLabel.text = name
                let agreementAttributedString = self.agreementTermsTextView.attributedText.mutable
                let rangeOfContractLink = NSString(
                    string: agreementAttributedString.string
                    ).range(of: NSLocalizedString("vzr_final_terms_contract_link_text", comment: ""))
                agreementAttributedString.addAttributes(
                    [ .link: programInfo.contractTermsUrlString ],
                    range: rangeOfContractLink
                )
                let rangeOfInsuranceLink = NSString(
                    string: agreementAttributedString.string
                ).range(of: NSLocalizedString("vzr_final_terms_terms_insurance_link_text", comment: ""))
                agreementAttributedString.addAttributes(
                    [ .link: programInfo.insuranceTermsUrlString ],
                    range: rangeOfInsuranceLink
                )
                self.agreementTermsTextView.attributedText = agreementAttributedString
            } else if let error = lastError {
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.refresh() }))
                )
                self.zeroView?.update(viewModel: zeroViewModel)
            } else {
                let zeroViewModel = ZeroViewModel(
                    kind: .custom(
                        title: NSLocalizedString("common_error_unknown_error", comment: ""),
                        message: nil,
                        iconKind: .search
                    ),
                    buttons: [
                        .init(
                            title: NSLocalizedString("common_retry", comment: ""),
                            isPrimary: true,
                            action: { [weak self] in self?.refresh() }
                        )
                    ]
                )
                self.zeroView?.update(viewModel: zeroViewModel)
            }
        }
    }

    @IBAction private func checkButtonTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        activateButton.isEnabled = checkboxButton.isSelected
    }

    @IBAction private func purchaseTap(_ sender: UIButton) {
        output.activate()
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
