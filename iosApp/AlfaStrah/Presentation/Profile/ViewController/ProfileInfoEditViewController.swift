//
//  ProfileInfoEditViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/11/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ProfileInfoEditViewController: ViewController {
    struct AccountData {
        let firstName: String
        let lastName: String
        let patronymic: String?
        let phone: Phone?
        let birthDate: Date
        let email: String?
    }
    
    struct Input {
        let accountData: () -> AccountData
        let agreementLinks: PersonalDataUsageAndPrivacyPolicyURLs?
    }

    struct Output {
        let save: () -> Void
        let showDocument: (URL) -> Void
        let updateAgreementState: (Bool) -> Void
        let toChat: () -> Void
        let emailEntered: (String) -> Void
        let phoneEntered: (Phone) -> Void
    }

    struct Notify {
        let updateSections: (_ accountData: AccountData) -> Void
        let isSaveButtonEnabled: (_ enabled: Bool) -> Void
        let resetAgreementState: () -> Void
    }

    var input: Input!
    var output: Output!

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateSections: { [weak self] accountData in
            guard let self = self
            else { return }
            
            self.topSectionsCardView.updateItems(self.topSectionItems(accountData))
            self.bottomSectionsCardView.updateItems(self.bottomSectionItems(accountData))
        },
        isSaveButtonEnabled: { [weak self] enabled in
            self?.saveButton.isEnabled = enabled
        },
        resetAgreementState: { [weak self] in
            self?.agreementView.resetConfirmation()
        }
    )

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let actionButtonsStackView = UIStackView()
    private let topSectionsCardView = SectionsCardView()
    private let bottomSectionsCardView = SectionsCardView()
    private let saveButton = RoundEdgeButton()
    private let infoView = ProfileWarningInfoView()
    private let agreementView = CommonUserAgreementView()

    private let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("user_profile_change_info_navigation_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
        
        setupScrollView()
        
        setupContentStackView()
        setupTopSectionsCardView()
        setupInfoView()
        setupBottomSectionsCardView()
        
        setupActionButtonStackView()
        setupSaveButton()
        
        topSectionsCardView.updateItems(topSectionItems(input.accountData()))
        bottomSectionsCardView.updateItems(bottomSectionItems(input.accountData()))
        
        setupAgreementView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        agreementView.resetConfirmation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let inset = actionButtonsStackView.bounds.height + agreementView.bounds.height
        
        if scrollView.contentInset.bottom != inset {
            scrollView.contentInset.bottom = inset
        }
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: view))
    }

    private func setupContentStackView() {
        scrollView.addSubview(contentStackView)
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 18
        contentStackView.backgroundColor = .clear
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: contentStackView, in: scrollView) +
            [ contentStackView.widthAnchor.constraint(equalTo: view.widthAnchor)]
        )
    }
    
    private func setupActionButtonStackView() {
        view.addSubview(actionButtonsStackView)
        
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = 0
        actionButtonsStackView.backgroundColor = .clear
        
        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSaveButton() {
        saveButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        saveButton.setTitle(
            NSLocalizedString("common_save", comment: ""),
            for: .normal
        )
        saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(saveButton)
        
        saveButton.isEnabled = false
    }
    
    private func setupTopSectionsCardView() {
        contentStackView.addArrangedSubview(spacer(24))
        contentStackView.addArrangedSubview(topSectionsCardView)
    }
    
    private func setupInfoView() {
        infoView.set(tapHandler: output.toChat)
        contentStackView.addArrangedSubview(infoView)
    }
    
    private func setupBottomSectionsCardView() {
        contentStackView.addArrangedSubview(bottomSectionsCardView)
    }
    
    private func setupAgreementView() {
        let links: [LinkArea] = [
            .init(
                text: NSLocalizedString("personal_data_usage_terms_link", comment: ""),
                link: input.agreementLinks?.personalDataUsageUrl,
                tapHandler: { [weak self] url in
                    guard let url = url
                    else { return }
                    
                    self?.output.showDocument(url)
                }
            ),
            .init(
                text: NSLocalizedString("privacy_policy_link", comment: ""),
                link: input.agreementLinks?.privacyPolicyUrl,
                tapHandler: { [weak self] url in
                    guard let url = url
                    else { return }
                    
                    self?.output.showDocument(url)
                }
            )
        ]
        
        agreementView.set(
            text: NSLocalizedString("personal_data_usage_and_privacy_policy_agreement_checkbox_text", comment: ""),
            userInteractionWithTextEnabled: true,
            links: links,
            handler: .init(
                userAgreementChanged: { [weak self] checked in
                    self?.output.updateAgreementState(checked)
                }
            )
        )
        
        scrollView.addSubview(agreementView)
        
        agreementView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            agreementView.topAnchor.constraint(
                greaterThanOrEqualTo: contentStackView.bottomAnchor,
                constant: 24
            ),
            agreementView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            agreementView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            agreementView.bottomAnchor.constraint(
                equalTo: actionButtonsStackView.topAnchor,
                constant: 16
            ).with(priority: .defaultLow)
        ])
    }
    
    @objc func saveButtonTap(_ sender: UIButton) {
        output.save()
    }
    
    private func topSectionItems(_ accountData: AccountData) -> [SectionsCardView.Item] {
        return [
            .init(
                title: NSLocalizedString("user_profile_phone_number_title", comment: ""),
                placeholder: NSLocalizedString("user_profile_phone_number_title", comment: ""),
                value: accountData.phone?.humanReadable ?? "",
                icon: .rightArrow,
                isEnabled: true,
                tapHandler: { [weak self] in
                    guard let self = self
                    else { return }
                    
                    self.openPhoneInputBottomViewController(
                        from: self,
                        initialPhoneText: accountData.phone?.humanReadable ?? ""
                    ) { phone in
                        self.output.phoneEntered(phone)
                    }
                }
            ),
            .init(
                title: NSLocalizedString("user_profile_email", comment: ""),
                placeholder: NSLocalizedString("user_profile_email", comment: ""),
                value: accountData.email,
                icon: .rightArrow,
                isEnabled: true,
                tapHandler: { [weak self] in
                    guard let self = self
                    else { return }
                
                    self.openEmailInputBottomViewController(
                        from: self,
                        initialEmailText: accountData.email ?? ""
                    ) { email in
                        self.output.emailEntered(email)
                    }
                }
            )
        ]
    }
    
    private func bottomSectionItems(_ accountData: AccountData) -> [SectionsCardView.Item] {
        return [
            .init(
                title: NSLocalizedString("user_profile_first_name", comment: ""),
                placeholder: NSLocalizedString("user_profile_first_name", comment: ""),
                value: accountData.firstName,
                icon: .empty,
                isEnabled: false,
                tapHandler: nil
            ),
            .init(
                title: NSLocalizedString("user_profile_last_name", comment: ""),
                placeholder: NSLocalizedString("user_profile_last_name", comment: ""),
                value: accountData.lastName,
                icon: .empty,
                isEnabled: false,
                tapHandler: nil
            ),
            .init(
                title: NSLocalizedString("user_profile_patronymic", comment: ""),
                placeholder: NSLocalizedString("user_profile_patronymic", comment: ""),
                value: accountData.patronymic ?? "",
                icon: .empty,
                isEnabled: false,
                tapHandler: nil
            ),
            .init(
                title: NSLocalizedString("user_profile_date_of_birth", comment: ""),
                placeholder: NSLocalizedString("user_profile_date_of_birth", comment: ""),
                value: birthDateFormatter.string(from: accountData.birthDate),
                icon: .empty,
                isEnabled: false,
                tapHandler: nil
            )
        ]
    }
    
    private func openPhoneInputBottomViewController(
        from: UIViewController,
        initialPhoneText: String,
        completion: @escaping (Phone) -> Void
    ) {
        let controller = PhoneInputBottomViewController()

        controller.input = .init(
            title: NSLocalizedString("disagreement_with_services_phone_number", comment: ""),
            placeholder: NSLocalizedString("disagreement_with_services_phone_number_prompt", comment: ""),
            initialPhoneText: initialPhoneText
        )
        controller.output = .init(completion: { [weak from] plain, humanReadable in
            let phone = Phone(plain: plain, humanReadable: humanReadable)
            completion(phone)
            from?.dismiss(animated: true, completion: nil)
        })

        from.showBottomSheet(contentViewController: controller)
    }
    
    private func openEmailInputBottomViewController(
        from: UIViewController,
        initialEmailText: String,
        completion: @escaping (String) -> Void
    ) {
        let controller = EmailInputBottomViewController()
        
        controller.input = .init(
            title: NSLocalizedString("dms_cost_recovery_email_input_title", comment: ""),
            placeholder: "",
            initialEmailText: initialEmailText
        )
        
        controller.output = .init(
            completion: { [weak from] email in
                completion(email)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
