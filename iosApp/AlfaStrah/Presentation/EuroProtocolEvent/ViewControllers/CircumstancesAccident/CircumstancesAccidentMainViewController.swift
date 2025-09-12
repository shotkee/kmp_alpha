//
//  CircumstancesAccidentMainViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 05.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class CircumstancesAccidentMainViewController: EuroProtocolBaseScrollViewController {
    private enum CardType: CaseIterable {
        static let title: String = NSLocalizedString("insurance_euro_protocol_accident_main_title", comment: "")
        static let placeholder: String = NSLocalizedString("insurance_euro_protocol_accident_main_placeholder", comment: "")
        static let value: String = NSLocalizedString("insurance_euro_protocol_accident_main_value", comment: "")

        case disagreements
        case address
        case date
        case photo

        var cardTitle: String {
            switch self {
                case .disagreements:
                    return NSLocalizedString("insurance_euro_protocol_accident_contest_title", comment: "")
                case .address:
                    return NSLocalizedString("insurance_euro_protocol_accident_address_title", comment: "")
                case .date:
                    return NSLocalizedString("insurance_euro_protocol_accident_date_title", comment: "")
                case .photo:
                    return NSLocalizedString("insurance_euro_protocol_accident_photo_title", comment: "")
            }
        }

        func getValue(hasDisagreements: Bool?, draftInfo: EuroProtocolNoticeInfo?) -> String {
            switch self {
                case .disagreements:
                    return hasDisagreements != nil ? CardType.value : ""
                case .address:
                    guard let draftInfo = draftInfo else { return "" }

                    return draftInfo.place != nil ? CardType.value : ""
                case .date:
                    guard let draftInfo = draftInfo else { return "" }

                    return draftInfo.date != nil ? CardType.value : ""
                case .photo:
                    guard let draftInfo = draftInfo else { return "" }

                    return draftInfo.scheme != nil ? CardType.value : ""
            }
        }
    }
    private lazy var contentStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 12

        return value
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        value.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        value <~ Style.RoundedButton.oldPrimaryButtonSmall

        return value
    }()

    private var inputViews: [ValueCardView] = []

    struct Notify {
        var infoUpdated: () -> Void
    }

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        infoUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    struct Output {
        let openDisagreements: () -> Void
        let openAddress: () -> Void
        let openDate: () -> Void
        let openPhoto: () -> Void
        let save: () -> Void
    }

    struct Input {
        var hasDisagreements: () -> Bool?
        var currentDraftNoticeInfo: () -> EuroProtocolNoticeInfo?
    }

    var output: Output!
    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = .white
        title = CardType.title

        CardType.allCases.forEach { contentStackView.addArrangedSubview(createCardView(type: $0)) }

        addBottomButtonsContent(saveButton)
        scrollContentView.addSubview(contentStackView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

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

            inputViews[$0.offset].update(value: $0.element.getValue(hasDisagreements: input.hasDisagreements(),
                                                                    draftInfo: input.currentDraftNoticeInfo()))
        }
        saveButton.isEnabled = allPropertiesAreValid()
    }

    private func createCardView(type: CardType) -> CardView {
        let value = ValueCardView()
        value.set(
            title: type.cardTitle,
            placeholder: CardType.placeholder,
            value: type.getValue(hasDisagreements: input.hasDisagreements(), draftInfo: input.currentDraftNoticeInfo()),
            error: nil
        )

        value.tapHandler = { [unowned self] in
            switch type {
                case .disagreements:
                    self.output.openDisagreements()
                case .address:
                    self.output.openAddress()
                case .date:
                    self.output.openDate()
                case .photo:
                    self.output.openPhoto()
            }
        }

        inputViews.append(value)
        return CardView(contentView: value)
    }

    private func allPropertiesAreValid() -> Bool {
        guard
            let noticeInfo = input.currentDraftNoticeInfo(),
            input.hasDisagreements() != .none,
            noticeInfo.place != nil,
            noticeInfo.date != nil,
            noticeInfo.scheme != nil
        else {
            return false
        }

        return true
    }

    @objc private func saveButtonAction() {
        output.save()
    }
}
