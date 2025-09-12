//
//  CardVerticalButton.swift
//  AlfaStrah
//
//  Created by Darya Viter on 09.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

/// В дизайн-системе – один из вариантов CardButton, в котором иконка находится сверху от текста.
/// [Figma](https://www.figma.com/file/tKxXq2M8ztUCQdnAq8TguY/Alfastrahovanie-Design-System?node-id=1389%3A89)
class CardVerticalButton: HighlightableCardView {
    private let contentInsets: UIEdgeInsets = .init(
        top: 15, left: 15, bottom: 15, right: 15
    )

    private let iconImageView: UIImageView = .init()
    private let titleLabel: UILabel = .init()

    var tapHandler: (() -> Void)?

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 3
        return stack
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

    // MARK: Builders

    func set(
        title: String,
        icon: UIImage?
    ) {
        iconImageView.image = icon
        titleLabel.text = title
    }

    private func commonSetup() {
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)

        addSubview(stackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: stackView, in: self, margins: contentInsets) +
                [
                    iconImageView.widthAnchor.constraint(equalToConstant: 24),
                    iconImageView.heightAnchor.constraint(equalToConstant: 24)
                ]
        )

        titleLabel <~ Style.Label.primaryText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        addTarget(self, action: #selector(viewTap), for: .touchUpInside)
    }

    @objc private func viewTap() {
        tapHandler?()
    }
}
