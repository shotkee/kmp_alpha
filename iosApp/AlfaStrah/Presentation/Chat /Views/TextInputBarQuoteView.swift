//
//  TextInputBarQuoteView.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 29.11.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import UIKit

class TextInputBarQuoteView: UIView {
    private let leftBar: UIView = {
        let view = UIView()
        view.backgroundColor = Style.Color.Palette.red
        view.layer.cornerRadius = 1.5
        return view
    }()

    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label <~ Style.Label.ColoredLabel(
            titleColor: Style.Color.Palette.darkGray,
            font: Style.Font.caption1
        )
        label.numberOfLines = 1
        return label
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label <~ Style.Label.primaryText
        label.numberOfLines = 1
        return label
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(
            UIImage.tintedImage(
                withName: "ico-close",
                tintColor: Style.Color.Palette.darkGray
            ),
            for: .normal
        )
        button.setImage(
            UIImage.tintedImage(
                withName: "ico-close",
                tintColor: Style.Color.Palette.lightGray
            ),
            for: [.selected, .highlighted]
        )
        return button
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
        addSubview(labelsStackView)
        addSubview(cancelButton)

        labelsStackView.addArrangedSubview(authorLabel)
        labelsStackView.addArrangedSubview(textLabel)

        [leftBar, labelsStackView, authorLabel, textLabel, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let views: [String: Any] = [
            "leftBar": leftBar,
            "labelsStackView": labelsStackView,
            "authorLabel": authorLabel,
            "textLabel": textLabel,
            "closeButton": cancelButton
        ]

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-18-[leftBar(3)]-9-[labelsStackView]-21-[closeButton(24)]-18-|",
            options: [.alignAllCenterY],
            metrics: nil,
            views: views
        ))
        NSLayoutConstraint.fixHeight(view: leftBar, constant: 30)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-6-[labelsStackView(\(15 + 18))]",
            metrics: nil,
            views: views
        ))
        NSLayoutConstraint.fixHeight(view: cancelButton, constant: 24)

        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
    }

    // MARK: Actions

    var cancelButtonHandler: (() -> Void)?

    @objc private func onCancelButton() {
        cancelButtonHandler?()
    }

    // MARK: API

    func set(
        author: String,
        messageText: String
    ) {
        self.authorLabel.text = author
        self.textLabel.text = messageText
    }
}
