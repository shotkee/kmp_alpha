//
//  CardButton.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 15.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

/// В дизайн-системе – один из вариантов CardButton, в котором иконка находится слева от текста
class CardHorizontalButton: HighlightableCardView {
    private let contentInsets: UIEdgeInsets = .init(
        top: 15, left: 15, bottom: 15, right: 15
    )

    private let iconImageView: UIImageView = .init()
    private let titleLabel: UILabel = .init()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 9
        return stack
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        stackView.isUserInteractionEnabled = false

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: stackView, in: self, margins: contentInsets) +
            [
                iconImageView.widthAnchor.constraint(equalToConstant: 24),
                iconImageView.heightAnchor.constraint(equalToConstant: 24)
            ]
        )

        titleLabel <~ Style.Label.primaryText

        addTarget(self, action: #selector(viewTap), for: .touchUpInside)
    }

    func set(
        title: String,
        icon: UIImage?
    ) {
        iconImageView.image = icon
        titleLabel.text = title
    }

    var tapHandler: (() -> Void)?

    @objc private func viewTap() {
        tapHandler?()
    }
}
