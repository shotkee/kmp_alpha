//
//  QATableCell.swift
//  AlfaStrah
//
//  Created by mac on 27.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class QATableCell: UITableViewCell {
    static let id: Reusable<QATableCell> = .fromClass()
    private var titleLabel = UILabel()
    private var imageArrowView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commonSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        fatalError("Xibs and storyboards are not supported")
    }
    
    private func commonSetup() {
        selectionStyle = .none
        backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        let whiteBackgroundView = UIView()
        let cardView = CardView(contentView: whiteBackgroundView)
        cardView.isUserInteractionEnabled = false
        
		imageArrowView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)

		whiteBackgroundView.backgroundColor = .Background.backgroundSecondary
        whiteBackgroundView.clipsToBounds = false
        whiteBackgroundView.addSubview(titleLabel)
        whiteBackgroundView.addSubview(imageArrowView)
        contentView.addSubview(cardView)

        imageArrowView.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
			NSLayoutConstraint.fill(
				view: cardView,
				in: contentView,
				margins: .init(top: 6, left: 18, bottom: 6, right: 18)
			) + [
                titleLabel.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -16),
                titleLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 16),
                imageArrowView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16),
                imageArrowView.centerYAnchor.constraint(equalTo: whiteBackgroundView.centerYAnchor),
                imageArrowView.widthAnchor.constraint(equalToConstant: 24),
                imageArrowView.heightAnchor.constraint(equalToConstant: 24),
                titleLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: imageArrowView.leadingAnchor, constant: -9)
            ]
        )
        
        titleLabel <~ Style.Label.primaryText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
    }
    
    func set(title: String) {
        titleLabel.text = title
    }
}
