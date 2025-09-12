//
//  QAHorizontalCollectionCell.swift
//  AlfaStrah
//
//  Created by mac on 27.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class QAHorizontalCollectionCell: UICollectionViewCell {
    static let id: Reusable<QAHorizontalCollectionCell> = .fromClass()
    private let titleLabel = UILabel()
	private let containerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonSetup() {
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
		containerView.layer.borderWidth = 1
		updateBorderColor()
		contentView.addSubview(containerView)
		containerView.edgesToSuperview()
        
        titleLabel <~ Style.Label.primarySubhead
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(titleLabel)
		titleLabel.edgesToSuperview()
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		containerView.layer.cornerRadius = contentView.bounds.height / 2
	}
    
    override var isSelected: Bool {
        didSet {
			updateBorderColor()
			containerView.backgroundColor = isSelected
				? .Background.backgroundAccent
                : .clear
            titleLabel.textColor = isSelected
				? .Text.textContrast
				: .Text.textPrimary
        }
    }

    func set(
        title: String
    ) {
        titleLabel.text = title
    }
	
	private func updateBorderColor() {
		containerView.layer.borderColor = isSelected
			? UIColor.clear.cgColor
			: UIColor.Stroke.strokeBorder.cgColor
	}
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateBorderColor()
	}
}
