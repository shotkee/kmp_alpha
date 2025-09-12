//
//  MessageTextCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class MessageTextCell: MessageBubbleCell {
    static let myCell: Reusable<MessageTextCell> = .class(id: "MyMessageTextCell")
    static let operatorCell: Reusable<MessageTextCell> = .class(id: "YourMessageTextCell")

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.spacing = 7
        return stack
    }()

    private let quoteView = QuoteView()
    private let messageTextLabel: LinkLabel = LinkLabel()

    override func prepareForReuse() {
        super.prepareForReuse()

        quoteView.isHidden = true
        messageTextLabel.attributedText = nil
    }

    override func setup() {
        super.setup()

        accessibilityIdentifier = "messageTextCell"

        #if DEBUG
        bubbleView.accessibilityIdentifier = "bubbleView"
        stackView.accessibilityIdentifier = "stackView"
        quoteView.accessibilityIdentifier = "quoteView"
        messageTextLabel.accessibilityIdentifier = "messageTextLabel"
        #endif

        doNotTranslateAutoresizingMaskIntoConstraints(
            stackView, quoteView, messageTextLabel
        )

        messageTextLabel.numberOfLines = 0

        stackView.addArrangedSubview(quoteView)
        stackView.addArrangedSubview(messageTextLabel)
        bubbleView.addSubview(stackView)

        useIntrinsicContentSize(for: quoteView)
        useIntrinsicContentSize(for: messageTextLabel)
        useIntrinsicContentSize(for: stackView)
    }

    override func update() {
        super.update()
        
        messageTextLabel.linkTapAction = linkAction
        
        guard let message
        else {
            messageTextLabel.text = ""
            return
        }

        messageTextLabel.text = message.getDisplayedText()
        
        if let messageQuote = message.getQuote() {
            quoteView.isHidden = false
            quoteView.set(
                author: messageQuote.getSenderName(),
                messageText: messageQuote.getMessageText()
            )
        } else {
            quoteView.isHidden = true
        }
    }

    override func dynamicStylize() {
        super.dynamicStylize()

        messageTextLabel.textAlignment = isMine ? .right : .left
        messageTextLabel.textAttributes = isMine
            ? Style.TextAttributes.chatTextVisitor
            : Style.TextAttributes.chatTextOperator
        messageTextLabel.linkAttributes = Style.TextAttributes.link
        messageTextLabel.selectedLinkAttributes = Style.TextAttributes.chatLinkSelected
        
        quoteView.stylize(
            color: isMine
                ? Style.TextAttributes.chatTextVisitorColor
                : Style.TextAttributes.chatTextOperatorColor
        )
    }

    // MARK: - Layout

    override class var height: CGFloat { UITableView.automaticDimension }
    override class var estimatedHeight: CGFloat { 100 }

    override func layoutContent() {
        super.layoutContent()

        useIntrinsicContentSize(for: messageTextLabel)

        let constraints = NSLayoutConstraint.fill(view: stackView, in: bubbleView,
            margins: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))

        add(constraints: constraints)
    }
}

private class QuoteView: UIView {
    private let leftBar: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1.5
        return view
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()

    // MARK: Init

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        self.layoutMargins = .zero

        addSubview(leftBar)
        addSubview(authorLabel)
        addSubview(textLabel)

        doNotTranslateAutoresizingMaskIntoConstraints(
            leftBar, authorLabel, textLabel
        )

        useIntrinsicContentHeight(for: authorLabel)
        useIntrinsicContentHeight(for: textLabel)

        #if DEBUG
        authorLabel.accessibilityLabel = "Quote.authorLabel"
        textLabel.accessibilityLabel = "Quote.textLabel"
        leftBar.accessibilityLabel = "Quote.leftBar"
        #endif

        NSLayoutConstraint.activate([
            leftBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
            leftBar.widthAnchor.constraint(equalToConstant: 3),
            leftBar.trailingAnchor.constraint(equalTo: authorLabel.leadingAnchor, constant: -9),
            leftBar.trailingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -9),
            authorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            leftBar.topAnchor.constraint(equalTo: self.topAnchor),
            leftBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),

            authorLabel.topAnchor.constraint(equalTo: self.topAnchor),
            authorLabel.heightAnchor.constraint(equalToConstant: 15),
            authorLabel.bottomAnchor.constraint(equalTo: textLabel.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 15),
        ])
    }

    func set(
        author: String?,
        messageText: String?
    ) {
        authorLabel.text = author
        textLabel.text = messageText
    }
    
    func stylize(color: UIColor) {
        leftBar.backgroundColor = color
        authorLabel <~ Style.Label.ColoredLabel(
            titleColor: color,
            font: Style.Font.caption1
        )
        textLabel <~ Style.Label.ColoredLabel(
            titleColor: color,
            font: Style.Font.caption1
        )
    }
}

private func useIntrinsicContentSize(for view: UIView) {
    useIntrinsicContentWidth(for: view)
    useIntrinsicContentHeight(for: view)
}
private func useIntrinsicContentWidth(for view: UIView) {
    view.setContentHuggingPriority(.required, for: .horizontal)
    view.setContentCompressionResistancePriority(.required, for: .horizontal)
}
private func useIntrinsicContentHeight(for view: UIView) {
    view.setContentHuggingPriority(.required, for: .vertical)
    view.setContentCompressionResistancePriority(.required, for: .vertical)
}
