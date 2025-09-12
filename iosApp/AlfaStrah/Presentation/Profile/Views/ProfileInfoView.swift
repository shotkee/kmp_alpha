//
//  ProfileInfoView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/10/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class ProfileInfoView: UIView {
    private enum Constants {
        static let defaultOffset: CGFloat = 16
        static let unconfirmedButtonSize = CGSize(width: 42, height: 42)
        static let unconfirmedImageSize = CGSize(width: 16, height: 16)
        static var unconfirmedTopOffset: CGFloat {
            defaultOffset - 0.5 * (unconfirmedButtonSize.height - unconfirmedImageSize.height)
        }
        static var unconfirmedTrailingOffset: CGFloat {
            defaultOffset - 0.5 * (unconfirmedButtonSize.width - unconfirmedImageSize.width)
        }
    }

    private let titleLabel: UILabel = .init()
    private let infoLabel: UILabel = .init()
    private let separatorView: UIView = .init()
    private var unconfirmedAction: (() -> Void)?
    private lazy var unconfirmedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "insurance-attention"), for: .normal)
        button.addTarget(self, action: #selector(unconfirmedTap(_:)), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(infoLabel)
        addSubview(separatorView)
        addSubview(unconfirmedButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        unconfirmedButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultOffset),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.defaultOffset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultOffset),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultOffset),
            infoLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -18),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            unconfirmedButton.heightAnchor.constraint(equalToConstant: Constants.unconfirmedButtonSize.height),
            unconfirmedButton.widthAnchor.constraint(equalToConstant: Constants.unconfirmedButtonSize.width),
            unconfirmedButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.unconfirmedTopOffset),
            unconfirmedButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.unconfirmedTrailingOffset)
        ])

        titleLabel <~ Style.Label.secondaryText
        infoLabel <~ Style.Label.primaryHeadline1
        infoLabel.numberOfLines = 2
        separatorView.backgroundColor = Style.Color.Palette.lightGray
        backgroundColor = .clear
    }

    func configure(_ title: String, info: String, isUnconfirmed: Bool = false, unconfirmedAction: (() -> Void)? = nil) {
        titleLabel.text = title
        infoLabel.text = info
        self.unconfirmedAction = unconfirmedAction
        infoLabel.textColor = isUnconfirmed ? Style.Color.Palette.gray : Style.Color.Palette.black
        unconfirmedButton.isHidden = !isUnconfirmed
    }

    @objc private func unconfirmedTap(_ sender: UIButton) {
        unconfirmedAction?()
    }
}
