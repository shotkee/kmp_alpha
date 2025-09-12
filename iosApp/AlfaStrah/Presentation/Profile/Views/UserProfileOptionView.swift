//
//  UserProfileOptionView.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 3/10/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class UserProfileOptionView: UIView {
    private enum Constants {
        static let defaultOffset: CGFloat = 18
        static let arrowSize = CGSize(width: 24, height: 24)
    }

    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()

    private var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.image = UIImage(named: "user-profile-dark-arrow")?.withRenderingMode(.alwaysTemplate)
        addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultOffset),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.heightAnchor.constraint(equalToConstant: Constants.arrowSize.height),
            arrowImageView.widthAnchor.constraint(equalToConstant: Constants.arrowSize.width),
            arrowImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Constants.defaultOffset),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultOffset)
        ])

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    func configure(title: String, color: UIColor = Style.Color.Palette.black, onTap: @escaping () -> Void) {
        self.onTap = onTap
        titleLabel.font = Style.Font.text
        titleLabel.textColor = color
        titleLabel.text = title
        arrowImageView.tintColor = color
    }

    @objc private func onTap(_ sender: Any?) {
        onTap?()
    }
}
