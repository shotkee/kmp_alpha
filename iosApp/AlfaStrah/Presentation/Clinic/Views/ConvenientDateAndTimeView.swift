//
//  ConvenientDateAndTimeView.swift
//  AlfaStrah
//
//  Created by Darya Viter on 30.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ConvenientDateAndTimeView: UIView {
    private(set) var date: Date? = nil {
        didSet {
            if let date = date {
                convenientDateCard.set(
                    title: NSLocalizedString("clinic_appointment_convenient_date_card_text", comment: ""),
                    placeholder: "",
                    value: AppLocale.dateString(date),
                    error: nil,
                    showSeparator: true
                )
            } else {
                convenientDateCard.set(
                    title: "",
                    placeholder: NSLocalizedString("clinic_appointment_convenient_date_card_text", comment: ""),
                    value: nil,
                    error: nil,
                    showSeparator: true
                )
            }
        }
    }

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumIntegerDigits = 2
        formatter.minimumIntegerDigits = 2
        return formatter
    }()

    private(set) var time: (Int, Int)? = nil {
        didSet {
            let displayValue: String? = {
                guard
                    let time = time,
                    let startHours = formatter.string(from: NSNumber(value: time.0)),
                    let endHours = formatter.string(from: NSNumber(value: time.1))
                else {
                    return nil
                }
                return "\(startHours):00 — \(endHours):00"
            }()
            let title = displayValue == nil ? "" : NSLocalizedString("clinic_appointment_convenient_time_card_text", comment: "")
            convenientTimeCard.set(
                title: title,
                placeholder: NSLocalizedString("clinic_appointment_convenient_time_card_text", comment: ""),
                value: displayValue,
                error: nil,
                showSeparator: true
            )
        }
    }

    var deleteHandler: (() -> Void)?

    // MARK: UI

    private lazy var commonStack: UIStackView = {
        let commonStack = UIStackView()
        commonStack.accessibilityIdentifier = #function
        commonStack.axis = .horizontal
        commonStack.alignment = .center
        commonStack.spacing = 15
        return commonStack
    }()
    private lazy var dateCardsStack: UIStackView = {
        let dateCardsStack = UIStackView()
        dateCardsStack.accessibilityIdentifier = #function
        dateCardsStack.axis = .vertical
        return dateCardsStack
    }()
    private lazy var convenientDateCard: SmallValueCardView = {
        let convenientDateCard = SmallValueCardView()
        convenientDateCard.accessibilityIdentifier = #function
        convenientDateCard.tapHandler = { self.dateCatcher? { [weak self] in self?.date = $0 } }
        convenientDateCard.set(
            title: "",
            placeholder: NSLocalizedString("clinic_appointment_convenient_date_card_text", comment: ""),
            value: nil,
            error: nil,
            showSeparator: true
        )
        return convenientDateCard
    }()
    private lazy var convenientTimeCard: SmallValueCardView = {
        let convenientTimeCard = SmallValueCardView()
        convenientTimeCard.set(
            title: "",
            placeholder: NSLocalizedString("clinic_appointment_convenient_time_card_text", comment: ""),
            value: nil,
            error: nil,
            showSeparator: true
        )
        convenientTimeCard.tapHandler = { self.timeCatcher? { [weak self] in self?.time = $0 } }

        return convenientTimeCard
    }()
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
		button.setImage(.Icons.crossSmall.tintedImage(withColor: .Icons.iconAccent), for: .normal)
        button.layer.cornerRadius = 12
		button.backgroundColor = .clear
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 36),
            button.widthAnchor.constraint(equalToConstant: 36),
        ])

        return button
    }()

    var dateCatcher: ((_ completion: @escaping (Date) -> Void) -> Void)?
    var timeCatcher: ((_ completion: @escaping ((Int, Int)) -> Void) -> Void)?

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

    private func commonSetup() {
        addSubview(commonStack)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: commonStack, in: self))

        dateCardsStack.addArrangedSubview(convenientDateCard)
        dateCardsStack.addArrangedSubview(convenientTimeCard)
        commonStack.addArrangedSubview(CardView(contentView: dateCardsStack))
        commonStack.addArrangedSubview(deleteButton)
    }

    func setButtonHiddenState(_ isHidden: Bool) {
        deleteButton.isHidden = isHidden
    }

    @objc private func deleteTapped() {
        deleteHandler?()
    }
}
