//
//  StarsScoreWidgetCell.swift
//  AlfaStrah
//
//  Created by vit on 27.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class StarsScoreWidgetCell: MessageBubbleCell {
	static let id: Reusable<StarsScoreWidgetCell> = .fromClass()

	private let containerView = UIView()
	private let cardView = CardView()
	private let ratingStackView = UIStackView()
	private var starButtons: [UIButton] = []
	
	private let rateTitleLabel = UILabel()
	
	var ratingSelectedCallback: ((Int) -> Void)?
	
	var selectedRating: Int = 0 {
		didSet {
			guard selectedRating != oldValue
			else { return }

			updateUI()
			
			self.ratingSelectedCallback?(selectedRating)
		}
	}
		
	override func setup() {
		super.setup()
		
		clearStyle()
		
		cardView.set(content: containerView)
		bubbleView.addSubview(cardView)
		
		bubbleView.createsMaskLayer = false
		bubbleView.layer.masksToBounds = false
		bubbleView.clipsToBounds = false
		
		containerView.addSubview(rateTitleLabel)
		rateTitleLabel.numberOfLines = 0
		
		containerView.addSubview(ratingStackView)
		
		setupStarsView()
	}
	
	override func update() {
		super.update()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
	}
	
	override func dynamicStylize() {
		super.dynamicStylize()
		
		bubbleView.backgroundColor = .clear
	}
	
	override func staticStylize() {
		super.staticStylize()
				
		containerView.backgroundColor = .Background.backgroundSecondary
		cardView.contentColor = .Background.backgroundSecondary
		cardView.cornerRadius = 16
		
		rateTitleLabel <~ Style.Label.primarySubhead
		rateTitleLabel.textAlignment = .center
		
		rateTitleLabel.text = NSLocalizedString("chat_rate_widget_title", comment: "")
	}

	// MARK: - Layout
	/// Exact height of the cell.
	class override var height: CGFloat { UITableView.automaticDimension }

	/// Estimated height of the cell.
	class override var estimatedHeight: CGFloat { 102 }

	override func layoutContent() {
		super.layoutContent()
		
		containerView.height(102)
		containerView.width(264)
		cardView.edgesToSuperview()
		
		rateTitleLabel.topToSuperview(offset: 16)
		rateTitleLabel.leadingToSuperview(offset: 12)
		rateTitleLabel.trailingToSuperview(offset: 12)
		
		ratingStackView.centerXToSuperview()
		ratingStackView.bottomToSuperview(offset: -12)
	}
	
	private func setupStarsView() {
		ratingStackView.isLayoutMarginsRelativeArrangement = true
		ratingStackView.layoutMargins = .zero
		ratingStackView.alignment = .fill
		ratingStackView.distribution = .fill
		ratingStackView.axis = .horizontal
		ratingStackView.spacing = 0
		ratingStackView.backgroundColor = .clear
		
		(0..<Constants.maxStars).forEach { _ in
			let button = UIButton(type: .custom)
			self.starButtons.append(button)
			button.translatesAutoresizingMaskIntoConstraints = false
			button.height(48)
			button.widthToHeight(of: button)
			button.setImage(
				.Icons.star.resized(newWidth: 32)?.tintedImage(withColor: .Icons.iconSecondary),
				for: .normal
			)
			button.setImage(
				.Icons.star.resized(newWidth: 32)?.tintedImage(withColor: .Icons.iconAccent),
				for: .selected
			)
			button.addTarget(self, action: #selector(starTap(_:)), for: .touchUpInside)
			ratingStackView.addArrangedSubview(button)
		}
	}
	
	@objc private func starTap(_ sender: UIButton) {
		guard let starIndex = starButtons.firstIndex(of: sender) else { return }

		selectedRating = starIndex + 1
		updateUI()
	}
	
	private func updateUI() {
		for (index, button) in starButtons.enumerated() {
			button.isSelected = index < selectedRating
		}
	}

	private enum Constants {
		static let maxStars = 5
	}
}
