//
//  OSAGORenewPolicyInfoViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 25.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class OSAGORenewPolicyInfoViewController: ViewController, UITextViewDelegate {
    private lazy var rootScrollView: UIScrollView = .init(frame: .zero)
    private lazy var rootView: UIView = .init(frame: .zero)

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 20

        return stack
    }()

    private lazy var commonUserAgreementView: CommonUserAgreementView = {
        let view: CommonUserAgreementView = .init(frame: .zero)
        return view
    }()
    private lazy var privacyPolicyAgreementView: CommonUserAgreementView = {
        let view: CommonUserAgreementView = .init(frame: .zero)
        return view
    }()

    private lazy var activateButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
		button.setTitle(NSLocalizedString("kasko_renew_button_titile", comment: ""), for: .normal)
        button <~ Style.RoundedButton.redBackground
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendRenewRequest), for: .touchUpInside)

        return button
    }()

    struct Output {
        let renew: (_ userAgreedToPrivacyPolicy: Bool) -> Void
        let linkTap: (URL) -> Void
    }

    struct Input {
        let userInfo: OsagoProlongationCalculateInfo
        let getOsagoProlongationUrls: (@escaping (OsagoProlongationURLs) -> Void) -> Void
        let getPersonalDataUsageTermsUrl: (@escaping (PersonalDataUsageAndPrivacyPolicyURLs) -> Void) -> Void
    }

    var output: Output!
    var input: Input!

    private var urlActivation: URL?
    private var urlInsurance: URL?
    private var personalDataUsageAndPrivacyPolicyURLs: PersonalDataUsageAndPrivacyPolicyURLs?

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        view.addSubview(rootScrollView)
        view.addSubview(activateButton)

        rootScrollView.addSubview(rootView)
        rootView.addSubview(contentStackView)

        rootScrollView.translatesAutoresizingMaskIntoConstraints = false
        rootView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        activateButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rootScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            rootScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rootScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            rootScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootScrollView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            rootView.topAnchor.constraint(equalTo: rootScrollView.topAnchor, constant: 24),
            rootView.bottomAnchor.constraint(equalTo: rootScrollView.bottomAnchor),
            rootView.rightAnchor.constraint(equalTo: rootScrollView.rightAnchor),
            rootView.leadingAnchor.constraint(equalTo: rootScrollView.leadingAnchor),
            rootView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            contentStackView.topAnchor.constraint(equalTo: rootView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            contentStackView.rightAnchor.constraint(equalTo: rootView.rightAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 18),

            activateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
            activateButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            activateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            activateButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupUI() {
        title = NSLocalizedString("insurance_renew_osago_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
		
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0

        createPolicyInfoSection().forEach { stackView.addArrangedSubview($0) }
        stackView.addArrangedSubview(createSectionHeader(with: NSLocalizedString("osago_renew_info_auto_title", comment: "")))
        createCarInfoSection().forEach { stackView.addArrangedSubview($0) }

        contentStackView.addArrangedSubview(CardView(contentView: stackView))
        contentStackView.addArrangedSubview(commonUserAgreementView)
        contentStackView.addArrangedSubview(privacyPolicyAgreementView)

        setupCommonUserAgreementLinks()
        setupPrivacyPolicyAgreementLinks()
    }

    private func setupCommonUserAgreementLinks() {
        let activationLink: LinkArea = .init(
            text: NSLocalizedString("osago_renew_policy_template_link", comment: ""),
            link: nil
        ) { [weak self] _ in
            
            guard let self = self
            else { return }

            if let urlActivation = self.urlActivation {
                self.output.linkTap(urlActivation)
                return
            }

            self.input.getOsagoProlongationUrls { [weak self] data in
                self?.urlActivation = data.urlActivation
                self?.urlInsurance = data.urlInsurance
                self?.output.linkTap(data.urlActivation)
            }
        }

        let insuranceLink: LinkArea = .init(
            text: NSLocalizedString("flat_on_off_agreement_insurance_terms_link", comment: ""),
            link: nil
        ) { [weak self] _ in
            
            guard let self = self
            else { return }

            if let urlInsurance = self.urlInsurance {
                self.output.linkTap(urlInsurance)
                return
            }

            self.input.getOsagoProlongationUrls { [weak self] data in
                self?.urlActivation = data.urlActivation
                self?.urlInsurance = data.urlInsurance
                self?.output.linkTap(data.urlInsurance)
            }
        }

        commonUserAgreementView.set(
            text: NSLocalizedString("osago_renew_agreement_terms_text", comment: ""),
            links: [ activationLink, insuranceLink ],
            handler: .init(
                userAgreementChanged: { [weak self] _ in
                    self?.validateFields()
                }
            )
        )
    }

    private func setupPrivacyPolicyAgreementLinks() {
        let activationLink: LinkArea = .init(
            text: NSLocalizedString("personal_data_usage_terms_link", comment: ""),
            link: nil
        ) { [weak self] _ in
            
            guard let self = self
            else { return }

            if let personalDataUsageAndPrivacyPolicyURLs = self.personalDataUsageAndPrivacyPolicyURLs {
                self.output.linkTap(personalDataUsageAndPrivacyPolicyURLs.personalDataUsageUrl)
                return
            }

            self.input.getPersonalDataUsageTermsUrl { [weak self] data in
                self?.personalDataUsageAndPrivacyPolicyURLs = data
                self?.output.linkTap(data.personalDataUsageUrl)
            }
        }

        let insuranceLink: LinkArea = .init(
            text: NSLocalizedString("privacy_policy_link", comment: ""),
            link: nil
        ) { [weak self] _ in
            
            guard let self = self
            else { return }

            if let personalDataUsageAndPrivacyPolicyURLs = self.personalDataUsageAndPrivacyPolicyURLs {
                self.output.linkTap(personalDataUsageAndPrivacyPolicyURLs.privacyPolicyUrl)
                return
            }

            self.input.getPersonalDataUsageTermsUrl { [weak self] data in
                self?.personalDataUsageAndPrivacyPolicyURLs = data
                self?.output.linkTap(data.privacyPolicyUrl)
            }
        }

        privacyPolicyAgreementView.set(
            text: NSLocalizedString("personal_data_usage_and_privacy_policy_agreement_checkbox_text", comment: ""),
            links: [ activationLink, insuranceLink ],
            handler: .init(
                userAgreementChanged: { [weak self] _ in
                    self?.validateFields()
                }
            )
        )
    }

    private func validateFields() {
        activateButton.isEnabled
            = commonUserAgreementView.userConfirmedAgreement
            && privacyPolicyAgreementView.userConfirmedAgreement
    }

    private func createSectionHeader(with title: String, height: CGFloat = 36) -> UIView {
        let view = UIView()
		view.backgroundColor = .Background.backgroundSecondary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true

        let label = UILabel()
        label <~ Style.Label.secondaryText
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: label,
                in: view,
                margins: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
            )
        )

        return view
    }

    private func createPolicyInfoSection() -> [UIView] {
        let sumNoteView = createCommonNoteView(
            with: NSLocalizedString("osago_renew_payment_title", comment: ""),
            note: AppLocale.price(from: NSNumber(value: input.userInfo.sum), currencyCode: "RUB"),
            showSeparator: true,
            appearance: .bold
        )

        let dateNoteView = createCommonNoteView(
            with: NSLocalizedString("osago_renew_date_title", comment: ""),
            note: String(
                format: NSLocalizedString("vzr_date_interval_format", comment: ""),
                AppLocale.shortDateString(input.userInfo.startDate),
                AppLocale.shortDateString(input.userInfo.endDate)
            ),
            showSeparator: false
        )

        return [sumNoteView, dateNoteView]
    }

    private func createCarInfoSection() -> [UIView] {
        guard let carMark = input.userInfo.carMark else { return [] }

        let carMarkNoteView = createCommonNoteView(
            with: NSLocalizedString("osago_renew_info_mark_title", comment: ""),
            note: carMark,
            showSeparator: true
        )

        let carInfoNoteView = createCommonNoteView(
            with: (input.userInfo.carRegistrationNumber != nil)
                ? NSLocalizedString("osago_renew_info_auto_number_title", comment: "")
                : NSLocalizedString("osago_renew_info_vin_title", comment: ""),
            note: (input.userInfo.carRegistrationNumber != nil)
                ? input.userInfo.carRegistrationNumber ?? ""
                : input.userInfo.carVin ?? "",
            showSeparator: false
        )

       return [carMarkNoteView, carInfoNoteView]
    }

    private func createCommonNoteView(
        with title: String,
        note: String,
        showSeparator: Bool,
        appearance: CommonNoteLabelView.Appearance = .regular
    ) -> CommonNoteLabelView {
        let infoView: CommonNoteLabelView = .init()

        infoView.set(
            title: title,
            note: note,
            margins: Style.Margins.defaultInsets,
            showSeparator: showSeparator,
            appearance: appearance
        )

        return infoView
    }

    // MARK: - Button Actions

    @objc private func sendRenewRequest() {
        output.renew(
            privacyPolicyAgreementView.userConfirmedAgreement
        )
    }
}
