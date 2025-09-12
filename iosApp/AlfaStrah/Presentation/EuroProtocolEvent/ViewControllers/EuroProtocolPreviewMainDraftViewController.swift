//
//  EuroProtocolPreviewMainDraftViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class EuroProtocolPreviewMainDraftViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let draft: () -> EuroProtocolCurrentDraftContentModel?
        let updateDraft: (@escaping (Result<EuroProtocolCurrentDraftContentModel, EuroProtocolServiceError>) -> Void) -> Void
        let user: EsiaUser?
        let acceptDraft: (@escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
        let participantBInviteModel: () -> ParticipantBInviteModel
    }

    struct Output {
        let draftAccepted: () -> Void
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
    private let acceptButton: RoundEdgeButton = .init()

    private lazy var buttonsStackView: UIStackView = {
        let value = UIStackView()
        value.axis = .vertical
        value.spacing = 9
        return value
    }()

    private func disagreementsCardValue() -> String {
        let value: String
        guard let disagreements = input.draft()?.noticeInfo.disagreements else {
            return (NSLocalizedString("insurance_euro_protocol_draft_has_disagreements_not_filled", comment: ""))}

        value = disagreements
            ? (NSLocalizedString("insurance_euro_protocol_draft_has_disagreements_true", comment: ""))
            : (NSLocalizedString("insurance_euro_protocol_draft_has_disagreements_false", comment: ""))
        return value
    }

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
        title = NSLocalizedString("insurance_euro_protocol_preview_draft_title", comment: "")
        updateUI()
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

        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false

        scrollContentView.addSubview(rootStackView)

        acceptButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        acceptButton.setTitle(NSLocalizedString("insurance_euro_protocol_sign_draft_button_title", comment: ""), for: .normal)
        acceptButton.addTarget(self, action: #selector(acceptButtonTap), for: .touchUpInside)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false

        buttonsStackView.addArrangedSubview(acceptButton)

        addBottomButtonsContent(buttonsStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: scrollContentView) +
                [
                    acceptButton.heightAnchor.constraint(equalToConstant: 48)
                ]
        )
    }

    private func updateUI() {
        rootStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Info section

        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.text = NSLocalizedString("insurance_euro_protocol_preview_draft_info_text", comment: "")
        infoLabel <~ Style.Label.secondaryText
        rootStackView.addArrangedSubview(infoLabel)

        // Accident info section

        addSectionTitle(NSLocalizedString("insurance_euro_protocol_draft_accident_title", comment: ""))

        addCardInfoSection([
            .init(
                title: NSLocalizedString("insurance_euro_protocol_accident_contest_title", comment: ""),
                value: disagreementsCardValue()
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_accident_address_title", comment: ""),
                value: input.draft()?.noticeInfo.place
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_accident_date_title", comment: ""),
                value: input.draft()?.noticeInfo.date.map { AppLocale.dateTimeString($0) }
            ),
        ])

        // Participant A info section

        addParticipantInfoSection(
            sectionTitle: NSLocalizedString("insurance_euro_protocol_draft_participant_a_title", comment: ""),
            participantName: input.user?.fullName,
            participant: input.draft()?.participantA
        )

        // Participant A car damage section

        addCarDamageSection(
            sectionTitle: NSLocalizedString("insurance_euro_protocol_draft_participant_a_auto_damage_title", comment: ""),
            participant: input.draft()?.participantA
        )

        // Participant A car damage place section

        addBumpPlaceSection(
            title: NSLocalizedString("insurance_euro_protocol_participant_A_car_damage_place", comment: ""),
            initialImpact: input.draft()?.participantA.roadAccidents.initialImpact
        )

        // Participant B info section

        addParticipantInfoSection(
            sectionTitle: NSLocalizedString("insurance_euro_protocol_draft_participant_b_title", comment: ""),
            participantName: input.participantBInviteModel().fullName,
            participant: input.draft()?.participantB
        )

        // Participant B car damage section

        addCarDamageSection(
            sectionTitle: NSLocalizedString("insurance_euro_protocol_draft_participant_b_auto_damage_title", comment: ""),
            participant: input.draft()?.participantB
        )

        // Participant B car damage place section

        addBumpPlaceSection(
            title: NSLocalizedString("insurance_euro_protocol_participant_B_car_damage_place", comment: ""),
            initialImpact: input.draft()?.participantB.roadAccidents.initialImpact
        )
    }

    private func addParticipantInfoSection(sectionTitle: String, participantName: String?, participant: EuroProtocolParticipantInfo?) {
        guard let participant = participant else { return }

        var infoDataItems: [InfoData?] = [
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_driver_name_title", comment: ""),
                value: participantName
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_driver_license_number_input_title", comment: ""),
                value: participant.license?.licenseNumber
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_driver_license_start_date_input_title", comment: ""),
                value: participant.license?.issueDate.map { AppLocale.rsaSdkDateFormatter($0) }
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_driver_license_end_date_input_title", comment: ""),
                value: participant.license?.expiryDate.map { AppLocale.rsaSdkDateFormatter($0) }
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_driver_phone_title", comment: ""),
                value: participant.driver?.phone
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_driver_address_title", comment: ""),
                value: participant.driver?.address
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_driver_license_title", comment: ""),
                value: participant.license?.categoryValue
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_osago_title", comment: ""),
                value: participant.policy.policyNumber
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_osago_start_title", comment: ""),
                value: participant.policy.beginDate
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_osago_end_title", comment: ""),
                value: participant.policy.toDate.map { AppLocale.rsaSdkDateFormatter($0) }
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_osago_participant_auto_brand", comment: ""),
                value: participant.transport.brand
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_osago_participant_auto_model", comment: ""),
                value: participant.transport.model
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_plate_number_title", comment: ""),
                value: participant.transport.regmark
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_vin_number_title", comment: ""),
                value: participant.transport.vin
            )
        ]

        switch participant.owner {
            case .driver:
                infoDataItems.append(
                    .init(
                        title: NSLocalizedString("insurance_euro_protocol_preview_draft_owner_name_title", comment: ""),
                        value: participantName
                    )
                )
            case .individual(let firstName, let lastName, let middleName, let address):
                let fullName = [ firstName, lastName, middleName ]
                    .compactMap { $0 }
                    .joined(separator: " ")

                infoDataItems.append(contentsOf: [
                    .init(
                        title: NSLocalizedString("insurance_euro_protocol_preview_draft_owner_name_title", comment: ""),
                        value: fullName
                    ),
                    .init(
                        title: NSLocalizedString("insurance_euro_protocol_preview_draft_owner_address_title", comment: ""),
                        value: address
                    )
                ])
            case .organization(let name, let address):
                infoDataItems.append(contentsOf: [
                    .init(
                        title: NSLocalizedString("insurance_euro_protocol_preview_draft_owner_company_title", comment: ""),
                        value: name
                    ),
                    .init(
                        title: NSLocalizedString("insurance_euro_protocol_preview_draft_owner_address_title", comment: ""),
                        value: address
                    ),
                ])
            case .none:
                break
        }

        addSectionTitle(sectionTitle)
        addCardInfoSection(infoDataItems)
    }

    private func addCarDamageSection(sectionTitle: String, participant: EuroProtocolParticipantInfo?) {
        guard let participant = participant else { return }

        addSectionTitle(sectionTitle)
        addCardInfoSection([
            .init(
                title: NSLocalizedString("insurance_euro_protocol_participant_vehicle_type", comment: ""),
                value: participant.transport.vechicleType?.title
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_preview_draft_accident_type_title", comment: ""),
                value: participant.roadAccidents.circumstancesValue
            ),
            .init(
                title: NSLocalizedString("insurance_euro_protocol_participant_car_damage_info_card_title", comment: ""),
                value: participant.roadAccidents.comments
            ),
        ])
    }

    private func addSectionTitle(_ text: String) {
        let label = UILabel(frame: .zero)
        label.text = text
        label <~ Style.Label.primaryHeadline1

        rootStackView.addArrangedSubview(spacer(24))
        rootStackView.addArrangedSubview(label)
        rootStackView.addArrangedSubview(spacer(15))
    }

    private struct InfoData {
        let title: String
        let value: String

        init?(title: String, value: String?) {
            guard let value = value, !value.isEmpty else { return nil }

            self.title = title
            self.value = value
        }
    }

    private func addCardInfoSection(_ info: [InfoData?]) {
        let info = info.compactMap { $0 }
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0

        for infoCell in info {
            let card = SmallValueCardView()
            card.set(
                title: infoCell.title,
                placeholder: "",
                value: infoCell.value,
                error: nil,
                icon: .center(nil),
                isEnabled: false,
                showSeparator: true
            )
            stackView.addArrangedSubview(card)
        }

        rootStackView.addArrangedSubview(CardView(contentView: stackView))
    }

    private func addBumpPlaceSection(title: String, initialImpact: EuroProtocolInitialImpact?) {
        guard let initialImpact = initialImpact else { return }

        addSectionTitle(title)
        let vechicleType = initialImpact.vechicleType
        let view: FirstDamagePlacePicker
        switch vechicleType {
            case .car:
                view = FirstDamagePlaceCarPickerView.fromNib()
            case .truck:
                view = FirstDamagePlaceTruckPickerView.fromNib()
            case .bike:
                view = FirstDamagePlaceBikePickerView.fromNib()
        }
        view.state = .bumpPreview

        if let bumpSheme = vechicleType.bumpSchemeType.init(sectionValue: initialImpact.sector) {
            view.updateSelection(with: bumpSheme)
        }

        rootStackView.addArrangedSubview(view)
    }

    @objc private func acceptButtonTap() {
        navigationItem.hidesBackButton = true
        loadingIndicator(show: true)
        input.acceptDraft { [weak self] result in
            self?.navigationItem.hidesBackButton = false
            self?.loadingIndicator(show: false)
            switch result {
                case .success:
                    self?.output.draftAccepted()
                case .failure(let error):
                    self?.handleError(error)
            }
        }
    }

    // MARK: - Handle Error

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        processError(error)
        return true
    }
}
