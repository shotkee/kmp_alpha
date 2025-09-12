//
//  EuroProtocolCarOwnerViewController.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 29.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length
class EuroProtocolCarOwnerViewController: EuroProtocolBaseViewController {
    struct Input {
        var participant: EuroProtocolParticipant
        var owner: EuroProtocolOwner?
        var accountName: String?
    }

    struct Output {
        var save: (_ owner: EuroProtocolOwner, _ completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
    }

    var input: Input!
    var output: Output!

    enum OwnerCardType {
        case individualName
        case entityName
        case individualAddress
        case entityAddress

        var title: String {
            switch self {
                case .individualName:
                    return NSLocalizedString("accident_person_name_title", comment: "")
                case .entityName:
                    return NSLocalizedString("insurance_euro_protocol_car_owner_company_name", comment: "")
                case .individualAddress:
                    return NSLocalizedString("insurance_euro_protocol_car_owner_address", comment: "")
                case .entityAddress:
                    return NSLocalizedString("insurance_euro_protocol_car_owner_entity_address", comment: "")
            }
        }
    }

    enum OwnerData {
        case driver
        case individual(firstName: String?, lastName: String?, middleName: String?, address: String?)
        case organization(name: String?, address: String?)

        init(owner: EuroProtocolOwner?) {
            guard let owner = owner else {
                self = .emptyIndividual
                return
            }

            switch owner {
                case .driver:
                    self = .driver
                case .individual(let firstName, let lastName, let middleName, let address):
                    self = .individual(
                        firstName: firstName,
                        lastName: lastName,
                        middleName: middleName,
                        address: address
                    )
                case .organization(let name, let address):
                    self = .organization(name: name, address: address)
                case .none:
                    self = .emptyIndividual
            }
        }

        var owner: EuroProtocolOwner? {
            switch self {
                case .driver:
                    return .driver
                case .individual(let firstName, let lastName, let middleName, let address):
                    guard
                        let firstName = firstName,
                        let lastName = lastName,
                        let address = address
                    else { return nil }

                    return .individual(firstName: firstName, lastName: lastName, middleName: middleName, address: address)
                case .organization(let name, let address):
                    guard let name = name, let address = address else { return nil }

                    return .organization(name: name, address: address)
            }
        }

        static var emptyIndividual: OwnerData {
            .individual(firstName: nil, lastName: nil, middleName: nil, address: nil)
        }

        static var emptyOrganization: OwnerData {
            .organization(name: nil, address: nil)
        }
    }

    private lazy var rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.contentMode = .left
        return stack
    }()

    private lazy var segmentControl: RMRStyledSwitch =  {
        let control = RMRStyledSwitch()
        control.style(
            leftTitle: NSLocalizedString("insurance_euro_protocol_car_owner_selector_individual", comment: ""),
            rightTitle: NSLocalizedString("insurance_euro_protocol_car_owner_selector_legalEntity", comment: "")
        )
        control.addTarget(self, action: #selector(segmentControlAction), for: .valueChanged)
        control.contentMode = .scaleToFill
        return control
    }()

    private lazy var ownerLabel: UILabel = {
        let label = UILabel()
        label <~ Style.Label.primaryText
        label.text = NSLocalizedString("insurance_euro_protocol_car_owner_switch_title", comment: "")
        return label
    }()

    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = Style.Color.Palette.red
        switcher.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        return switcher
    }()

    private lazy var separatorView: HairLineView = {
        let value: HairLineView = .init(frame: .zero)
        value.lineColor = Style.Color.Palette.whiteGray
        return value
    }()

    private lazy var switchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private lazy var ownerDataLabel: UILabel = {
        let label = UILabel()
        label <~ Style.Label.primaryHeadline1

        switch input.participant {
            case .participantA:
                label.text = NSLocalizedString("insurance_euro_protocol_car_owner_owner_title_A", comment: "")
            case .participantB:
                label.text = NSLocalizedString("insurance_euro_protocol_car_owner_owner_title_B", comment: "")
        }

        return label
    }()

    private lazy var individualNameCard: SmallValueCardView = {
        let card = createCard(cardType: .individualName)

        card.tapHandler = { [weak self] in self?.openIndividualNameInputBottomController(cardToUpdate: card) }
        return card
    }()

    private lazy var entityNameCard: SmallValueCardView = {
        let card = createCard(cardType: .entityName)
        card.tapHandler = { [unowned self] in
            guard case .organization(let name, let address) = self.ownerData else { return }

            self.openOrganizationNameInputButtomController(
                cardType: .entityName,
                cardView: card
            ) { text in
                self.ownerData = .organization(name: text, address: address)
            }
        }
        return card
    }()

    private lazy var individualAddressCard: SmallValueCardView = {
        let card = createCard(cardType: .individualAddress)
        card.tapHandler = { [unowned self] in
            guard case .individual(let name, let lastName, let middleName, let address) = self.ownerData else {
                return
            }

            self.openAddressInputButtomViewController(
                cardType: .individualAddress,
                cardView: card) { text in
                self.ownerData = .individual(
                    firstName: name,
                    lastName: lastName,
                    middleName: middleName,
                    address: text
                )
            }
        }
        return card
    }()

    private lazy var entityAddressCard: SmallValueCardView = {
        let card = createCard(cardType: .entityAddress)
        card.tapHandler = { [unowned self] in
            guard case .organization(let name, let address) = self.ownerData else { return }

            self.openAddressInputButtomViewController(
                cardType: .entityAddress,
                cardView: card
            ) { text in
                self.ownerData = .organization(name: name, address: text)
            }
        }
        return card
    }()

    private lazy var individualCardsView: CardView = {
        let stack = UIStackView(arrangedSubviews: [individualNameCard, individualAddressCard])
        stack.axis = .vertical
        stack.spacing = 1
        return CardView(contentView: stack)
    }()

    private lazy var entityCardsView: CardView = {
        let stack = UIStackView(arrangedSubviews: [entityNameCard, entityAddressCard])
        stack.axis = .vertical
        stack.spacing = 1
        return CardView(contentView: stack)
    }()

    private lazy var segmentControlStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let button = RoundEdgeButton()
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        button.isEnabled = false
        return button
    }()

    private lazy var ownerDataSpacerView: UIView = {
        let view: UIView = spacer(15)
        return view
    }()

    private var ownerData: OwnerData = .emptyIndividual

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        segmentControl.layer.cornerRadius = segmentControl.frame.height / 2
    }

    private func setupUI() {
        title = NSLocalizedString("insurance_euro_protocol_participant_data_owner_title", comment: "")
        view.backgroundColor = Style.Color.background

        ownerData = OwnerData(owner: input.owner)

        switch ownerData {
            case .individual:
                segmentControl.setSelectedIndex(0, animated: false)
            case .organization:
                segmentControl.setSelectedIndex(1, animated: true)
            default:
                break
        }
        view.addSubview(rootStackView)
        view.addSubview(saveButton)

        rootStackView.addArrangedSubview(switchStackView)
        rootStackView.addArrangedSubview(segmentControlStackView)
        rootStackView.addArrangedSubview(ownerDataSpacerView)
        rootStackView.addArrangedSubview(ownerDataLabel)
        rootStackView.addArrangedSubview(spacer(15))

        rootStackView.addArrangedSubview(individualCardsView)
        rootStackView.addArrangedSubview(entityCardsView)

        switchStackView.addArrangedSubview(horizontalStackView)
        switchStackView.addArrangedSubview(separatorView)

        horizontalStackView.addArrangedSubview(ownerLabel)
        horizontalStackView.addArrangedSubview(switcher)

        segmentControlStackView.addArrangedSubview(spacer(24))
        segmentControlStackView.addArrangedSubview(segmentControl)
        segmentControlStackView.addArrangedSubview(spacer(24))

        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                rootStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
                rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
                rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                       constant: 18),
                rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: -18),

                horizontalStackView.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
                horizontalStackView.topAnchor.constraint(equalTo: rootStackView.topAnchor),
                horizontalStackView.heightAnchor.constraint(equalToConstant: 54),

                segmentControl.heightAnchor.constraint(equalToConstant: 42),
                segmentControl.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1),

                saveButton.heightAnchor.constraint(equalToConstant: 48),
                saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
                saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
                saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18)
            ]
        )

        updateUI()
    }

    private func updateUI() {
        switch ownerData {
            case .individual(let firstName, let lastName, let middleName, let address):
                let fullName = [ firstName, lastName, middleName ]
                    .compactMap { $0 }
                    .joined(separator: " ")
                individualNameCard.update(value: fullName)
                individualAddressCard.update(value: address)
            case .organization(let name, let address):
                entityNameCard.update(value: name)
                entityAddressCard.update(value: address)
            case .driver:
                switcher.isOn = true
                individualNameCard.update(value: input.accountName)
        }
        configureScreenState()
        saveButton.isEnabled = shouldEnableSaveButton()
    }

    private func configureScreenState() {
        switch ownerData {
            case .driver:
                segmentControlStackView.isHidden = true
                ownerDataSpacerView.isHidden = false
                individualCardsView.isHidden = false
                segmentControl.isHidden = true
                entityCardsView.isHidden = true
                individualAddressCard.isHidden = true
                individualNameCard.isEnabled = false
            case .individual:
                segmentControlStackView.isHidden = false
                ownerDataSpacerView.isHidden = true
                individualCardsView.isHidden = false
                segmentControl.isHidden = false
                entityCardsView.isHidden = true
                individualAddressCard.isHidden = false
                individualNameCard.isEnabled = true
            case .organization:
                segmentControlStackView.isHidden = false
                ownerDataSpacerView.isHidden = true
                segmentControl.isHidden = false
                entityCardsView.isHidden = false
                individualCardsView.isHidden = true
                individualNameCard.isEnabled = false
        }
    }

    private func shouldEnableSaveButton() -> Bool {
        switch ownerData {
            case .driver:
                return true
            case .individual(let firstName, let lastName, _, let address):
                return firstName != nil && firstName != "" && lastName != nil
                    && lastName != "" && address != nil && address != ""
            case .organization(let name, let address):
                return name != nil && name != "" && address != nil && address != ""
        }
    }

    private func openIndividualNameInputBottomController(cardToUpdate: SmallValueCardView) {
        guard case .individual(let name, let lastName, let middleName, let address) = ownerData else {
            return
        }

        let controller = InputBottomViewController()
        container?.resolve(controller)

        let lastNameInput = InputBottomViewController.InputObject(
            text: lastName,
            placeholder: NSLocalizedString("user_profile_last_name", comment: ""),
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRule: [ RequiredValidationRule() ]
        )

        let firstNameInput = InputBottomViewController.InputObject(
            text: name,
            placeholder: NSLocalizedString("user_profile_first_name", comment: ""),
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRule: [ RequiredValidationRule() ]
        )

        let patronymicInput = InputBottomViewController.InputObject(
            text: middleName,
            placeholder: NSLocalizedString("insurance_euro_protocol_add_participant_patronymic", comment: ""),
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRule: [ ]
        )

        controller.input = .init(
            title: OwnerCardType.individualName.title,
            infoText: nil,
            inputs: [ lastNameInput, firstNameInput, patronymicInput ]
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] result in
                let surname = result[lastNameInput.id]
                let firstName = result[firstNameInput.id]
                let patronymic = result[patronymicInput.id]

                self.ownerData = .individual(firstName: firstName, lastName: surname, middleName: patronymic, address: address)
                cardToUpdate.update(error: nil)
                self.updateUI()
                self.dismiss(animated: true)
            }
        )
        showBottomSheet(contentViewController: controller)
    }

    private func openAddressInputButtomViewController(
        cardType: OwnerCardType,
        cardView: SmallValueCardView,
        completion: @escaping (String) -> Void
    ) {
        let controller: TextAreaInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: cardType.title,
            description: nil,
            textInputTitle: nil,
            textInputPlaceholder: cardType.title,
            initialText: cardView.getValue(),
            validationRules: [ ],
            showValidInputIcon: true,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            charsLimited: .unlimited,
            showMaxCharsLimit: false
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            text: { [unowned self] text in
                completion(text)
                cardView.update(error: nil)
                self.updateUI()
                self.dismiss(animated: true)
            }
        )
        showBottomSheet(contentViewController: controller)
    }

    func openOrganizationNameInputButtomController(
        cardType: OwnerCardType,
        cardView: SmallValueCardView,
        completion: @escaping (String) -> Void
    ) {
        let controller: InputBottomViewController = .init()
        container?.resolve(controller)

        let addressInput = InputBottomViewController.InputObject(
            text: cardView.getValue(),
            placeholder: cardType.title,
            keyboardType: .default,
            validationRule: [ RequiredValidationRule() ]
        )

        controller.input = .init(
            title: cardType.title,
            infoText: nil,
            inputs: [ addressInput ]
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] result in
                completion(result[addressInput.id] ?? "")
                cardView.update(error: nil)
                self.updateUI()
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func createCard(cardType: OwnerCardType) -> SmallValueCardView {
        let card = SmallValueCardView()
        card.set(
            title: cardType.title,
            placeholder: cardType.title,
            value: nil,
            error: nil
        )
        return card
    }

    private func initialIndividualData() -> OwnerData {
        let initialOwnerData = OwnerData(owner: input.owner)
        if case .individual = initialOwnerData {
            return initialOwnerData
        } else {
            return .emptyIndividual
        }
    }

    private func initialOrganizationData() -> OwnerData {
        let initialOwnerData = OwnerData(owner: input.owner)
        if case .organization = initialOwnerData {
            return initialOwnerData
        } else {
            return .emptyOrganization
        }
    }

    @objc private func switchAction() {
        if switcher.isOn {
            ownerData = .driver
        } else {
            ownerData = initialIndividualData()
            segmentControl.setSelectedIndex(0, animated: false)
        }

        updateUI()
    }

    @objc func segmentControlAction(sender: RMRStyledSwitch) {
        switch sender.selectedIndex {
            case 0:
                ownerData = initialIndividualData()
            case 1:
                ownerData = initialOrganizationData()
            default:
                break
        }

        updateUI()
    }

    @objc private func saveButtonAction() {
        guard let owner: EuroProtocolOwner = ownerData.owner else { return }

        output.save(owner) { [weak self] result in
            if case .failure(let error) = result {
                self?.handleError(error)
            }
        }
    }

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        switch error {
            case EuroProtocolServiceError.sdkError(.validationErrors( _, _, errors: let errors)):
                var fioErrorDescriptions: [String] = []
                errors.forEach { validationError in
                    switch validationError {
                        case .invalidSymbolsInOwnerName( _, description: let description, _),
                             .invalidOwnerNameLength(_, description: let description, _),
                             .invalidOwnerSurnameLength( _, description: let description, _),
                             .invalidSymbolsInOwnerSurname( _, description: let description, _),
                             .invalidOwnerMiddleNameLength( _, description: let description, _),
                             .invalidSymbolsInOwnerMiddleName( _, description: let description, _):

                            fioErrorDescriptions.append(description)

                        case .invalidOwnerOrganizationNameLength(_, description: let description, _):
                            entityNameCard.update(error: description)

                        case .invalidOwnerAddressLength(_, description: let description, _):
                            if case .organization = ownerData {
                                entityAddressCard.update(error: description)
                            } else {
                                individualAddressCard.update(error: description)
                            }

                        default:
                            processError(error)
                    }
                }
                individualNameCard.update(error: fioErrorDescriptions.joined(separator: ", "))

            default:
            processError(error)
        }
        return true
    }
}
