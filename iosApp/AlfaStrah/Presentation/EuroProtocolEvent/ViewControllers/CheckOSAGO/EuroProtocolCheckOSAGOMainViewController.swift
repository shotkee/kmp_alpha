//
//  EuroProtocolCheckOSAGOMainViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 12.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class EuroProtocolCheckOSAGOMainViewController: EuroProtocolBaseScrollViewController {
    private lazy var contentStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 24

        return value
    }()

    private lazy var infoLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value <~ Style.Label.secondaryText
        value.textAlignment = .left
        value.numberOfLines = 0

        return value
    }()

    private lazy var nextButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        value.setTitle(NSLocalizedString("common_continue", comment: ""), for: .normal)
        value <~ Style.RoundedButton.oldPrimaryButtonSmall

        return value
    }()

    private var inputViews: [ValueCardView] = []

    struct Output {
        let openParticipant: (_ type: OSAGOCheckParticipantType) -> Void
        let nextScreen: () -> Void
    }

    struct Input {
        var draft: () -> EuroProtocolCurrentDraftContentModel?
        var participants: () -> [OSAGOCheckParticipantType]
    }

    var output: Output!
    var input: Input!

    struct Notify {
        var infoUpdated: () -> Void
    }

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        infoUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_osago_main_title", comment: "")
        infoLabel.text = NSLocalizedString("insurance_euro_protocol_osago_main_description", comment: "")

        scrollContentView.addSubview(contentStackView)
        addBottomButtonsContent(nextButton)

        contentStackView.addArrangedSubview(infoLabel)
        input.participants().forEach { contentStackView.addArrangedSubview(createSection($0)) }

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        updateUI()
    }

    private func updateUI() {
        input.participants().enumerated().forEach {
            let offset = $0.offset
            guard inputViews.count > offset else { return }

            inputViews[offset].update(value: $0.element.getPolicyNumber(input.draft()))
            inputViews[offset].tapHandler = { [unowned self] in
                let participant = self.input.participants()[offset]
                self.output.openParticipant(participant)
            }
        }

        let areBothInsurancesFilled = input.draft()?.participantA.policy.seriesAndNumber != nil
            && input.draft()?.participantB.policy.seriesAndNumber != nil
        nextButton.isEnabled = areBothInsurancesFilled
    }

    private func createSection(_ type: OSAGOCheckParticipantType) -> UIView {
        let headerTitleLabel: UILabel = .init(frame: .zero)
        headerTitleLabel <~ Style.Label.secondaryHeadline2
        headerTitleLabel.text = type.sectionTitle

        let infoView = ValueCardView()
        infoView.set(
            title: type.cardTitle,
            placeholder: type.cardPlaceholder,
            value: type.getPolicyNumber(input.draft()),
            error: nil
        )

        inputViews.append(infoView)
        infoView.tapHandler = { [unowned self] in
            self.output.openParticipant(type)
        }

        let cardView: CardView = .init(contentView: infoView)

        let stack: UIStackView = .init(arrangedSubviews: [ headerTitleLabel, cardView ])
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 15

        return stack
    }

    @objc private func nextButtonAction() {
        output.nextScreen()
    }
}
