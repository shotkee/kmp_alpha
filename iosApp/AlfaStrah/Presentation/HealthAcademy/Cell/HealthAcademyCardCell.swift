//
//  HealthAcademyCardCell.swift
//  AlfaStrah
//
//  Created by mac on 28.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

class HealthAcademyCardCell: UICollectionViewCell {
    static let id: Reusable<HealthAcademyCardCell> = .fromClass()
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonSetup() {
        let imageBackgroundView = UIView()
        let cardView = CardView(contentView: imageBackgroundView)
		cardView.contentColor = .Background.backgroundSecondary

        imageBackgroundView.addSubview(titleLabel)
        imageBackgroundView.addSubview(iconImageView)
        contentView.addSubview(cardView)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: cardView, in: contentView) + [
                cardView.widthAnchor.constraint(equalToConstant: floor((UIScreen.main.bounds.width - 2 * 18 - 12) / 2)),
                cardView.heightAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.77),
                titleLabel.bottomAnchor.constraint(equalTo: imageBackgroundView.bottomAnchor, constant: -15),
                titleLabel.leadingAnchor.constraint(equalTo: imageBackgroundView.leadingAnchor, constant: 15),
                titleLabel.rightAnchor.constraint(equalTo: imageBackgroundView.rightAnchor, constant: -8),
                iconImageView.topAnchor.constraint(equalTo: imageBackgroundView.topAnchor, constant: 15),
                iconImageView.leadingAnchor.constraint(equalTo: imageBackgroundView.leadingAnchor, constant: 15),
                iconImageView.widthAnchor.constraint(equalToConstant: 28),
                iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor, multiplier: 1)
            ]
        )
        
        titleLabel <~ Style.Label.primaryHeadline3
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .left
    }
    
    func set(
        imageUrl: URL?,
        title: String
    ) {
		iconImageView.sd_setImage(
			with: imageUrl,
			placeholderImage: .Icons.placeholder
		)
        titleLabel.text = title
    }
}
