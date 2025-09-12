//
//  FirstDamageViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 15.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class FirstDamagePlaceViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let participant: ParticipantType
        let initialImpact: () -> EuroProtocolInitialImpact?
        let selectedDamageText: () -> String?
        let isSaveEnabled: () -> Bool
    }

    struct Output {
        let showDamagePositionPicker: (_: EuroProtocolVehicleType) -> Void
        let selectedVehicleTypeChanged: () -> Void
        let save: (_ completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
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

    private var selectedVehicleType: EuroProtocolVehicleType = .car

    enum ParticipantType {
        case participantA
        case participantB

        var vehicleTypeTitle: String {
            switch self {
                case .participantA:
                    return NSLocalizedString("insurance_euro_protocol_participant_A_vehicle_type", comment: "")
                case .participantB:
                    return NSLocalizedString("insurance_euro_protocol_participant_B_vehicle_type", comment: "")
            }
        }

        var damagePlaceTitle: String {
            switch self {
                case .participantA:
                    return NSLocalizedString("insurance_euro_protocol_participant_A_car_damage_place", comment: "")
                case .participantB:
                    return NSLocalizedString("insurance_euro_protocol_participant_B_car_damage_place", comment: "")
            }
        }

        init(euroProtocolParticipant: EuroProtocolParticipant) {
            switch euroProtocolParticipant {
                case .participantA:
                    self = .participantA
                case .participantB:
                    self = .participantB
            }
        }
    }

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 12

        return stack
    }()

    private let vehicleTypeLabel: UILabel = .init()
    private let damagePlaceLabel: UILabel = .init()

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedVehicleType = input.initialImpact()?.vechicleType ?? .car
        commonSetup()
        setupUI()
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
        title = NSLocalizedString("insurance_euro_protocol_participant_car_damage_place_title", comment: "")
        vehicleTypeLabel <~ Style.Label.primaryHeadline1
        damagePlaceLabel <~ Style.Label.primaryHeadline1
        vehicleTypeLabel.text = input.participant.vehicleTypeTitle
        damagePlaceLabel.text = input.participant.damagePlaceTitle
        let vehicleTypeCard = CardView(contentView: vehicleTypePickerCardView)
        let damagePlaceCard = CardView(contentView: damagePickerCardView)
        contentStackView.addArrangedSubview(vehicleTypeLabel)
        contentStackView.addArrangedSubview(vehicleTypeCard)
        contentStackView.setCustomSpacing(24, after: vehicleTypeCard)
        contentStackView.addArrangedSubview(damagePlaceLabel)
        contentStackView.addArrangedSubview(damagePlaceCard)
    }

    private func updateUI() {
        vehicleTypePickerCardView.update(value: selectedVehicleType.displayText)
        damagePickerCardView.update(value: input.selectedDamageText())
        saveButton.isEnabled = input.isSaveEnabled()
    }

    private lazy var damagePickerCardView: SmallValueCardView = {
        let infoView = SmallValueCardView()

        let title = NSLocalizedString("insurance_euro_protocol_participant_car_damage_place_title", comment: "")
        infoView.set(
            title: title,
            placeholder: title,
            value: input.selectedDamageText(),
            error: nil
        )

        infoView.tapHandler = { [unowned self] in
            self.output.showDamagePositionPicker(self.selectedVehicleType)
        }

        return infoView
    }()

    private lazy var vehicleTypePickerCardView: SmallValueCardView = {
        let infoView = SmallValueCardView()

        let title = NSLocalizedString("insurance_euro_protocol_participant_vehicle_type_full", comment: "")
        infoView.set(
            title: title,
            placeholder: title,
            value: selectedVehicleType.displayText,
            error: nil
        )

        infoView.tapHandler = { [unowned self] in
            self.openVehiclePickerBottomViewController()
        }

        return infoView
    }()

    private func openVehiclePickerBottomViewController() {
        let controller: LegacySingleValuePickerBottomViewController = .init()
        container?.resolve(controller)

        let dataSource: [SelectableItem] = EuroProtocolVehicleType.allCases.map { element in
            VehicleTypeSelectable(
                title: element.displayText,
                isSelected: element == selectedVehicleType
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

                self.selectedVehicleType = EuroProtocolVehicleType.allCases[index]
                self.output.selectedVehicleTypeChanged()
                self.updateUI()
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    @objc private func saveButtonAction() {
        output.save { [weak self] in
            if case .failure(let error) = $0 {
                self?.processError(error)
            }
        }
    }
}
