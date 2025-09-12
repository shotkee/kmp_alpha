//
//  DamagedDetailsPhotoViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 14.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class DamagedPartPhotosViewController: EuroProtocolBaseScrollViewController {
    typealias DamageEditCompletion = (Result<Void, EuroProtocolServiceError>) -> Void

    enum DamagedPartError: Error, Displayable {
        case reachedMaxNumberOfParts

        var errorMessage: String {
            switch self {
                case .reachedMaxNumberOfParts:
                    return NSLocalizedString(
                        "insurance_euro_protocol_damaged_parts_limit_reached", comment: ""
                    )
            }
        }

        var displayValue: String? { errorMessage }
        var debugDisplayValue: String { errorMessage }
    }

    struct Input {
        let participant: ParticipantType
        let damages: () -> [EuroProtocolVehiclePart]
        let photo: (EuroProtocolVehiclePart) -> UIImage?
        let vehicleType: () -> VehicleType
        let isSaveEnabled: () -> Bool
    }

    struct Output {
        let onFirstAppear: () -> Void
        let save: () -> Void
        let addDamage: (_ completion: @escaping DamageEditCompletion) -> Void
        let selectVehicleType: (VehicleType) -> Void
        let deleteDamage: (_ part: EuroProtocolVehiclePart, _ completion: @escaping DamageEditCompletion) -> Void
        let selectDamage: (EuroProtocolVehiclePart) -> Void
    }

    struct Notify {
        var infoUpdated: () -> Void
    }

    var input: Input!
    var output: Output!

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        infoUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    enum ParticipantType {
        case participantA
        case participantB

        init(euroProtocolParticipant: EuroProtocolParticipant) {
            switch euroProtocolParticipant {
                case .participantA:
                    self = .participantA
                case .participantB:
                    self = .participantB
            }
        }

        var vehicleTypeTitle: String {
            switch self {
                case .participantA:
                    return NSLocalizedString("insurance_euro_protocol_participant_A_vehicle_type", comment: "")
                case .participantB:
                    return NSLocalizedString("insurance_euro_protocol_participant_B_vehicle_type", comment: "")
            }
        }

        var damagePhotoTitle: String {
            switch self {
                case .participantA:
                    return NSLocalizedString("insurance_euro_protocol_vehicle_damage_participant_A", comment: "")
                case .participantB:
                    return NSLocalizedString("insurance_euro_protocol_vehicle_damage_participant_B", comment: "")
            }
        }
    }

    enum VehicleType: Equatable, CaseIterable {
        case car
        case other

        var displayText: String {
            switch self {
                case .car:
                    return NSLocalizedString("insurance_euro_protocol_vehicle_type_car", comment: "")
                case .other:
                    return NSLocalizedString("insurance_euro_protocol_vehicle_type_other", comment: "")
            }
        }
    }

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var vehicleTypeStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private lazy var damagePhotosStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private lazy var damagePhotoItemsStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let vehicleTypeLabel: UILabel = .init()
    private let damagePhotoTitleLabel: UILabel = .init()
    private lazy var damagePhotoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private lazy var addDamageButton: UIView = {
        let button = CardHorizontalButton()
        button.set(
            title: NSLocalizedString("insurance_euro_protocol_add_damaged_part", comment: ""),
            icon: UIImage(named: "icon-europrotocol-add-car")
        )
        button.tapHandler = { [unowned self] in
            self.addDamage()
        }
        return CardView(contentView: button)
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init()
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        updateUI()
    }

    private var viewDidAppearWasCalled: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !viewDidAppearWasCalled {
            output.onFirstAppear()
            viewDidAppearWasCalled = true
        }
    }

    override func setupUI() {
        super.setupUI()

        addBottomButtonsContent(saveButton)
        scrollContentView.addSubview(contentStackView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
                contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
                contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
                contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),

                saveButton.heightAnchor.constraint(equalToConstant: 48)
            ]
        )
    }

    private func commonSetup() {
        view.backgroundColor = Style.Color.background
        title = NSLocalizedString(
            "insurance_euro_protocol_participant_car_damage_photo_title", comment: ""
        )
        vehicleTypeLabel <~ Style.Label.primaryHeadline1
        damagePhotoTitleLabel <~ Style.Label.primaryHeadline1
        damagePhotoDescriptionLabel <~ Style.Label.secondaryText
        vehicleTypeLabel.text = input.participant.vehicleTypeTitle
        damagePhotoTitleLabel.text = input.participant.damagePhotoTitle
        damagePhotoDescriptionLabel.text = NSLocalizedString(
            "insurance_euro_protocol_car_damage_add_hint", comment: ""
        )

        contentStackView.addArrangedSubview(vehicleTypeStackView)
        contentStackView.addArrangedSubview(damagePhotosStackView)

        damagePhotosStackView.addArrangedSubview(damagePhotoTitleLabel)
        damagePhotosStackView.addArrangedSubview(damagePhotoDescriptionLabel)
        damagePhotosStackView.addArrangedSubview(damagePhotoItemsStackView)
        damagePhotosStackView.addArrangedSubview(addDamageButton)

        let vehicleTypeCard = CardView(contentView: vehicleTypePickerCardView)
        vehicleTypeStackView.addArrangedSubview(vehicleTypeLabel)
        vehicleTypeStackView.addArrangedSubview(vehicleTypeCard)
    }

    private func updateUI() {
        vehicleTypePickerCardView.update(value: input.vehicleType().displayText)
        damagePhotoDescriptionLabel.isHidden = !input.damages().isEmpty
        damagePhotoItemsStackView.isHidden = input.damages().isEmpty
        damagePhotoItemsStackView.subviews.forEach { $0.removeFromSuperview() }
        input.damages().forEach {
            if let view = damageView(for: $0) {
                damagePhotoItemsStackView.addArrangedSubview(view)
            }
        }
        saveButton.isEnabled = input.isSaveEnabled()
    }

    private lazy var vehicleTypePickerCardView: SmallValueCardView = {
        let infoView = SmallValueCardView()
        let title = NSLocalizedString("insurance_euro_protocol_participant_vehicle_type_full", comment: "")
        infoView.set(
            title: title,
            placeholder: title,
            value: input.vehicleType().displayText,
            error: nil
        )
        infoView.tapHandler = { [unowned self] in
            self.openVehiclePickerBottomViewController()
        }
        return infoView
    }()

    private func damageView(for part: EuroProtocolVehiclePart) -> UIView? {
        let view: ValueCardView = .init()

        let title: String = {
            if case .other(let title, _) = part {
                return title
            }
            return part.description
        }()

        view.set(
            title: title,
            placeholder: NSLocalizedString(
                "insurance_euro_protocol_participant_car_damage_place_card_placeholder",
                comment: ""
            ),
            value: input.photo(part) == nil
                ? nil
                : NSLocalizedString(
                    "insurance_euro_protocol_participant_car_damage_place_card_value",
                    comment: ""
                  ),
            error: nil,
            icon: .delete
        )

        view.iconTapHandler = { [unowned self] in
            self.deleteDamage(part)
        }

        view.tapHandler = { [unowned self] in
            self.output.selectDamage(part)
        }

        return CardView(contentView: view)
    }

    private func openVehiclePickerBottomViewController() {
        let controller: LegacySingleValuePickerBottomViewController = .init()
        container?.resolve(controller)

        let dataSource: [SelectableItem] = VehicleType.allCases.map { element in
            VehicleTypeSelectable(
                title: element.displayText,
                isSelected: element == input.vehicleType()
            )
        }

        controller.input = .init(
            title: NSLocalizedString("insurance_euro_protocol_participant_vehicle_type", comment: ""),
            dataSource: dataSource
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] selected in
                guard let index = dataSource.firstIndex(where: { $0.id == selected.id }) else {
                    return
                }

                self.output.selectVehicleType(VehicleType.allCases[index])
                self.updateUI()
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func addDamage() {
        output.addDamage { [weak self] result in
            if case .failure(let error) = result {
                self?.processError(error)
            }
        }
    }

    private func deleteDamage(_ part: EuroProtocolVehiclePart) {
        output.deleteDamage(part) { [weak self] result in
            if case .failure(let error) = result {
                self?.processError(error)
            }
        }
    }

    @objc private func saveButtonAction() {
        output.save()
    }
}
