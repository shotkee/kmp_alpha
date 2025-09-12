//
//  EuroProtocolMainDraftViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class EuroProtocolMainDraftViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let draft: () -> EuroProtocolCurrentDraftContentModel?
        let updateDraft: (@escaping (Result<EuroProtocolCurrentDraftContentModel, EuroProtocolServiceError>) -> Void) -> Void
        let participantBInviteModel: () -> ParticipantBInviteModel
        let isAccidentCircumstancesFilled: () -> Bool
        let isParticipantAInfoFilled: () -> Bool
        let isParticipantAVehicleDamagesFilled: () -> Bool
        let isParticipantBInfoFilled: () -> Bool
        let isParticipantBVehicleDamagesFilled: () -> Bool
    }

    struct Output {
        let createDraft: (@escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
        let draftPreview: () -> Void
        let addParticipantB: () -> Void
        let accidentInfo: () -> Void
        let participantAInfo: () -> Void
        let participantAAutoDamage: () -> Void
        let participantBInfo: () -> Void
        let participantBAutoDamage: () -> Void
    }

    var input: Input!
    var output: Output!

    struct Notify {
        var draftUpdated: () -> Void
    }

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        draftUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    private let rootStackView: UIStackView = .init()
    private let nextButton: RoundEdgeButton = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_draft_title", comment: "")

        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateDraftModel()
    }

    private func updateDraftModel() {
        input.updateDraft { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success:
                    self.updateUI()
                case .failure(let error):
                    self.handleError(error)
            }
        }
    }

    override func setupUI() {
        super.setupUI()

        rootStackView.axis = .vertical
        rootStackView.alignment = .fill
        rootStackView.distribution = .fill
        rootStackView.spacing = 0
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.layoutMargins = UIEdgeInsets(top: 24, left: 18, bottom: 18, right: 24)
        scrollView.addSubview(rootStackView)

        nextButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        nextButton.setTitle(NSLocalizedString("insurance_euro_protocol_draft_button_title", comment: ""), for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        addBottomButtonsContent(nextButton)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: scrollContentView) +
                [
                    rootStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
                    nextButton.heightAnchor.constraint(equalToConstant: 48)
                ]
        )
    }

    private func updateUI() {
        rootStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let filledText = NSLocalizedString("insurance_euro_protocol_filled_text", comment: "")

        // Add participant section

        let participantBAdded = input.draft()?.noticeInfo.invitationCode != nil && input.participantBInviteModel().fullName != nil
        let addParticipantB = ValueCardView()
        addParticipantB.set(
            title: participantBAdded
                ? NSLocalizedString("insurance_euro_protocol_draft_open_qr_code_title", comment: "")
                : NSLocalizedString("insurance_euro_protocol_draft_add_participant_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_not_added_text", comment: ""),
            value: participantBAdded ? input.participantBInviteModel().fullName : nil,
            error: validationErrors.filter { [ 1080 ].contains($0.info.code) }.map { $0.info.description }.joined(separator: ", "),
            icon: participantBAdded
                ? .rightArrow
                : .center(UIImage(named: "icon-europrotocol-add-participant"))
        )
        addParticipantB.tapHandler = { [unowned self] in
            self.output.addParticipantB()
        }
        rootStackView.addArrangedSubview(CardView(contentView: addParticipantB))

        // Accident info section

        addSectionTitle(NSLocalizedString("insurance_euro_protocol_draft_accident_setion_title", comment: ""))

        let accidentInfoFilled = input.isAccidentCircumstancesFilled()
        let accidentInfo = ValueCardView()
        accidentInfo.set(
            title: NSLocalizedString("insurance_euro_protocol_draft_accident_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_not_filled_text", comment: ""),
            value: accidentInfoFilled ? filledText : nil,
            error: validationErrors.filter { [ 1081, 1082, 1083 ].contains($0.info.code) }
                .map { $0.info.description }.joined(separator: ", "),
            icon: .rightArrow
        )
        accidentInfo.tapHandler = { [unowned self] in
            self.output.accidentInfo()
        }
        rootStackView.addArrangedSubview(CardView(contentView: accidentInfo))

        // Participant A info section

        addSectionTitle(NSLocalizedString("insurance_euro_protocol_draft_participant_a_setion_title", comment: ""))

        let participantInfoErrors = validationErrors.filter { [ 1090, 1091, 1098, 1108 ].contains($0.info.code) }
            .map { $0.info.description }.joined(separator: ", ")
        let damageErrors = validationErrors.filter { [ 1066, 1069, 1089, 1067, 1092, 1097, 1109, 1110 ].contains($0.info.code) }
            .map { $0.info.description }.joined(separator: ", ")
        let participantAInfoFilled = input.isParticipantAInfoFilled()
        let participantADamageFilled = input.isParticipantAVehicleDamagesFilled()

        let participantAInfo = ValueCardView()
        participantAInfo.set(
            title: NSLocalizedString("insurance_euro_protocol_draft_participant_a_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_not_filled_text", comment: ""),
            value: participantAInfoFilled ? filledText : nil,
            error: participantInfoErrors,
            icon: .rightArrow
        )
        participantAInfo.tapHandler = { [unowned self] in
            self.output.participantAInfo()
        }
        rootStackView.addArrangedSubview(CardView(contentView: participantAInfo))

        rootStackView.addArrangedSubview(spacer(12))

        let participantADamage = ValueCardView()
        participantADamage.set(
            title: NSLocalizedString("insurance_euro_protocol_draft_participant_a_auto_damage_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_not_filled_text", comment: ""),
            value: participantADamageFilled ? filledText : nil,
            error: damageErrors,
            icon: .rightArrow
        )
        participantADamage.tapHandler = { [unowned self] in
            self.output.participantAAutoDamage()
        }
        rootStackView.addArrangedSubview(CardView(contentView: participantADamage))

        // Participant B info section

        addSectionTitle(NSLocalizedString("insurance_euro_protocol_draft_participant_b_setion_title", comment: ""))

        let participantBInfoFilled = input.isParticipantBInfoFilled()
        let participantBDamageFilled = input.isParticipantBVehicleDamagesFilled()

        let participantBInfo = ValueCardView()
        participantBInfo.set(
            title: NSLocalizedString("insurance_euro_protocol_draft_participant_b_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_not_filled_text", comment: ""),
            value: participantBInfoFilled ? filledText : nil,
            error: participantInfoErrors,
            icon: .rightArrow
        )
        participantBInfo.tapHandler = { [unowned self] in
            self.output.participantBInfo()
        }
        rootStackView.addArrangedSubview(CardView(contentView: participantBInfo))

        rootStackView.addArrangedSubview(spacer(12))

        let participantBDamage = ValueCardView()
        participantBDamage.set(
            title: NSLocalizedString("insurance_euro_protocol_draft_participant_b_auto_damage_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_not_filled_text", comment: ""),
            value: participantBDamageFilled ? filledText : nil,
            error: damageErrors,
            icon: .rightArrow
        )
        participantBDamage.tapHandler = { [unowned self] in
            self.output.participantBAutoDamage()
        }
        rootStackView.addArrangedSubview(CardView(contentView: participantBDamage))
    }

    private func addSectionTitle(_ text: String) {
        let label = UILabel(frame: .zero)
        label.text = text
        label <~ Style.Label.secondaryHeadline2

        rootStackView.addArrangedSubview(spacer(24))
        rootStackView.addArrangedSubview(label)
        rootStackView.addArrangedSubview(spacer(15))
    }

    @objc private func nextButtonTap() {
        loadingIndicator(show: true)
        output.createDraft { [weak self] result in
            guard let self = self else { return }

            self.loadingIndicator(show: false)
            switch result {
                case .success:
                    self.output.draftPreview()
                case .failure(let error):
                    switch error {
                        case .sdkError(.validationErrors(_, _, let errors)):
                            self.handleValidationErrors(errors)
                            self.updateUI()
                        default:
                            self.handleError(error)
                    }
            }
        }
    }

    // MARK: - Handle Error

    private var validationErrors: [RsaSdkValidationError] = []

    private func handleValidationErrors(_ errors: [RsaSdkValidationError]) {
        validationErrors = errors

        let errorCodesToShow: [Int] = [ 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1084, 1085, 1086, 1087, 1088, 1093, 1094, 1095, 1107 ]
        let errorMessage: String = errors.filter { errorCodesToShow.contains($0.info.code) }
            .map { $0.info.description }.joined(separator: "\n")
        if !errorMessage.isEmpty {
            alertPresenter.show(alert: ErrorNotificationAlert(error: nil, text: errorMessage))
        }
    }

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        switch error {
            case EuroProtocolServiceError.sdkError(.draftIsAlreadyRegistered(_, _)):
                return false
            default:
                processError(error)
                return true
        }
    }
}
