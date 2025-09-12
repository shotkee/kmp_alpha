//
//  FlatOnOffProtectionView.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 05.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class FlatOnOffProtectionView: UIView {
    private let titleLabel: UILabel = UILabel()
    private let subtitleLabel: UILabel = UILabel()
    private let policyButton: UIButton = UIButton()
    private let separator: UIView = UIView()

    private var showPolicyAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        [ titleLabel, subtitleLabel, policyButton, separator ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            policyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
            policyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),
            policyButton.widthAnchor.constraint(equalToConstant: 40),
            policyButton.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: policyButton.leadingAnchor, constant: -7),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: policyButton.leadingAnchor, constant: -7),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        subtitleLabel <~ Style.Label.primaryCaption1
        separator.backgroundColor = Style.Color.Palette.whiteGray
        policyButton.tintColor = Style.Color.main
        policyButton.setImage(UIImage(named: "icon-alfa-policy"), for: .normal)
        policyButton.addTarget(self, action: #selector(showPolicy), for: .touchUpInside)

        // [TODO]: Temporarily hide button since protection has no policy URL field
        policyButton.isEnabled = false
        policyButton.alpha = 0
    }

    func configure(
        mode: FlatOnOffProtectionsSectionView.Mode,
        protection: FlatOnOffProtection,
        showSeparator: Bool,
        showPolicyAction: @escaping () -> Void
    ) {
        switch mode {
            case .active:
                titleLabel <~ Style.Label.accentHeadline1
            case .upcoming:
                titleLabel <~ Style.Label.primaryHeadline1
            case .completed:
                titleLabel <~ Style.Label.tertiaryHeadline1
        }
        let from = AppLocale.shortDateString(protection.startDate)
        let to = AppLocale.shortDateString(protection.endDate)
        let format = NSLocalizedString("flat_on_off_active_period", comment: "")
        titleLabel.text = String.localizedStringWithFormat(format, from, to)

        let daysFormat = NSLocalizedString("flat_on_off_activation_period", comment: "")
        subtitleLabel.text = String.localizedStringWithFormat(daysFormat, protection.days)

        separator.isHidden = !showSeparator
        self.showPolicyAction = showPolicyAction
    }

    @objc private func showPolicy() {
        showPolicyAction?()
    }
}
