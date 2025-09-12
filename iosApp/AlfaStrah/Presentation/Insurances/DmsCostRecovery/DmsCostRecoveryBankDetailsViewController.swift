//
//  DmsCostRecoveryDetailsViewController.swift
//  AlfaStrah
//
//  Created by vit on 26.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryBankDetailsViewController: ViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    
    private let bankDetailsView = TitledValueCardView()
    private let doneButton = RoundEdgeButton()
    private let bankDetailsSectionsView = TitledSectionsCardView()
    
    struct Notify {
        let bankSelected: (DmsCostRecoveryBank) -> Void
        let accountNumberEntered: (String) -> Void
        let actionButtonEnabled: (_ enabled: Bool) -> Void
    }
    
    private(set) lazy var notify = Notify(
        bankSelected: { [weak self] selectedBank in
            self?.fillDetails(from: selectedBank)
        },
        accountNumberEntered: { [weak self] accountNumberString in
            self?.accountNumberEntered(accountNumberString)
        },
        actionButtonEnabled: { [weak self] enabled in
            self?.doneButton.isEnabled = enabled
        }
    )
    
    private var items: [SectionsCardView.Item] = []
    
    struct Input {
        let requisites: DmsCostRecoveryFlow.Requisites
    }
    
    var input: Input!
    
    struct Output {
        let doneButtonTap: () -> Void
        let personalAccountInput: () -> Void
        let showBankSearch: () -> Void
    }
    
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.backgroundColor = .Background.backgroundContent
        title = NSLocalizedString("dms_cost_recovery_details_bank_title", comment: "")
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        addCards()
        
        setupDoneButton()
        
        let requisites = input.requisites
        
        if let bank = requisites.bank {
            fillDetails(from: bank)
        }
        
        if let accountNumber = requisites.accountNumber {
            accountNumberEntered(accountNumber)
        }
        
        self.doneButton.isEnabled = requisites.isFilled
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.contentInset.bottom != actionButtonsStackView.bounds.height {
            scrollView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
    
    private func addCards() {
        bankDetailsView.set(
            title: NSLocalizedString("dms_cost_recovery_details_bank_request", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_details_bank_bik_title", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_default_info_empty_state", comment: ""),
            isRequiredField: true
        )
        bankDetailsView.tapHandler = output.showBankSearch
        
        contentStackView.addArrangedSubview(bankDetailsView)
        
        contentStackView.addArrangedSubview(bankDetailsSectionsView)
        bankDetailsSectionsView.isHidden = true
    }
    
    private func setupDoneButton() {
        doneButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        doneButton.setTitle(
            NSLocalizedString("common_done_button", comment: ""),
            for: .normal
        )
        doneButton.addTarget(self, action: #selector(doneButtonTap), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(doneButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
        
        doneButton.isEnabled = false
    }
        
    private func fillDetails(from bank: DmsCostRecoveryBank) {
        bankDetailsView.set(
            title: NSLocalizedString("dms_cost_recovery_details_bank_request", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_details_bank_bik_title", comment: ""),
            value: bank.bik,
            isRequiredField: true
        )
        
        bankDetailsSectionsView.isHidden = false
        
        items.removeAll()
        
        items = [
            .init(
                title: NSLocalizedString("dms_cost_recovery_details_recipient_bank_title", comment: ""),
                placeholder: "",
                value: bank.title,
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
            .init(
                title: NSLocalizedString("dms_cost_recovery_details_recipient_bank_correspondent_account_title", comment: ""),
                placeholder: "",
                value: bank.correspondentAccount,
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
            .init(
                title: "",
                placeholder: NSLocalizedString("dms_cost_recovery_details_recipient_bank_personal_account", comment: ""),
                value: nil,
                icon: .rightArrow,
                isEnabled: true,
                tapHandler: { [weak self] in
                    guard let self = self
                    else { return }
                    
                    self.output.personalAccountInput()
                }
            )
        ]
        
        bankDetailsSectionsView.set(
            title: NSLocalizedString("dms_cost_recovery_details_bank_info", comment: ""),
            items: items,
            isRequiredField: true
        )
        
        doneButton.isEnabled = false
    }
    
    private func accountNumberEntered(_ accountNumber: String) {
        // TODO: update mechanics for single item in SectionsCardView
        items.removeLast()
        items.append(.init(
            title: NSLocalizedString("dms_cost_recovery_details_recipient_bank_personal_account", comment: ""),
            placeholder: "",
            value: accountNumber,
            icon: .rightArrow,
            isEnabled: true,
            tapHandler: { [weak self] in
                guard let self = self
                else { return }
                
                self.output.personalAccountInput()
            }
        ))
        
        bankDetailsSectionsView.updateItems(items)
    }
    
    @objc func doneButtonTap(_ sender: UIButton) {
        output.doneButtonTap()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
