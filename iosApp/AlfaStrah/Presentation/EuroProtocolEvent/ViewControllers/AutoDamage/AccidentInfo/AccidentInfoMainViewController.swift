//
//  AccidentInfoMainViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 14.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class AccidentInfoMainViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let type: EuroProtocolParticipant
        let selectedCircumstances: () -> [EuroProtocolCircumstance]
        let comment: () -> String?
        let otherAccidentDescription: () -> String?
    }

    struct Output {
        let save: ( _ completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
        let showTypes: () -> Void
        let saveComment: (String?) -> Void
        let saveOtherAccidentDescription: (String?) -> Void
    }

    var input: Input!
    var output: Output!

    enum CardType: CaseIterable {
        static let title: String = NSLocalizedString("insurance_euro_protocol_accident_type_main_title", comment: "")

        case type
        case info

        func getTitle(_ type: EuroProtocolParticipant) -> String {
            switch self {
                case .type:
                    switch type {
                        case .participantA:
                            return NSLocalizedString("insurance_euro_protocol_accident_type_card_types_placeholder_a", comment: "")
                        case .participantB:
                            return NSLocalizedString("insurance_euro_protocol_accident_type_card_types_placeholder_b", comment: "")
                    }
                case .info:
                    switch type {
                        case .participantA:
                            return NSLocalizedString("insurance_euro_protocol_accident_type_card_info_placeholder_a", comment: "")
                        case .participantB:
                            return NSLocalizedString("insurance_euro_protocol_accident_type_card_info_placeholder_b", comment: "")
                    }
            }
        }

        var infoText: String {
            switch self {
                case .type:
                    return NSLocalizedString("insurance_euro_protocol_accident_type_card_types_title", comment: "")
                case .info:
                    return NSLocalizedString("insurance_euro_protocol_accident_type_card_info_title", comment: "")
            }
        }
    }

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 0

        return stack
    }()

    private lazy var accidentDescriptionCard: SmallValueCardView = {
        let value = SmallValueCardView()
        let title = NSLocalizedString("insurance_euro_protocol_accident_description_card_title", comment: "")
        let description = input.otherAccidentDescription()
        value.set(
            title: title,
            placeholder: title,
            value: description,
            error: nil
        )
        value.tapHandler = {
            self.openTextInputBottomViewController(
                with: value,
                title: title,
                initialText: self.input.otherAccidentDescription(),
                completion: { self.output.saveOtherAccidentDescription($0) }
            )
        }

        return value
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var otherDescriptionStack: UIStackView = {
        let value = UIStackView()
        value.axis = .vertical
        value.addArrangedSubview(spacer(12))
        value.addArrangedSubview(CardView(contentView: accidentDescriptionCard))

        return value
    }()

    var inputViews: [SmallValueCardView] = []

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
        title = CardType.title

        contentStackView.addArrangedSubview(createSectionView(CardType.type))
        contentStackView.addArrangedSubview(otherDescriptionStack)
        contentStackView.addArrangedSubview(spacer(24))
        contentStackView.addArrangedSubview(createSectionView(CardType.info))

        addBottomButtonsContent(saveButton)
        scrollContentView.addSubview(contentStackView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        accidentDescriptionCard.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),

            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func updateUI() {
        CardType.allCases.enumerated().forEach {
            guard inputViews.count > $0.offset else { return }

            switch $0.element {
                case .type:
                    inputViews[$0.offset].update(
                        value: input.selectedCircumstances()
                            .map { $0.description }
                            .joined(separator: ", ")
                    )
                case .info:
                    inputViews[$0.offset].update(value: input.comment())
            }
        }

        let selectedCircumstances = input.selectedCircumstances()

        otherDescriptionStack.isHidden = !selectedCircumstances.contains(.other)
        accidentDescriptionCard.update(value: input.otherAccidentDescription())

        let shouldNotApplyCommentFilledCondition: Bool = input.type == .participantB
        let commentFilledCondition: Bool = shouldNotApplyCommentFilledCondition || !(input.comment()?.isEmpty ?? true)

        let otherDescriptionFilledCondition: Bool = !selectedCircumstances.contains(.other) ||
            !(input.otherAccidentDescription()?.isEmpty ?? true)

        saveButton.isEnabled = !selectedCircumstances.isEmpty && commentFilledCondition && otherDescriptionFilledCondition
    }

    private func createSectionView(_ type: CardType) -> UIView {
        var value: String = ""
        switch type {
            case .type:
                value = input.selectedCircumstances()
                    .map { $0.description }
                    .joined(separator: ", ")
            case .info:
                value = input.comment() ?? ""
        }

        let infoLabel = UILabel(frame: .zero)
        infoLabel <~ Style.Label.primaryHeadline1
        infoLabel.text = type.infoText

        let infoView = SmallValueCardView()
        infoView.set(
            title: type.getTitle(input.type),
            placeholder: type.getTitle(input.type),
            value: value,
            error: nil
        )

        infoView.tapHandler = { [unowned self] in
            switch type {
                case .type:
                    self.output.showTypes()
                case .info:
                    self.openTextInputBottomViewController(
                        with: infoView,
                        title: type.getTitle(input.type),
                        initialText: input.comment(),
                        completion: { self.output.saveComment($0) }
                    )
            }
        }

        let stack = UIStackView(arrangedSubviews: [ infoLabel, CardView(contentView: infoView) ])
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 15

        switch type {
            case .type:
                break
            case .info:
                stack.isHidden = input.type == .participantB
        }

        inputViews.append(infoView)
        return stack
    }

    private func openTextInputBottomViewController(
        with infoView: SmallValueCardView,
        title: String,
        initialText: String?,
        completion: @escaping (String?) -> Void
    ) {
        let controller: TextAreaInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: title,
            description: nil,
            textInputTitle: nil,
            textInputPlaceholder: title,
            initialText: initialText,
            validationRules: [ RequiredValidationRule() ],
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
                infoView.update(value: text)
                infoView.update(error: nil)

                completion(text)
                self.dismiss(animated: true)
            }
        )
        showBottomSheet(contentViewController: controller)
    }

    @objc private func saveButtonAction() {
        output.save { [weak self] result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.handleError(error)
            }
        }
    }

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        switch error {
            case EuroProtocolServiceError.sdkError(.invalidRoadAccidentDescription(_, let description)):
                accidentDescriptionCard.update(error: description)
            case EuroProtocolServiceError.sdkError(.invalidCircumstancesDescription(_, let description)):
                if let cardIndex = CardType.allCases.firstIndex(of: .info) {
                    inputViews[cardIndex].update(error: description)
                }
            default:
                processError(error)
        }

        return true
    }
}
