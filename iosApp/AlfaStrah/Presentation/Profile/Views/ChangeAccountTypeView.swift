//
// ChangeAccountTypeView
// AlfaStrah
//
// Created by Амир Нуриев on 07 March 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import UIKit

class ChangeAccountTypeView: UIView {
    private enum Constants {
        static let defaultOffset: CGFloat = 18
        static let defaultInteritemOffset: CGFloat = 6
        static let cornerRadius: CGFloat = 12
        static let minimumInfoLabelWidth: CGFloat = 184
    }

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()

    private lazy var changeButton: RoundEdgeButton = {
        let button = RoundEdgeButton()
        button.setTitle(NSLocalizedString("user_profile_change", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(changeTap(_:)), for: .touchUpInside)
        return button
    }()

    private var accountType: AccountType?
    private var changeAccountType: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        backgroundColor = .Background.backgroundSecondary

        clipsToBounds = false
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(changeButton)
        changeButton.translatesAutoresizingMaskIntoConstraints = false

        infoLabel <~ Style.Label.primaryText
        infoLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        changeButton <~ Style.RoundedButton.redBordered

        var constraints: [NSLayoutConstraint] = [
            changeButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.defaultOffset),
            changeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.defaultOffset),
            changeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultOffset),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultOffset),
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.defaultOffset),
            bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: Constants.defaultOffset)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func configure(_ accountType: AccountType, changeAccountType: (() -> Void)? = nil) {
        if let changeAccountType = changeAccountType {
            self.changeAccountType = changeAccountType
        }
        self.accountType = accountType
        let text: String
        switch accountType {
            case .alfaStrah:
                text = String(
                    format: NSLocalizedString("user_profile_move_to_account", comment: ""),
                    NSLocalizedString("user_profile_alfa_strah_life", comment: "")
                )
            case .alfaLife:
                text = String(
                    format: NSLocalizedString("user_profile_move_to_account", comment: ""),
                    NSLocalizedString("user_profile_alfa_strah", comment: "")
                )
        }
        infoLabel.attributedText = makeAttributedInfoString(text)
    }

    private func makeAttributedInfoString(_ text: String) -> NSAttributedString {
        var attributes = Style.TextAttributes.normalText
        attributes[.paragraphStyle] = Style.Paragraph.withLineHeight(18)
        return NSAttributedString(string: text, attributes: attributes)
    }

    @objc private func changeTap(_ sender: UIButton) {
        changeAccountType?()
    }
}
