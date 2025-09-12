//
//  EuroProtocolCheckOSAGOInfoViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 16.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

class EuroProtocolCheckOSAGOInfoViewController: EuroProtocolBaseScrollViewController {
    struct Output {
        let successfullySetPolicyInfo: () -> Void
        let acceptPolicyInfo: () -> Void
    }

    struct Input {
        let type: OSAGOCheckParticipantType
        let policyInfo: (_ seriesAndNumber: SeriesAndNumberDocument,
                         _ completion: @escaping (Result<OSAGOCheckParticipant, EuroProtocolServiceError>) -> Void) -> Void
    }

    var output: Output!
    var input: Input!

    enum State {
        case input(enteredValue: SeriesAndNumberDocument?)
        case info(dataSource: OSAGOCheckParticipant)

        var currentSeriesAndNumber: SeriesAndNumberDocument? {
            switch self {
                case .info(let dataSource):
                    return dataSource.policyInfo.seriesAndNumber
                case .input(let enteredValue):
                    return enteredValue
            }
        }
    }

    private enum InfoType: CaseIterable {
        case policy
        case auto

        static let description: String = NSLocalizedString("insurance_euro_protocol_osago_participant_info", comment: "")

        var title: String {
            switch self {
                case .policy:
                    return NSLocalizedString("insurance_euro_protocol_osago_participant_policy_section_title", comment: "")
                case .auto:
                    return NSLocalizedString("insurance_euro_protocol_osago_participant_auto_section_title", comment: "")
            }
        }

        enum PolicyInfo: CaseIterable {
            case company
            case policy
            case startDate
            case endDate

            var title: String {
                switch self {
                    case .company:
                        return NSLocalizedString("insurance_euro_protocol_osago_participant_company", comment: "")
                    case .policy:
                        return NSLocalizedString("insurance_euro_protocol_osago_participant_policy", comment: "")
                    case .startDate:
                        return NSLocalizedString("insurance_euro_protocol_osago_participant_policy_start_date", comment: "")
                    case .endDate:
                        return NSLocalizedString("insurance_euro_protocol_osago_participant_policy_end_date", comment: "")
                }
            }

            func getValue(_ dataSource: OSAGOCheckParticipant) -> String? {
                switch self {
                    case .company:
                        return dataSource.policyInfo.companyName
                    case .policy:
                        return dataSource.policyInfo.seriesAndNumber.description
                    case .startDate:
                        return dataSource.policyInfo.startDate
                    case .endDate:
                        return dataSource.policyInfo.endDate
                }
            }
        }

        enum AutoInfo: CaseIterable {
            case brand
            case model
            case vin
            case gosNumber

            var title: String {
                switch self {
                    case .brand:
                        return NSLocalizedString("insurance_euro_protocol_osago_participant_auto_brand", comment: "")
                    case .model:
                        return NSLocalizedString("insurance_euro_protocol_osago_participant_auto_model", comment: "")
                    case .vin:
                        return NSLocalizedString("insurance_euro_protocol_osago_participant_auto_vin", comment: "")
                    case .gosNumber:
                        return NSLocalizedString("insurance_euro_protocol_osago_participant_auto_number", comment: "")
                }
            }

            func getValue(_ dataSource: OSAGOCheckParticipant) -> String? {
                switch self {
                    case .brand:
                        return dataSource.autoInfo.brand
                    case .model:
                        return dataSource.autoInfo.model
                    case .vin:
                        return dataSource.autoInfo.vin
                    case .gosNumber:
                        return dataSource.autoInfo.licensePlate
                }
            }
        }
    }

    private lazy var contentStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 24

        return value
    }()

    private lazy var inputStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 15

        return value
    }()

    private lazy var infoStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 24

        return value
    }()

    private lazy var buttonsStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 9

        return value
    }()

    private lazy var policySeriesAndNumberView: SmallValueCardView = {
        let value = SmallValueCardView()
        value.set(
            title: NSLocalizedString("insurance_euro_protocol_osago_main_participant_placeholder", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_osago_main_participant_placeholder", comment: ""),
            value: state.currentSeriesAndNumber?.description,
            error: nil
        )

        value.tapHandler = { [unowned self] in
            self.openPolicyInputBottomViewController()
        }

        return value
    }()

    private lazy var infoLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value <~ Style.Label.secondaryText
        value.textAlignment = .left
        value.numberOfLines = 0

        return value
    }()

    private lazy var successInfoButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.addTarget(self, action: #selector(successButtonAction), for: .touchUpInside)
        value.setTitle(NSLocalizedString("insurance_euro_protocol_osago_participant_success_info", comment: ""), for: .normal)
        value <~ Style.RoundedButton.oldPrimaryButtonSmall

        return value
    }()

    private lazy var failureInfoButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.addTarget(self, action: #selector(failureButtonAction), for: .touchUpInside)
        value.setTitle(NSLocalizedString("insurance_euro_protocol_osago_participant_failure_info", comment: ""), for: .normal)
        value <~ Style.RoundedButton.oldOutlinedButtonSmall

        return value
    }()

    private lazy var policyReadErrorView: ZeroView = {
        let view = ZeroView()
        view.update(viewModel: .init(kind: .loading))
        view.subviews.forEach { $0.backgroundColor = .clear }
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    private var state: State = .input(enteredValue: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        requestPolicyInfoIfNeeded()
    }

    override func setupUI() {
        super.setupUI()

        state = .input(enteredValue: input.type.defaultSeriesAndNumber)

        view.backgroundColor = .white
        title = input.type.cardTitle

        scrollContentView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(inputStackView)
        contentStackView.addArrangedSubview(infoStackView)

        let policyCardView = CardView(contentView: policySeriesAndNumberView)
        inputStackView.addArrangedSubview(policyCardView)
        inputStackView.addArrangedSubview(infoLabel)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false

        addBottomButtonsContent(buttonsStackView)
        policyReadErrorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(policyReadErrorView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),

            policyReadErrorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            policyReadErrorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            policyReadErrorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            policyReadErrorView.topAnchor.constraint(equalTo: inputStackView.bottomAnchor),

            failureInfoButton.heightAnchor.constraint(equalToConstant: 48),
            successInfoButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func updateUI() {
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        switch state {
            case .input:
                infoLabel.text = nil
            case .info(let participantInfo):
                infoLabel.text = InfoType.description
                buttonsStackView.addArrangedSubview(failureInfoButton)
                buttonsStackView.addArrangedSubview(successInfoButton)

                InfoType.allCases.forEach {
                    infoStackView.addArrangedSubview(createSection(participantInfo, type: $0))
                }
        }
    }

    private func createSection(_ participantInfo: OSAGOCheckParticipant, type: InfoType) -> UIView {
        let headerTitleLabel: UILabel = .init(frame: .zero)
        headerTitleLabel <~ Style.Label.primaryHeadline3
        headerTitleLabel.text = type.title

        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 15

        stack.addArrangedSubview(headerTitleLabel)
        stack.addArrangedSubview(createCardView(participantInfo, type: type))

        return stack
    }

    private func createCardView(_ participantInfo: OSAGOCheckParticipant, type: InfoType) -> CardView {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 0

        switch type {
            case .policy:
                InfoType.PolicyInfo.allCases
                    .filter { $0.getValue(participantInfo) != nil }
                    .forEach {
                        if let value = $0.getValue(participantInfo) {
                            stack.addArrangedSubview(createInfoView(title: $0.title, note: value))
                        }
                    }
            case .auto:
                InfoType.AutoInfo.allCases
                    .filter { $0.getValue(participantInfo) != nil }
                    .forEach {
                        if let value = $0.getValue(participantInfo) {
                            stack.addArrangedSubview(createInfoView(title: $0.title, note: value))
                        }
                    }
        }

        return CardView(contentView: stack)
    }

    private func createInfoView(title: String, note: String) -> UIView {
        let infoView = SmallValueCardView()
        infoView.set(
            title: title,
            placeholder: title,
            value: note,
            error: nil,
            icon: .center(nil)
        )

        return infoView
    }

    private func requestPolicyInfoIfNeeded() {
        if case .input(let value) = state, let document = value {
            requestInfo(document)
        }
    }

    private func requestInfo(_ document: SeriesAndNumberDocument) {
        input.policyInfo(document) { [weak self] result in
            guard let self = self else { return }

            self.policyReadErrorView.isHidden = true
            switch result {
                case .success(let info):
                    self.state = .info(dataSource: info)
                    self.output.successfullySetPolicyInfo()
                case .failure(let error):
                    self.state = .input(enteredValue: document)
                    self.handleError(error)
            }
            self.updateUI()
        }
    }

    private func openPolicyInputBottomViewController() {
        let controller: InputBottomViewController = .init()
        container?.resolve(controller)

        let seriaInput = InputBottomViewController.InputObject(
            text: state.currentSeriesAndNumber?.series,
            placeholder: NSLocalizedString("insurance_euro_protocol_osago_policy_seria_placeholder", comment: ""),
            keyboardType: .default,
            validationRule: [ RequiredValidationRule() ]
        )

        let numberInput = InputBottomViewController.InputObject(
            text: state.currentSeriesAndNumber?.number,
            placeholder: NSLocalizedString("insurance_euro_protocol_osago_policy_number_placeholder", comment: ""),
            keyboardType: .numberPad,
            validationRule: [ RequiredValidationRule() ]
        )

        controller.input = .init(
            title: input.type.cardTitle,
            infoText: NSLocalizedString("insurance_euro_protocol_osago_number_input_description", comment: ""),
            inputs: [ seriaInput, numberInput ]
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] result in
                let policy = SeriesAndNumberDocument(series: result[seriaInput.id] ?? "", number: result[numberInput.id] ?? "")
                policySeriesAndNumberView.update(value: policy.description)
                policySeriesAndNumberView.update(error: nil)
                self.state = .input(enteredValue: policy)
                self.dismiss(animated: true) {
                    self.requestInfo(policy)
                }
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    @objc private func successButtonAction() {
        guard case .info = state else { return }

        output.acceptPolicyInfo()
    }

    @objc private func failureButtonAction() {
        openPolicyInputBottomViewController()
    }

    // MARK: - Handle Error

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        switch error {
            case EuroProtocolServiceError.sdkError(.errorToReadPolicy):
                showPolicyReadError(error)
            case EuroProtocolServiceError.sdkError(.invalidPolicySeries(_, let descriptionText)):
                showValidationError(text: descriptionText)
            case EuroProtocolServiceError.sdkError(.invalidPolicyNumber(_, let descriptionText)):
                showValidationError(text: descriptionText)
            default:
                processError(error)
        }

        return true
    }

    private func showPolicyReadError(_ error: Error) {
        guard let error = error as? EuroProtocolServiceError else {
            return
        }

        let zeroViewModel = ZeroViewModel(
            kind: .custom(
                title: error.errorMessage.title,
                message: error.errorMessage.message,
                iconKind: .error
            ),
            canCloseScreen: true,
            buttons: [
                .init(
                    title: NSLocalizedString("common_retry", comment: ""),
                    isPrimary: false,
                    action: {
                        self.requestPolicyInfoIfNeeded()
                    }
                ),
                .init(
                    title: NSLocalizedString("insurance_euro_protocol_osago_participant_change_data", comment: ""),
                    isPrimary: true,
                    action: {
                        self.openPolicyInputBottomViewController()
                    }
                )
            ]
        )

        policyReadErrorView.update(viewModel: zeroViewModel)
        policyReadErrorView.isHidden = false
    }

    private func showValidationError(text: String) {
        policySeriesAndNumberView.update(error: text)
    }
}
