//
//  EuroProtocolDraftStatusViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 24.08.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class EuroProtocolDraftStatusViewController: EuroProtocolBaseScrollViewController {
    enum DraftStatusError: Error, Displayable {
        case noParticipantAInsuranceFound

        var errorMessage: String {
            switch self {
                case .noParticipantAInsuranceFound:
                    return NSLocalizedString(
                        "insurance_euro_protocol_no_participant_A_insurance_found", comment: ""
                    )
            }
        }

        var displayValue: String? { errorMessage }
        var debugDisplayValue: String { errorMessage }
    }

    struct Output {
        let eraseClose: () -> Void
        let saveClose: () -> Void
        let finalClose: () -> Void
        let sendNotice: (_ completion: @escaping (Result<String, EuroProtocolServiceError>) -> Void) -> Void
        let sendAlfaReport: (_ aisNumber: String, _ completion: @escaping (Result<String, EuroProtocolServiceError>) -> Void) -> Void
        let changeDraft: () -> Void
        let backToHome: () -> Void
        let next: () -> Void
        let continueAtOffice: () -> Void
    }

    struct Input {
        let draftStatus: (@escaping (Result<EuroProtocolDraftStatus, EuroProtocolServiceError>) -> Void) -> Void
        let aisStatus: () -> AisStatus
    }

    var input: Input!
    var output: Output!

    enum State {
        case waiting // Состояние 1
        case rejected // Состояние 2
        case rejectedAgain // Состояние 3
        case signedAISNotSent // Состояние 4
        case signedSendToAISError // Состояние 5
        case successUnregistered // Состояние 6
        case signedSendAISNumberError // Состояние 7
        case registrationError // Состояние 8
        case success // Состояние 9
        case registeredAISNotSent // Состояние 9.5 (на 10.10.2021 нет в спеке)
        case registeredSendToAISError // Состояние 10
        case registeredSendAISNumberError // Состояние 11
        case unknownStatus // Состояние 12
    }

    enum AisStatus {
        case notSent
        case sendToAISError
        case sendToAlfaError(aisNumber: String)
        case success(aisNumber: String)
    }

    private var status: EuroProtocolDraftStatus = .waitingForOtherSign {
        didSet { updateScreenState() }
    }

    private var aisStatus: AisStatus = .notSent {
        didSet { updateScreenState() }
    }

    private var state: State = .waiting {
        didSet { updateUI() }
    }

    private lazy var rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var cardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 9
        return stack
    }()

    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label <~ Style.Label.secondaryText
        label.numberOfLines = 0
        return label
    }()

    private lazy var nextButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_continue", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    private lazy var checkStatusPrimaryButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(checkStatusButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_check_status", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    private lazy var checkStatusOutlinedButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(checkStatusButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_check_status", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldOutlinedButtonSmall
        return button
    }()

    private lazy var changeDraftButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(changeDraftButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_change_draft", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    private lazy var sendToAISButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(sendToAISButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_send_to_ais", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    private lazy var sendAisToAlfaButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(sendAisToAlfaButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_send_ais_to_alfa", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    private lazy var backToStartPrimaryButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_back_to_start", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    private lazy var backToStartOutlinedButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_back_to_start", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldOutlinedButtonSmall
        return button
    }()

    private lazy var backToHomeButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(backToHomeButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_back_to_home", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    private lazy var continueAtOfficeOutlinedButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(continueAtOffice), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_draft_status_continue_at_office", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldOutlinedButtonSmall
        return button
    }()

    private func noticeStatusCard() -> UIView {
        let noticeCard = ReadonlyValueCardView()
        noticeCard.set(
            title: NSLocalizedString("insurance_euro_protocol_draft_status_notice_status_card_title", comment: ""),
            value: status.description,
            icon: status.icon
        )
        return CardView(contentView: noticeCard)
    }

    private func noticeNumberCard() -> UIView {
        let epguNumber: String? = {
            switch self.status {
                case .registered(let message):
                    return message
                default:
                    return nil
            }
        }()

        let noticeNumberCard = ReadonlyValueCardView()
        noticeNumberCard.set(
            title: NSLocalizedString("insurance_euro_protocol_draft_status_notice_number_card_title", comment: ""),
            value: epguNumber ?? NSLocalizedString("insurance_euro_protocol_draft_status_value_not_received_text", comment: ""),
            icon: epguNumber == nil ? UIImage(named: "icon-clock") : UIImage(named: "icon-checkmark-black")
        )
        return CardView(contentView: noticeNumberCard)
    }

    private func AISNumberCard() -> UIView {
        let value: String = {
            switch self.aisStatus {
                case .notSent:
                    return NSLocalizedString("insurance_euro_protocol_draft_status_value_not_received_text", comment: "")
                case .sendToAISError:
                    return NSLocalizedString("insurance_euro_protocol_draft_status_value_error_text", comment: "")
                case .sendToAlfaError(let aisNumber), .success(let aisNumber):
                    return aisNumber
            }
        }()

        let icon: UIImage? = {
            switch self.aisStatus {
                case .notSent:
                    return UIImage(named: "icon-clock")
                case .sendToAISError:
                    return UIImage(named: "icon-close")
                case .sendToAlfaError, .success:
                    return UIImage(named: "icon-checkmark-black")
            }
        }()

        let AISNumberCard = ReadonlyValueCardView()
        AISNumberCard.set(
            title: NSLocalizedString("insurance_euro_protocol_draft_status_ais_number_card_title", comment: ""),
            value: value,
            icon: icon
        )
        return CardView(contentView: AISNumberCard)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateData()
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = Style.Color.background
        navigationItem.title = NSLocalizedString("insurance_euro_protocol_draft_status_title", comment: "")
        addCloseButton { [weak self] in
            self?.closeButtonAction()
        }
        scrollContentView.addSubview(rootStackView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: scrollContentView, margins: .init(top: 0, left: 18, bottom: 0, right: 18))
        )

        rootStackView.addArrangedSubview(UIView())
        rootStackView.addArrangedSubview(tipLabel)
        rootStackView.addArrangedSubview(cardsStackView)
        NSLayoutConstraint.fixHeight(view: checkStatusPrimaryButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: checkStatusOutlinedButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: changeDraftButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: sendToAISButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: sendAisToAlfaButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: backToStartPrimaryButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: backToStartOutlinedButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: backToHomeButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: nextButton, constant: 48)
        NSLayoutConstraint.fixHeight(view: continueAtOfficeOutlinedButton, constant: 48)
        addBottomButtonsContent(buttonsStackView)
    }

    private func updateUI() {
        cardsStackView.subviews.forEach { $0.removeFromSuperview() }
        buttonsStackView.subviews.forEach { $0.removeFromSuperview() }

        switch state {
            case .waiting:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_waiting_for_other_sign_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                buttonsStackView.addArrangedSubview(checkStatusPrimaryButton)
            case .rejected:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_rejected_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                buttonsStackView.addArrangedSubview(changeDraftButton)
            case .rejectedAgain:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_rejected_again_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                buttonsStackView.addArrangedSubview(backToHomeButton)
            case .signedAISNotSent:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_sent_to_registrate_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(checkStatusOutlinedButton)
                buttonsStackView.addArrangedSubview(sendToAISButton)
                sendToAISButton.isEnabled = false
            case .signedSendToAISError:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_AIS_getting_error_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(backToStartOutlinedButton)
                buttonsStackView.addArrangedSubview(sendToAISButton)
                sendToAISButton.isEnabled = false
            case .successUnregistered:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_notice_sent_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(checkStatusPrimaryButton)
            case .signedSendAISNumberError:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_AIS_sending_error_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(checkStatusOutlinedButton)
                buttonsStackView.addArrangedSubview(sendAisToAlfaButton)
            case .registrationError:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_registration_error_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(backToStartPrimaryButton)
            case .success:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_success_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(noticeNumberCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(nextButton)
            case .registeredAISNotSent:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_registered_AIS_not_sent_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(noticeNumberCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(sendToAISButton)
                sendToAISButton.isEnabled = true
            case .registeredSendToAISError:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_registered_AIS_getting_error_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(noticeNumberCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(backToStartOutlinedButton)
                buttonsStackView.addArrangedSubview(sendToAISButton)
                sendToAISButton.isEnabled = true
            case .registeredSendAISNumberError:
                tipLabel.text = NSLocalizedString("insurance_euro_protocol_draft_status_registered_AIS_sending_error_tip", comment: "")
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(noticeNumberCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(continueAtOfficeOutlinedButton)
                buttonsStackView.addArrangedSubview(sendAisToAlfaButton)
            case .unknownStatus:
                tipLabel.text = nil
                cardsStackView.addArrangedSubview(noticeStatusCard())
                cardsStackView.addArrangedSubview(noticeNumberCard())
                cardsStackView.addArrangedSubview(AISNumberCard())
                buttonsStackView.addArrangedSubview(backToStartPrimaryButton)
        }
    }

    @objc private func closeButtonAction() {
        switch state {
            case .waiting, .rejected, .signedAISNotSent, .successUnregistered, .signedSendAISNumberError, .registeredAISNotSent:
                output.saveClose()
            case .rejectedAgain, .signedSendToAISError, .registrationError, .registeredSendToAISError, .unknownStatus:
                output.eraseClose()
            case .success:
                nextButtonAction()
            case .registeredSendAISNumberError:
                output.finalClose()
        }
    }

    @objc private func checkStatusButtonAction() {
        updateDraftStatus { }
    }

    @objc private func changeDraftButtonAction() {
        output.changeDraft()
    }

    @objc private func backToHomeButtonAction() {
        output.backToHome()
    }

    @objc private func sendToAISButtonAction() {
        func aisNumber() -> String? {
            guard case let .registered(comment) = status
            else { return nil }
            
            if let comment = comment
            {
                return comment.firstIndex(of: "N")
                    .map { String(comment.suffix(from: $0)) }
                    ?? comment
            }
            else
            {
                return ""
            }
        }
        
        guard let aisNumber = aisNumber()
        else { return }
        
        let hide = showLoadingIndicator(
            message: NSLocalizedString("insurance_euro_protocol_draft_status_ais_send_loader_text", comment: "")
        )
        output.sendNotice { [weak self] result in
            hide(nil)
            guard let self = self else { return }

            switch result {
                case .success:
                    self.sendAlfaReport(aisNumber: aisNumber)
                case .failure(let error):
                    self.aisStatus = .sendToAISError
                    self.handleError(error)
            }
        }
    }

    @objc private func sendAisToAlfaButtonAction() {
        guard case .sendToAlfaError(let aisNumber) = aisStatus else {
            return
        }

        sendAlfaReport(aisNumber: aisNumber)
    }

    @objc private func nextButtonAction() {
        output.next()
    }

    @objc private func continueAtOffice() {
        output.continueAtOffice()
    }

    private func sendAlfaReport(aisNumber: String) {
        let hide = showLoadingIndicator(
            message: NSLocalizedString("insurance_euro_protocol_draft_status_ais_alfa_loader_text", comment: "")
        )
        self.output.sendAlfaReport(aisNumber) { [weak self] result in
            hide(nil)
            guard let self = self else { return }

            switch result {
                case .success(_):
                    self.aisStatus = .success(aisNumber: aisNumber)
                case .failure(let error):
                    self.aisStatus = .sendToAlfaError(aisNumber: aisNumber)
                    self.handleError(error)
            }
        }
    }

    private func updateData() {
        updateDraftStatus { [weak self] in
            self?.updateAisStatus()
        }
    }

    private func updateDraftStatus(completion: @escaping () -> Void) {
        let hide = showLoadingIndicator(
            message: NSLocalizedString("insurance_euro_protocol_draft_status_loading_text", comment: "")
        )
        input.draftStatus { [weak self] result in
            completion()
            hide(nil)
            guard let self = self else { return }

            switch result {
                case .success(let status):
                    self.status = status
                case .failure(let error):
                    self.handleError(error)
            }
        }
    }

    private func updateAisStatus() {
        aisStatus = input.aisStatus()
    }

    private func updateScreenState() {
        switch status {
            case .waitingForOtherSign:
                state = .waiting
            case .sentToRegistrate:
                switch aisStatus {
                    case .notSent:
                        state = .signedAISNotSent
                    case .sendToAISError:
                        state = .signedSendToAISError
                    case .sendToAlfaError:
                        state = .signedSendAISNumberError
                    case .success:
                        state = .successUnregistered
                }
            case .rejected:
                state = .rejected
            case .rejectedAgain:
                state = .rejectedAgain
            case .registered:
                switch aisStatus {
                    case .notSent:
                        state = .registeredAISNotSent
                    case .sendToAISError:
                        state = .registeredSendToAISError
                    case .sendToAlfaError:
                        state = .registeredSendAISNumberError
                    case .success:
                        state = .success
                }
            case .timeout, .sendingServerError:
                state = .registrationError
            default:
                state = .unknownStatus
        }
    }

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        let handled = super.handleError(error)
        guard !handled else { return true }

        processError(error)
        return true
    }
}
