//
//  InsuranceBillPersonalInfoViewController.swift
//  AlfaStrah
//
//  Created by vit on 22.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class InsuranceBillPersonalInfoViewController: ViewController {
    @IBOutlet private var actionButtonsStackView: UIStackView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    
    private let payButton = RoundEdgeButton()
    private let sectionView = SectionsCardView()
    private let noticeLabel = UILabel()
    private let personalInfoSectionsView = SectionsCardView()
    
    struct Input {
        let payButtonEnabled: Bool
        let phone: String
        let email: String
    }
    
    var input: Input!
    
    struct Output {
        let pay: () -> Void
        let emailInput: () -> Void
        let phoneInput: () -> Void
    }
    
    var output: Output!
    
    struct Notify {
        let updateWith: (_ phone: Phone?, _ email: String?) -> Void
        let payButtonEnabled: (_ enabled: Bool) -> Void
    }

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateWith: { [weak self] phone, email in
            self?.fillPersonalInfoSectionWith(email: email, phone: phone?.humanReadable)
        },
        payButtonEnabled: { [weak self] enabled in
            self?.payButton.isEnabled = enabled
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        title = NSLocalizedString("insurance_bill_payment", comment: "")
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        addPayButton()
        addNoticeSection()
        
        contentStackView.addArrangedSubview(sectionView)
        fillPersonalInfoSectionWith(email: input.email, phone: input.phone)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.contentInset.bottom != actionButtonsStackView.bounds.height {
            scrollView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
    
    private func addPayButton() {
        payButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        payButton.setTitle(
            NSLocalizedString("insurance_bill_pay_off", comment: ""),
            for: .normal
        )
        payButton.addTarget(self, action: #selector(payButtonTap), for: .touchUpInside)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            payButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(payButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
        
        payButton.isEnabled = input.payButtonEnabled
    }
    
    private func addNoticeSection() {
        let noticeContainer = UIView()
        noticeLabel <~ Style.Label.secondaryHeadline2
        noticeLabel.numberOfLines = 0
        noticeContainer.addSubview(noticeLabel)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: noticeLabel,
                in: noticeContainer,
                margins: UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
            )
        )
        contentStackView.addArrangedSubview(noticeContainer)
        
        noticeLabel.text = NSLocalizedString("insurance_bill_payment_personal_info_notice", comment: "")
    }
    
    private func fillPersonalInfoSectionWith(email: String?, phone: String?) {
        let items: [SectionsCardView.Item] = [
            .init(
                title: NSLocalizedString("insurance_bill_payment_personal_info_phone_number", comment: ""),
                placeholder: NSLocalizedString("insurance_bill_payment_personal_info_phone_number", comment: ""),
                value: phone,
                icon: .rightArrow,
                isEnabled: true,
                tapHandler: output.phoneInput
            ),
            .init(
                title: NSLocalizedString("insurance_bill_payment_personal_info_email", comment: ""),
                placeholder: NSLocalizedString("insurance_bill_payment_personal_info_email", comment: ""),
                value: email,
                icon: .rightArrow,
                isEnabled: true,
                tapHandler: output.emailInput
            )
        ]
        sectionView.updateItems(items)
    }

    @objc func payButtonTap(_ sender: UIButton) {
        output.pay()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
