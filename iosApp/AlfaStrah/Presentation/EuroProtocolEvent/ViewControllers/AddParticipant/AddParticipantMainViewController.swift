//
//  AddParticipantMainViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 12.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class AddParticipantMainViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let participantBInviteModel: ParticipantBInviteModel
        let shouldShowLaterButton: Bool
    }

    struct Output {
        let cacheInputData: (ParticipantBInviteModel) -> Void
        let generateCode: (EuroProtocolParticipantInviteInfo, @escaping (Result<UIImage, EuroProtocolServiceError>) -> Void) -> Void
        let later: () -> Void
    }

    var input: Input!
    var output: Output!

    enum SectionType: CaseIterable {
        case type
        case info

        var title: String {
            switch self {
                case .type:
                    return NSLocalizedString("insurance_euro_protocol_add_participant_type_section_title", comment: "")
                case .info:
                    return NSLocalizedString("insurance_euro_protocol_add_participant_info_section_title", comment: "")
            }
        }

        var detail: String {
            switch self {
                case .type:
                    return ""
                case .info:
                    return NSLocalizedString("insurance_euro_protocol_add_participant_info_section_info", comment: "")
            }
        }

        enum TypeSectionCard: CaseIterable {
            case type

            var title: String {
                switch self {
                    case .type:
                        return NSLocalizedString("insurance_euro_protocol_add_participant_type_card_title", comment: "")
                }
            }

            var value: String {
                switch self {
                    case .type:
                        return NSLocalizedString("insurance_euro_protocol_add_participant_type_card_text", comment: "")
                }
            }
        }

        enum InfoSectionCard: CaseIterable {
            case name
            case date

            var title: String {
                switch self {
                    case .name:
                        return NSLocalizedString("insurance_euro_protocol_add_participant_info_card_name_title", comment: "")
                    case .date:
                        return NSLocalizedString("insurance_euro_protocol_add_participant_info_card_date_title", comment: "")
                }
            }
        }
    }

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 24

        return stack
    }()

    private lazy var buttonStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 9

        return stack
    }()

    private lazy var nextButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_add_participant_code_button_title", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var laterButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(laterButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_add_participant_later_button_title", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldOutlinedButtonSmall

        return button
    }()

    private var firstName: String?
    private var lastName: String?
    private var middleName: String?
    private var date: Date?

    private var allFieldsFilled: Bool {
        firstName != nil && lastName != nil && date != nil
    }

    var cardNameValue: String? {
        if firstName != nil || lastName != nil || middleName != nil {
            return [ lastName ?? "", firstName ?? "", middleName ?? "" ].joined(separator: " ")
        } else {
            return nil
        }
    }

    var cardDateValue: String? {
        if let date = date {
            return AppLocale.dateString(date)
        } else {
            return nil
        }
    }

    override func setupUI() {
        super.setupUI()

        addBottomButtonsContent(buttonStackView)
        scrollContentView.addSubview(contentStackView)

        if input.shouldShowLaterButton {
            buttonStackView.addArrangedSubview(laterButton)
        }
        buttonStackView.addArrangedSubview(nextButton)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),

            nextButton.heightAnchor.constraint(equalToConstant: 48),
            laterButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        firstName = input.participantBInviteModel.firstName
        lastName = input.participantBInviteModel.lastName
        middleName = input.participantBInviteModel.middleName
        date = input.participantBInviteModel.birthDate

        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_add_participant_title", comment: "")

        SectionType.allCases.forEach { contentStackView.addArrangedSubview(createSetion($0)) }
        nextButton.isEnabled = allFieldsFilled
    }

    private func updateUI() {
        nextButton.isEnabled = allFieldsFilled
    }

    private func createSetion(_ type: SectionType) -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = type.title
        titleLabel <~ Style.Label.primaryHeadline1

        let infoLabel = UILabel(frame: .zero)
        infoLabel.text = type.detail
        infoLabel.numberOfLines = 0
        infoLabel <~ Style.Label.secondaryText

        let stack: UIStackView = .init(arrangedSubviews: [ titleLabel, infoLabel ])
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 15

        switch type {
            case .type:
                createTypeCardViews().forEach { stack.addArrangedSubview($0) }
            case .info:
                createInfoCardViews().forEach { stack.addArrangedSubview($0) }
        }

        return stack
    }

    private func createTypeCardViews() -> [CardView] {
        SectionType.TypeSectionCard.allCases.map { element in
            let value = SmallValueCardView()
            value.set(
                title: element.title,
                placeholder: element.title,
                value: element.value,
                error: nil,
                icon: .center(nil),
                isEnabled: false
            )
            return CardView(contentView: value)
        }
    }

    private func createInfoCardViews() -> [CardView] {
        var views: [UIView] = []
        let nameCard = createCardView(
            SectionType.InfoSectionCard.name.title,
            value: cardNameValue) { valueCardView in
                self.openNameInputBottomViewController(
                    with: valueCardView,
                    firstName: self.firstName,
                    lastName: self.lastName,
                    middleName: self.middleName
                )
        }

        let birthdayCard = createCardView(
            SectionType.InfoSectionCard.date.title,
            value: cardDateValue
        ) { valueCardView in
                self.openDateInputBottomViewController(with: valueCardView, date: self.date)
        }

        views.append(nameCard)
        views.append(birthdayCard)

        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 0

        views.forEach { stack.addArrangedSubview($0) }

        return [ CardView(contentView: stack) ]

    }

    private func createCardView(
        _ title: String,
        value: String?,
        image: SmallValueCardView.IconPositionStyle = .rightArrow,
        tapHandler: ((SmallValueCardView) -> Void)?
    ) -> UIView {
        let valueCard = SmallValueCardView()
        valueCard.set(
            title: title,
            placeholder: title,
            value: value,
            error: nil,
            icon: image,
            showSeparator: true
        )

        valueCard.tapHandler = {
            tapHandler?(valueCard)
        }

        return valueCard
    }

    private func openDateInputBottomViewController(with infoView: SmallValueCardView, date: Date?) {
        let controller: DateInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: SectionType.InfoSectionCard.date.title,
            mode: .date,
            date: date ?? Date(),
            maximumDate: Date(),
            minimumDate: nil
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },

            selectDate: { [unowned self] date in
                self.date = date
                infoView.update(value: cardDateValue)
                self.updateUI()
                self.cacheData()
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func openNameInputBottomViewController(
        with infoView: SmallValueCardView,
        firstName: String?,
        lastName: String?,
        middleName: String?
    ) {
        let controller: InputBottomViewController = .init()
        container?.resolve(controller)

        let lastNameInput = InputBottomViewController.InputObject(
            text: lastName,
            placeholder: NSLocalizedString("user_profile_last_name", comment: ""),
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRule: [ RequiredValidationRule() ]
        )

        let firstNameInput = InputBottomViewController.InputObject(
            text: firstName,
            placeholder: NSLocalizedString("user_profile_first_name", comment: ""),
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRule: [ RequiredValidationRule() ]
        )

        let middleNameInput = InputBottomViewController.InputObject(
            text: middleName,
            placeholder: NSLocalizedString("insurance_euro_protocol_add_participant_patronymic", comment: ""),
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRule: []
        )

        controller.input = .init(
            title: SectionType.InfoSectionCard.name.title,
            infoText: nil,
            inputs: [ lastNameInput, firstNameInput, middleNameInput ]
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] result in
                self.firstName = result[firstNameInput.id]
                self.lastName = result[lastNameInput.id]
                self.middleName = result[middleNameInput.id]
                infoView.update(value: cardNameValue)
                self.updateUI()
                self.cacheData()
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    @objc private func nextButtonAction() {
        guard let firstName = firstName, let lastName = lastName, let date = date else { return }

        cacheData()
        output.generateCode(
            EuroProtocolParticipantInviteInfo(
                firstName: firstName,
                lastName: lastName,
                middleName: middleName,
                birthday: date
            )
        ) { [weak self] result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.handleError(error)
            }
        }
    }

    @objc private func laterButtonAction() {
        cacheData()
        output.later()
    }

    private func cacheData() {
        output.cacheInputData(
            ParticipantBInviteModel(firstName: firstName, lastName: lastName, middleName: middleName, birthDate: date)
        )
    }

    // MARK: - Handle Error

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        processError(error)

        return true
    }
}
