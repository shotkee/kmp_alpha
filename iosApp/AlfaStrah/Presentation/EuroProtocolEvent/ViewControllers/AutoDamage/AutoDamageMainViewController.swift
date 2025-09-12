//
//  AutoDamageMainViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 13.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class AutoDamageMainViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let type: ParticipantType
        let info: () -> EuroProtocolParticipantInfo?
        let isFieldFilled: (CardType) -> Bool
    }

    struct Output {
        let save: () -> Void
        let showPlace: () -> Void
        let showPhoto: () -> Void
        let showInfo: () -> Void
    }

    var input: Input!
    var output: Output!

    enum ParticipantType {
        case participantA
        case participantB

        var title: String {
            switch self {
                case .participantA:
                    return NSLocalizedString("insurance_euro_protocol_participant_car_damage_title_a", comment: "")
                case .participantB:
                    return NSLocalizedString("insurance_euro_protocol_participant_car_damage_title_b", comment: "")
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

    enum CardType: CaseIterable {
        case place
        case photo
        case info

        var title: String {
            switch self {
                case .place:
                    return NSLocalizedString("insurance_euro_protocol_participant_car_damage_place_title", comment: "")
                case .photo:
                    return NSLocalizedString("insurance_euro_protocol_participant_car_damage_photo_title", comment: "")
                case .info:
                    return NSLocalizedString("insurance_euro_protocol_participant_car_damage_info_card_title", comment: "")
            }
        }

        var placeholder: String {
            switch self {
                case .place:
                    return NSLocalizedString("insurance_euro_protocol_participant_car_damage_place_card_placeholder", comment: "")
                case .photo:
                    return NSLocalizedString("insurance_euro_protocol_participant_car_damage_photo_card_placeholder", comment: "")
                case .info:
                    return NSLocalizedString("insurance_euro_protocol_participant_car_damage_info_card_placeholder", comment: "")
            }
        }
    }

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 12

        return stack
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init()
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    var inputViews: [ValueCardView] = []

    struct Notify {
        var infoUpdated: () -> Void
    }

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        infoUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = .white
        title = input.type.title

        CardType.allCases.forEach { contentStackView.addArrangedSubview(createCardView($0)) }

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

    private func updateUI() {
        CardType.allCases.enumerated().forEach {
            guard inputViews.count > $0.offset else { return }

            let filledText = NSLocalizedString("insurance_euro_protocol_participant_car_damage_card_text", comment: "")
            let isFilled = input.isFieldFilled($0.element)
            let displayValue = isFilled ? filledText : ""
            inputViews[$0.offset].update(value: displayValue)
        }

        let isFirstDamageFilled = input.isFieldFilled(.place)
        let isDamagePartsFilled = input.isFieldFilled(.photo)
        let isAccidentInfoFilled = input.isFieldFilled(.info)
        saveButton.isEnabled = isFirstDamageFilled && isDamagePartsFilled && isAccidentInfoFilled
    }

    private func createCardView(_ type: CardType) -> CardView {
        let infoView = ValueCardView()
        infoView.set(
            title: type.title,
            placeholder: type.placeholder,
            value: nil,
            error: nil
        )

        infoView.tapHandler = { [unowned self] in
            switch type {
                case .place:
                    self.output.showPlace()
                case .photo:
                    self.output.showPhoto()
                case .info:
                    self.output.showInfo()
            }
        }

        inputViews.append(infoView)
        return CardView(contentView: infoView)
    }

    @objc private func saveButtonAction() {
        output.save()
    }
}
