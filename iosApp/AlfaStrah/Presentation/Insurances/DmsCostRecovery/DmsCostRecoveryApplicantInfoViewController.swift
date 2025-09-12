//
//  DmsCostRecoveryApplicantInfoViewController.swift
//  AlfaStrah
//
//  Created by vit on 29.12.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryApplicantInfoViewController: ViewController, AttachmentServiceDependency {
    var attachmentService: AttachmentService!
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    private let nextButton = RoundEdgeButton()
    
    private let bankDetailsView = TitledValueCardView()
    private let personalInfoView = TitledValueCardView()
    private let passportView = TitledValueCardView()
    private let additionalInfoView = TitledValueCardView()
    
    struct Input {
        let personalInfoFilled: Bool
        let passportFilled: Bool
        let requisitesFilled: Bool
        let additionalInfoFilled: Bool
        let stepDataFilled: Bool
    }
    
    var input: Input!
    
    struct Output {
        let nextButtonTap: () -> Void
        let personalInfo: () -> Void
        let bankDetails: () -> Void
        let passportDataTap: () -> Void
        let additionalInfoTap: () -> Void
    }
    
    var output: Output!
        
    struct Notify {
        let requisitesFilled: (_ filled: Bool) -> Void
        let personalInfoFilled: (_ filled: Bool) -> Void
        let isPassportFilledUpdated: (_ filled: Bool) -> Void
        let isAdditionalInfoFilledUpdated: (_ filled: Bool) -> Void
        let stepDataFilled: (_ filled: Bool) -> Void
    }
    
    private(set) lazy var notify = Notify(
        requisitesFilled: { [weak self] filled in
            self?.setRequisitesState(filled: filled)
        },
        personalInfoFilled: { [weak self] filled in
            self?.setPersonalInfoState(filled: filled)
        },
        isPassportFilledUpdated: { [weak self] filled in
            self?.setPassportState(filled: filled)
        },
        isAdditionalInfoFilledUpdated: { [weak self] filled in
            self?.setAdditionalInfoState(filled: filled)
        },
        stepDataFilled: { [weak self] filled in
            self?.nextButton.isEnabled = filled
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.backgroundColor = .Background.backgroundContent
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    
        addCards()
        addNextButton()
        
        setPersonalInfoState(filled: input.personalInfoFilled)
        setPassportState(filled: input.passportFilled)
        setRequisitesState(filled: input.requisitesFilled)
        setAdditionalInfoState(filled: input.additionalInfoFilled)
        nextButton.isEnabled = input.stepDataFilled
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.contentInset.bottom != actionButtonsStackView.bounds.height {
            scrollView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
    
    private func addCards() {
        personalInfoView.set(
            title: NSLocalizedString("dms_cost_recovery_personal_info_fullname_request", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_personal_info_fullname", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_default_info_empty_state", comment: ""),
            value: nil,
            isRequiredField: true
        )
        personalInfoView.tapHandler = output.personalInfo
        
        contentStackView.addArrangedSubview(personalInfoView)
        
        passportView.set(
            title: NSLocalizedString("dms_cost_recovery_passport_info_request_title", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_passport_info", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_default_info_empty_state", comment: ""),
            isRequiredField: true
        )
        passportView.tapHandler = output.passportDataTap
        
        contentStackView.addArrangedSubview(passportView)
        
        bankDetailsView.set(
            title: NSLocalizedString("dms_cost_recovery_applicant_bank_details_request", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_applicant_bank_details_for_recovery", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_default_info_empty_state", comment: ""),
            isRequiredField: true
        )
        bankDetailsView.tapHandler = output.bankDetails
        contentStackView.addArrangedSubview(bankDetailsView)
        
        additionalInfoView.set(
            title: NSLocalizedString("dms_cost_recovery_applicant_additional_info_request", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_applicant_additional_info_title", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_default_info_empty_state", comment: ""),
            isRequiredField: false
        )
        additionalInfoView.tapHandler = output.additionalInfoTap
        
        contentStackView.addArrangedSubview(additionalInfoView)
    }
    
    private func setPersonalInfoState(filled: Bool) {
        personalInfoView.updateValue(
            filled
                ? NSLocalizedString("dms_cost_recovery_default_info_filled_state", comment: "")
                : nil
        )
    }
    
    private func setPassportState(filled: Bool) {
        passportView.updateValue(
            filled
                ? NSLocalizedString("dms_cost_recovery_default_info_filled_state", comment: "")
                : nil
        )
    }
    
    private func setRequisitesState(filled: Bool) {
        bankDetailsView.updateValue(
            filled
                ? NSLocalizedString("dms_cost_recovery_default_info_filled_state", comment: "")
                : nil
        )
    }
    
    private func setAdditionalInfoState(filled: Bool) {
        additionalInfoView.updateValue(
            filled
                ? NSLocalizedString("dms_cost_recovery_default_info_filled_state", comment: "")
                : nil
        )
    }
    
    private func addNextButton() {
        nextButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        nextButton.setTitle(
            NSLocalizedString("common_next", comment: ""),
            for: .normal
        )
        nextButton.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(nextButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
    }
    
    @objc func nextButtonTap(_ sender: UIButton) {
        output.nextButtonTap()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
