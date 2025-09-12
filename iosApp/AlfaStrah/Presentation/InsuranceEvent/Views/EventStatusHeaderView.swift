//
//  EventStatusHeaderView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class EventStatusHeaderView: UIView {
    private let titleLabel = UILabel()
    private let actionButton = UIButton()
    private let stackView = UIStackView()

    var actionTapHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Style.Margins.defaultInsets
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: stackView, in: self))
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(actionButton)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)

        let topLine = HairLineView()
        topLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topLine)
        let bottomLine = HairLineView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLine)
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: topAnchor),
            topLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 1),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
        ])

		backgroundColor = .Background.backgroundSecondary
        titleLabel <~ Style.Label.secondaryText
        actionButton <~ Style.Button.ActionBlack(title: NSLocalizedString("common_ask_chat", comment: ""))
        actionButton.addTarget(self, action: #selector(actionTap), for: .touchUpInside)
        titleLabel.text = NSLocalizedString("insurance_event_status", comment: "")
    }

    @objc private func actionTap() {
        actionTapHandler?()
    }
}
