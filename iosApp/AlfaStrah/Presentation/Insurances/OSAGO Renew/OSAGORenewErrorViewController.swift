//
//  OSAGORenewErrorViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 19.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class OSAGORenewErrorViewController: ViewController {
    enum StyleButtons {
        case oneButton(mainTitle: String)
        case twoButtons(mainTitle: String, minorTitle: String)
    }

    private lazy var rootInfoStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.axis = .vertical
        stack.spacing = 25

        return stack
    }()

    private lazy var titleStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .center
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 6

        return stack
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 6

        return stack
    }()

    private lazy var iconImageView: UIImageView = .init(frame: .zero)

    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ Style.Label.primaryHeadline1
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ Style.Label.secondarySubhead
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var mainButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(self.mainButtonAction), for: .touchUpInside)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var minorButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(self.minorButtonAction), for: .touchUpInside)
        button <~ Style.RoundedButton.redTitle

        return button
    }()

    private lazy var textView: NoteView = {
        let textView: NoteView = .init(frame: .zero)
        textView.isEnabled = false
        textView.textView.textAlignment = .center
		textView.textView.textColor = .Text.textSecondary

        return textView
    }()

    struct Output {
        let minorButtonHandler: (() -> Void)?
        let mainButtonHandler: () -> Void
    }

    var output: Output!

    private var buttonsStyle: StyleButtons = .oneButton(mainTitle: "")
    private var errorsInfo: [String] = []
    private var icon: String = ""
    private var titleText: String = ""
    private var subTitle: String = ""

    private func setButtonsStyle(_ type: StyleButtons) {
        buttonsStyle = type
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
    }

    private func commonSetup() {
		view.backgroundColor = .Background.backgroundContent
        view.addSubview(rootInfoStackView)
        view.addSubview(buttonsStackView)
        view.addSubview(textView)

        rootInfoStackView.addArrangedSubview(iconImageView)
        rootInfoStackView.addArrangedSubview(titleStackView)

        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)

        rootInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rootInfoStackView.centerYAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor, constant: -100),
            rootInfoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rootInfoStackView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 18),
            rootInfoStackView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor, constant: -18),
            buttonsStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            buttonsStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            textView.bottomAnchor.constraint(lessThanOrEqualTo: buttonsStackView.topAnchor, constant: -50),
            textView.topAnchor.constraint(equalTo: rootInfoStackView.bottomAnchor, constant: 25),
            mainButton.heightAnchor.constraint(equalToConstant: 48),
            minorButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        updateButtonsUI()
    }

    private func updateButtonsUI() {
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        switch buttonsStyle {
            case .oneButton:
                buttonsStackView.addArrangedSubview(mainButton)

            case .twoButtons:
                buttonsStackView.addArrangedSubview(minorButton)
                buttonsStackView.addArrangedSubview(mainButton)
        }
    }

    private func updateUI() {
        iconImageView.image = UIImage(named: icon)

        titleLabel.text = titleText
        subTitleLabel.text = subTitle

        switch buttonsStyle {
            case .oneButton(let mainTitle):
                mainButton.setTitle(mainTitle, for: .normal)
            case .twoButtons(let mainTitle, let minorTitle):
                mainButton.setTitle(mainTitle, for: .normal)
                minorButton.setTitle(minorTitle, for: .normal)
        }

        let errorsString = errorsInfo.joined(separator: "\n")
        textView.text = errorsString
        textView.textView.setContentOffset(.zero, animated: true)
    }

    func set(
        icon: String,
        title: String,
        subTitle: String,
        errorsInfo: [String] = [],
        buttonStyle: StyleButtons
    ) {
        self.icon = icon
        self.titleText = title
        self.subTitle = subTitle
        self.errorsInfo = errorsInfo

        setButtonsStyle(buttonStyle)
        updateUI()
    }

    // MARK: IBActions

    @objc private func mainButtonAction() {
        output.mainButtonHandler()
    }

    @objc private func minorButtonAction() {
        output.minorButtonHandler?()
    }
}
