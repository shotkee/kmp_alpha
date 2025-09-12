//
//  FlatOnOffProtectionsSectionView.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 05.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class FlatOnOffProtectionsSectionView: UIView {
    private let headerLabel: UILabel = UILabel()
    private let protectionsStackView: UIStackView = UIStackView()

    enum Mode {
        case active
        case upcoming
        case completed
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        [ headerLabel, protectionsStackView ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            headerLabel.bottomAnchor.constraint(equalTo: protectionsStackView.topAnchor, constant: -9),
            protectionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            protectionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            protectionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        backgroundColor = Style.Color.Palette.white
        protectionsStackView.axis = .vertical
        headerLabel <~ Style.Label.primaryText
    }

    func configure(mode: Mode, protections: [FlatOnOffProtection], showPolicyAction: @escaping (URL) -> Void) {
        protectionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        switch mode {
            case .active:
                headerLabel.text = NSLocalizedString("flat_on_off_activation_active", comment: "")
            case .upcoming:
                headerLabel.text = NSLocalizedString("flat_on_off_activation_upcoming", comment: "")
            case .completed:
                headerLabel.text = NSLocalizedString("flat_on_off_activation_completed", comment: "")
        }

        for (index, protection) in protections.enumerated() {
            let view = FlatOnOffProtectionView()
            view.configure(mode: mode, protection: protection, showSeparator: index < protections.count - 1) {
                // [TODO]: Temporarily remove action from button
                //         Waiting for policy URL in protection model
                //         showPolicyAction(protection.policyURL)
            }
            protectionsStackView.addArrangedSubview(view)
        }
    }
}
