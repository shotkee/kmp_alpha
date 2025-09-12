//
//  MessageChatBotCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 24.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

typealias KeyboardButtonIndex = Int

protocol MessageChatBotCellDelegate: AnyObject {
    func select(cell: MessageChatBotCell, button: KeyboardButton, buttonIndex: KeyboardButtonIndex, message: Message)
}

class MessageChatBotCell: MessageBubbleCell {
	static let reuseIdentifier: Reusable<MessageChatBotCell> = .fromClass()
    private var answerButtons: [UIView] = []
    private var keyboardButtonConfigs: [KeyboardButton] = []
    weak var delegate: MessageChatBotCellDelegate?
    
    var isEnabled: Bool = false {
        didSet {
            guard isEnabled != oldValue else { return }

            update()
        }
    }

    private let stackView: UIStackView = UIStackView()
    private lazy var activityIndicatorView: ActivityIndicatorView = Self.createActivityIndicatorView()

    override func setup() {
        super.setup()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 6

        bubbleView.addSubview(stackView)
        // don't clip shadows by view edges
        bubbleView.createsMaskLayer = false
        bubbleView.update()
    }

    override func update() {
        super.update()

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        answerButtons = []
        keyboardButtonConfigs = []
        guard let buttons = message?.getKeyboard()?.getButtons() else { return }

        buttons.flatMap { $0 }.forEach { button in
            keyboardButtonConfigs.append(button)

            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center

            let buttonView = UIView()
            answerButtons.append(buttonView)
            if isEnabled {
                buttonView.backgroundColor = .Background.backgroundSecondary
                label <~ Style.Label.primaryText
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonTap(_:)))
                buttonView.addGestureRecognizer(tapGestureRecognizer)
            } else {
                buttonView.backgroundColor = .States.backgroundSecondaryDisabled
                label <~ Style.Label.secondaryText
            }
            buttonView.addSubview(label)
            NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: label, in: buttonView, margins: Style.Margins.defaultInsets))
            label.text = button.getText()

            let cardView = CardView(contentView: buttonView)
            cardView.cornerRadius = 22
            if isEnabled {
                cardView.contentColor = .Background.backgroundSecondary
                cardView.highlightedColor = .Background.backgroundSecondary
            } else {
                cardView.contentColor = .States.backgroundSecondaryDisabled
            }
            stackView.addArrangedSubview(cardView)
        }

        stopSpinner()
    }

    override func dynamicStylize() {
        super.dynamicStylize()

        bubbleView.backgroundColor = .clear
    }

    // MARK: - Layout

    override func layoutContent() {
        super.layoutContent()

        let constraints = NSLayoutConstraint.fill(
            view: stackView,
            in: bubbleView,
            margins: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        )
        add(constraints: constraints)
    }

    // MARK: - Actions

    @objc private func buttonTap(_ sender: UITapGestureRecognizer) {
        guard
            let buttonView = sender.view,
            let indexOfButton = answerButtons.firstIndex(of: buttonView),
            let keyboardButtonConfig = keyboardButtonConfigs[safe: indexOfButton],
            let message = message
        else { return }

        delegate?.select(cell: self, button: keyboardButtonConfig, buttonIndex: indexOfButton, message: message)
    }

    func startSpinner(keyboardButtonIndex: Int) {
        guard let buttonView = answerButtons[safe: keyboardButtonIndex]
        else { return }

        Self.startSpinner(activityIndicatorView, on: buttonView)
        contentView.isUserInteractionEnabled = false
    }

    func stopSpinner() {
        activityIndicatorView.isHidden = true
        contentView.isUserInteractionEnabled = true

        answerButtons.forEach {
            Self.setButtonLabelVisible($0, true)
        }
    }

    private static func createActivityIndicatorView() -> ActivityIndicatorView {
        let activityIndicatorView = ActivityIndicatorView(frame: .zero)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 36),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 36),
        ])

        return activityIndicatorView
    }

    private static func startSpinner(_ activityIndicatorView: ActivityIndicatorView, on buttonView: UIView) {
        activityIndicatorView.removeFromSuperview()
        buttonView.addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
        ])

        activityIndicatorView.isHidden = false
        activityIndicatorView.animating = true

        Self.setButtonLabelVisible(buttonView, false)
    }

    private static func setButtonLabelVisible(_ buttonView: UIView, _ showLabel: Bool) {
        (buttonView.subviews.first as? UILabel)?.isHidden = !showLabel
    }
}
