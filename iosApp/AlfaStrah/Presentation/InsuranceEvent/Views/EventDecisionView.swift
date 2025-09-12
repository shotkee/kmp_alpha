//
//  EventDecisionView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class EventDecisionView: UIView {
    private let stackView = UIStackView()

    private var eventDecision: EventDecision?
    private var decisionTapHandler: ((URL) -> Void)?

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
        stackView.layoutMargins = UIEdgeInsets(top: Style.Margins.defaultInsets.top, left: 0, bottom: 0, right: 0)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: stackView, in: self))
    }

    func set(eventDecision: EventDecision, decisionTapHandler: ((URL) -> Void)?) {
        self.eventDecision = eventDecision
        self.decisionTapHandler = decisionTapHandler
        let numberInfo = infoStackView(title: NSLocalizedString("insurance_event_decision_number", comment: ""),
            subtitle: eventDecision.number)
        stackView.addArrangedSubview(numberInfo)

        let sumInfo = infoStackView(title: NSLocalizedString("insurance_event_decision_sum", comment: ""),
            subtitle: eventDecision.sum.map { "\($0.amount)" + " " + $0.currency })
        stackView.addArrangedSubview(sumInfo)

        let resolutionButton = UIButton()
        resolutionButton <~ Style.Button.UnderlineMainButton(title: NSLocalizedString("insurance_event_read_decision", comment: ""))
        resolutionButton.addTarget(self, action: #selector(resolutionTap), for: .touchUpInside)
        stackView.addArrangedSubview(resolutionButton)
    }

    private func infoStackView(title: String, subtitle: String?) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.secondaryText
        titleLabel.text = title
        stackView.addArrangedSubview(titleLabel)

        if let subtitle = subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel <~ Style.Label.primaryText
            subtitleLabel.text = subtitle
            stackView.addArrangedSubview(subtitleLabel)
        }

        return stackView
    }

    @objc private func resolutionTap() {
        eventDecision.do { decisionTapHandler?($0.decisionUrl) }
    }
}
