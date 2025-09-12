//
//  FilterEventItemWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 18.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import SDWebImage

extension BDUI {
	class FilterEventItemWidgetView: WidgetView<FilterEventItemWidgetDTO> {
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let underLineView = UIView()
		private let iconImageView = UIImageView()
		private let markView = UIView()
		
		required init(
			block: FilterEventItemWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
			setupTapGestureRecognizer()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		override func layoutSubviews() {
			super.layoutSubviews()
			
			containerView.layer.cornerRadius = containerView.frame.height * 0.5
			
			if block.themedMarkColor != nil {
				containerView.layer.mask = markMask(frame: containerView.frame)
				markView.layer.cornerRadius = markView.frame.height * 0.5
			}
		}
		
		private func setupUI() {
			addSubview(containerView)
			containerView.edgesToSuperview()
			containerView.layer.masksToBounds = true
			
			let contentStackView = UIStackView()
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .horizontal
			contentStackView.spacing = 6
			contentStackView.backgroundColor = .clear
			
			containerView.addSubview(contentStackView)
			contentStackView.edgesToSuperview()
			
			if block.themedIcon != nil {
				iconImageView.height(16)
				iconImageView.width(16)
				contentStackView.addArrangedSubview(iconImageView)
			}
			
			titleLabel <~ Style.Label.primaryText
			
			titleLabel.text = block.themedTitle?.text
			
			contentStackView.addArrangedSubview(titleLabel)
			
			if block.themedMarkColor != nil {
				addSubview(markView)
				markView.edgesToSuperview(excluding: [.leading, .bottom], insets: insets(2))
				markView.height(10)
				markView.width(10)
				markView.layer.masksToBounds = true
			}
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			iconImageView.sd_setImage(with: block.themedIcon?.url(for: currentUserInterfaceStyle))
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .clear
			titleLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			markView.backgroundColor = block.themedMarkColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconAccent
			
			if let themedBorderColor = block.themedBorderColor {
				containerView.layer.borderWidth = 1
				containerView.layer.borderColor = themedBorderColor.color(for: currentUserInterfaceStyle)?.cgColor
			}
		}
		
		func markMask(frame: CGRect) -> CAShapeLayer {
			let endAngle: CGFloat = 360 * .pi / 180
			
			let radius: CGFloat = 7
			
			let path = UIBezierPath(
				arcCenter: CGPoint(
					x: frame.size.width - radius,
					y: radius
				),
				radius: radius,
				startAngle: 0,
				endAngle: endAngle,
				clockwise: false
			)
			
			path.append(UIBezierPath(rect: frame))
			path.close()
			
			let shapeLayer = CAShapeLayer()
			shapeLayer.path = path.cgPath
			shapeLayer.fillRule = .evenOdd
			
			return shapeLayer
		}
	}
}
