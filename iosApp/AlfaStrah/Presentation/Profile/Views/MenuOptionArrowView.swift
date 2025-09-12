//
//  MenuOptionArrowView.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 3/10/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class MenuOptionArrowView: UIView {
    private enum Constants {
        static let defaultOffset: CGFloat = 18
        static let arrowSize = CGSize(width: 24, height: 24)
        static let marginOffset: CGFloat = 15
    }

    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let logoImageView = UIImageView()

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
        backgroundColor = .Background.backgroundSecondary
        clipsToBounds = false
        
        titleLabel.font = Style.Font.text
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        arrowImageView.image = UIImage.Icons.arrow
        arrowImageView.tintColor = .Icons.iconSecondary
        addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        logoImageView.contentMode = .center
        logoImageView.tintColor = .Icons.iconAccent
        addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 6),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.heightAnchor.constraint(equalToConstant: Constants.arrowSize.height),
            arrowImageView.widthAnchor.constraint(equalToConstant: Constants.arrowSize.width),
            arrowImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Constants.defaultOffset),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultOffset),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: Constants.arrowSize.height),
            logoImageView.widthAnchor.constraint(equalToConstant: Constants.arrowSize.width),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.marginOffset)
        ])

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    func configure(logoImage: UIImage?, title: String, color: UIColor = .Text.textPrimary, onTap: @escaping () -> Void) {
        self.onTap = onTap
        titleLabel.textColor = color
        titleLabel.text = title
        logoImageView.image = logoImage
    }
    
    @objc private func onTap(_ sender: Any?) {
        onTap?()
    }
}
