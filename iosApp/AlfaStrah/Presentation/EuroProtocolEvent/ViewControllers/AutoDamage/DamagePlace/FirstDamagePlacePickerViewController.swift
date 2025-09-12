//
//  FirstDamagePlacePickerViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class FirstDamagePlacePickerViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let vehicleType: EuroProtocolVehicleType
        let initialDamagePosition: EuroProtocolVehicleDamagePosition?
    }

    struct Output {
        let save: (_ position: EuroProtocolVehicleDamagePosition) -> Void
    }

    var input: Input!
    var output: Output!

    private var vehicleDamage: EuroProtocolVehicleDamagePosition?

    override func viewDidLoad() {
        super.viewDidLoad()

        vehicleDamage = input.initialDamagePosition
        commonSetup()
    }

    private lazy var descrLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 32

        return stack
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init()
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        button.isEnabled = false

        return button
    }()

    private lazy var pickerView: FirstDamagePlacePicker = createPickerView(for: input.vehicleType)

    private func createPickerView(for type: EuroProtocolVehicleType) -> FirstDamagePlacePicker {
        let view: FirstDamagePlacePicker
        switch type {
            case .car:
                view = FirstDamagePlaceCarPickerView.fromNib()
            case .truck:
                view = FirstDamagePlaceTruckPickerView.fromNib()
            case .bike:
                view = FirstDamagePlaceBikePickerView.fromNib()
        }
        view.selectionHandler = { [unowned self] in
            self.saveButton.isEnabled = $0 != nil
            if let position = $0 {
                self.vehicleDamage = EuroProtocolVehicleDamagePosition(scheme: position)
            }
        }
        return view
    }

    override func setupUI() {
        super.setupUI()

        addBottomButtonsContent(saveButton)

        scrollContentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(descrLabel)
        contentStackView.addArrangedSubview(pickerView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        descrLabel.translatesAutoresizingMaskIntoConstraints = false

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
        descrLabel <~ Style.Label.secondaryText
        descrLabel.text = NSLocalizedString("insurance_euro_protocol_participant_car_damage_place_description", comment: "")
        if let bumpScheme = vehicleDamage?.bumpScheme {
            pickerView.updateSelection(with: bumpScheme)
        }
    }

    @objc private func saveButtonAction() {
        guard let damagePosition = vehicleDamage else {
            return
        }

        output.save(damagePosition)
    }
}
