//
//  InsuranceProductTagCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 26.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class InsuranceProductTagCollectionViewCell: UICollectionViewCell {
    private var titleLabel = UILabel()
    
    static let id: Reusable<InsuranceProductTagCollectionViewCell> = .fromClass()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView?.isOpaque = true
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = true
        contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 6
        setupTitleLabel()
    }
    
    private func setupTitleLabel(){
        titleLabel.font = Style.Font.text
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
		titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
		
    }
		
	func updateColors(insuranceProductTag: InsuranceProductTag?) {
		guard let insuranceProductTag
		else { return }
		let hexColorText = insuranceProductTag.titleColorThemed?.color(for: traitCollection.userInterfaceStyle)
			?? .from(hex: insuranceProductTag.titleColor)
		var hexColorBackground = insuranceProductTag.backgroundColorThemed?.color(for: traitCollection.userInterfaceStyle)
			?? .from(hex: insuranceProductTag.backgroundColor)
		
		contentView.backgroundColor = hexColorBackground
		titleLabel.textColor = hexColorText
	}
	
}

extension InsuranceProductTagCollectionViewCell {
	func configure(insuranceProductTag: InsuranceProductTag, maxWidth: CGFloat) {
		updateColors(insuranceProductTag: insuranceProductTag)
		titleLabel.text = insuranceProductTag.title
		contentView.width(max: maxWidth)
    }
}
