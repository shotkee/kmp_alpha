//
//  HealthAcademyListCell.swift
//  AlfaStrah
//
//  Created by mac on 01.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import SDWebImage
import Legacy

class HealthAcademyListCell: UICollectionViewCell {
    static let id: Reusable<HealthAcademyListCell> = .fromClass()
    private var labelView = UILabel()
	private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonSetup() {
        lazy var stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fill
            stack.alignment = .center
            stack.spacing = 12
            return stack
        }()

        let bottomLineView = UIView()
        contentView.addSubview(bottomLineView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
		bottomLineView.backgroundColor = .Stroke.divider
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 36),
            bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomLineView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bottomLineView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            bottomLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(labelView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        labelView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
			stackView.bottomAnchor.constraint(equalTo: bottomLineView.topAnchor, constant: -12),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			stackView.heightAnchor.constraint(greaterThanOrEqualTo: labelView.heightAnchor, multiplier: 1),
			stackView.heightAnchor.constraint(greaterThanOrEqualTo: iconView.heightAnchor, multiplier: 1),
			iconView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			iconView.widthAnchor.constraint(equalToConstant: 28),
			iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor, multiplier: 1)
		])
        
        labelView.lineBreakMode = .byTruncatingTail
        labelView <~ Style.Label.primaryText
        labelView.numberOfLines = 2
        labelView.textAlignment = .left
    }

    func set(
        imageUrl: URL?,
        title: String
    ) {
		iconView.sd_setImage(
			with: imageUrl,
			placeholderImage: .Icons.placeholder
		)
        labelView.text = title
    }
}
