//
//  ParticipantInfoViewController.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 13.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class ParticipantInfoViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let type: EuroProtocolParticipant
        let currentDraft: () -> EuroProtocolCurrentDraftContentModel?
        let isFilled: (CardType) -> Bool
    }

    struct Output {
        let save: () -> Void
        let showOwner: () -> Void
        let showPhoto: () -> Void
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

    enum CardType: CaseIterable {
        static let value: String = NSLocalizedString("insurance_euro_protocol_participant_data_owner_text", comment: "")

        case owner
        case photo

        var title: String {
            switch self {
                case .owner:
                    return NSLocalizedString("insurance_euro_protocol_participant_data_owner_title", comment: "")
                case .photo:
                    return NSLocalizedString("insurance_euro_protocol_participant_data_photo_title", comment: "")
            }
        }

        var placeholder: String {
            switch self {
                case .owner:
                    return NSLocalizedString("insurance_euro_protocol_participant_data_owner_placeholder", comment: "")
                case .photo:
                    return NSLocalizedString("insurance_euro_protocol_participant_data_photo_placeholder", comment: "")
            }
        }

        func getValue(isFilled: Bool) -> String? {
            switch self {
                case .owner:
                    return isFilled ? NSLocalizedString("insurance_euro_protocol_participant_data_owner_text", comment: "") : nil
                case .photo:
                    return isFilled ? NSLocalizedString("insurance_euro_protocol_participant_data_photo_text", comment: "") : nil
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

    private var allPropertiesAreValid: Bool {
        var participantInfo: EuroProtocolParticipantInfo?

        switch input.type {
            case .participantA:
                participantInfo = input.currentDraft()?.participantA
            case .participantB:
                participantInfo = input.currentDraft()?.participantB
        }

        if let isEmpty = participantInfo?.owner.isEmpty, !isEmpty, participantInfo?.transport.photo != nil {
            return true
        } else {
            return false
        }
    }

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init()
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    var inputViews: [ValueCardView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = .white
        switch input.type {
            case .participantA:
                title = NSLocalizedString("insurance_euro_protocol_participant_data_A_title", comment: "")
            case .participantB:
                title = NSLocalizedString("insurance_euro_protocol_participant_data_B_title", comment: "")
        }
        CardType.allCases.forEach { contentStackView.addArrangedSubview(createCardView($0)) }

        scrollContentView.addSubview(contentStackView)
        addBottomButtonsContent(saveButton)

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

            inputViews[$0.offset].update(value: $0.element.getValue(isFilled: input.isFilled($0.element)))
        }

        saveButton.isEnabled = allPropertiesAreValid
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
                case .owner:
                    self.output.showOwner()
                case .photo:
                    self.output.showPhoto()
            }
        }

        inputViews.append(infoView)
        return CardView(contentView: infoView)
    }

    @objc private func saveButtonAction() {
        output.save()
    }
}
