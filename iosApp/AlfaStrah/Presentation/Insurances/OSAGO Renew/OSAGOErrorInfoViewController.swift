//
//  OSAGOFailureInfoViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 25.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class OSAGOErrorInfoViewController: ViewController {
    private lazy var scrollView: UIScrollView = .init(frame: .zero)
    private lazy var rootView: UIView = .init(frame: .zero)

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16

        return stack
    }()

    private lazy var infoLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ Style.Label.secondarySubhead
        label.numberOfLines = 0

        return label
    }()

    private lazy var prolongButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button <~ Style.Button.ActionRedRounded(title: NSLocalizedString("osago_prolongation_button_title", comment: ""))
        button.addTarget(self, action: #selector(prolongationAction), for: .touchUpInside)
        button.isEnabled = false

        return button
    }()

    struct Output {
        let editParticipantTap: (OsagoProlongationParticipant) -> Void
        let prolongationTap: () -> Void
    }

    struct Input {
        let viewModel: OSAGORenewViewModel
    }

    struct Notify {
        var infoUpdated: () -> Void
    }

    var output: Output!
    var input: Input!

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        infoUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        view.addSubview(scrollView)
        view.addSubview(prolongButton)

        scrollView.addSubview(rootView)
        rootView.addSubview(contentStackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        rootView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        prolongButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            rootView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            rootView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            rootView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            rootView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rootView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            contentStackView.topAnchor.constraint(equalTo: rootView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            contentStackView.rightAnchor.constraint(equalTo: rootView.rightAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 18),

            prolongButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
            prolongButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            prolongButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            prolongButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupUI() {
        title = NSLocalizedString("insurance_renew_osago_title", comment: "")
        view.backgroundColor = Style.Color.Palette.white

        infoLabel.text = input.viewModel.originalInfo.description
        updateUI()
    }

    private func updateUI() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStackView.addArrangedSubview(infoLabel)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12

        input.viewModel.editedInfo.participants.forEach { stackView.addArrangedSubview(createCardView(with: $0)) }

        contentStackView.addArrangedSubview(stackView)
        prolongButton.isEnabled = input.viewModel.editedInfo.isReady
    }

    private func createCardView(with data: OsagoProlongationParticipant) -> CardView {
        let infoView: CommonErrorInfoView = .init()

        infoView.set(
            title: data.description,
            note: data.title,
            errorType: data.hasError
                ? !data.isReady ? .hasErrorText(data.errorText) : .hasError
                : .noError,
            icon: data.hasError ? "ico-arrow" : nil
        )

        infoView.tapHandler = { [weak self] in
            guard data.hasError else { return }

            self?.output.editParticipantTap(data)
        }

        return CardView(contentView: infoView)
    }

    // MARK: - Button Actions

    @objc private func prolongationAction() {
        output.prolongationTap()
    }
}
