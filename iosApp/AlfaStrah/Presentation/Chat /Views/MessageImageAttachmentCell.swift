//
//  MessageImageAttachmentCell.swift
//  AlfaStrah
//
//  Created by vit on 27.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage
import Lottie

class MessageImageAttachmentCell: MessageBubbleCell {
	enum State {
		case data
		case processing
		case unknown
	}
	
	static let myCell: Reusable<MessageImageAttachmentCell> = .class(id: "MyMessageImageAttachmentCell")
	static let operatorCell: Reusable<MessageImageAttachmentCell> = .class(id: "OperatorMessageImageAttachmentCell")

	private let containerView = UIView()

	private let attachmentImageView = UIImageView()
	private let placeholderImageView = UIImageView()
	
	private var animationView = createAnimationView()
	
	private lazy var bubbleWidthConstraint: NSLayoutConstraint = {
		return containerView.widthAnchor.constraint(equalToConstant: 0)
	}()
	
	private lazy var bubbleHeightConstraint: NSLayoutConstraint = {
		return containerView.heightAnchor.constraint(equalToConstant: 0)
	}()
	
	var prepareForReuseCallback: (() -> Void)?
		
	override func setup() {
		super.setup()
		
		bubbleView.addSubview(containerView)
		containerView.addSubview(placeholderImageView)
		
		placeholderImageView.center(in: containerView)
		placeholderImageView.width(60)
		placeholderImageView.heightToWidth(of: placeholderImageView)
		placeholderImageView.contentMode = .scaleAspectFit
		
		containerView.addSubview(attachmentImageView)
		attachmentImageView.contentMode = .scaleAspectFill
		attachmentImageView.edgesToSuperview()
		
		bubbleMaxWidth = Constants.imageAttachmentCellWidth
		bubbleHeightConstraint.constant = Constants.imageAttachmentCellWidth
		bubbleWidthConstraint.constant = Constants.imageAttachmentCellWidth
		
		containerView.addSubview(animationView)
		animationView.center(in: containerView)
		animationView.width(50)
		animationView.heightToWidth(of: animationView)
	}
	
	override func update() {
		super.update()
	}
	
	func configure(_ image: UIImage) {
		attachmentImageView.image = image
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		prepareForReuseCallback?()
		attachmentImageView.image = nil
	}
	
	override func dynamicStylize() {
		super.dynamicStylize()

		bubbleView.backgroundColor = .clear
		placeholderImageView.isHidden = attachmentImageView.image != nil
	}
	
	override func staticStylize() {
		super.staticStylize()
		
		bubbleView.backgroundColor = .clear
		containerView.backgroundColor = .Background.fieldBackground
		
		placeholderImageView.backgroundColor = .clear
		placeholderImageView.image = isMine
			? .Illustrations.uploadPlaceholder
			: .Illustrations.downloadPlaceholder
		
		attachmentImageView.tintColor = .clear
		attachmentImageView.backgroundColor = .clear
	}

	// MARK: - Layout
	/// Exact height of the cell.
	class override var height: CGFloat { UITableView.automaticDimension }

	/// Estimated height of the cell.
	class override var estimatedHeight: CGFloat { 150 }

	override func layoutContent() {
		super.layoutContent()

		var constraints = NSLayoutConstraint.fill(view: containerView, in: bubbleView)
		constraints.append(
			contentsOf: [
				bubbleHeightConstraint,
				bubbleWidthConstraint
			]
		)
		add(constraints: constraints)
	}
	
	private static func createAnimationView() -> AnimationView {
		let animation = Animation.named("red-spinning-loader")
		let animationView = AnimationView(animation: animation)
		animationView.backgroundColor = .clear
		animationView.loopMode = .loop
		animationView.contentMode = .scaleAspectFill
		
		let resistantPriority = UILayoutPriority(rawValue: 990)
		animationView.setContentCompressionResistancePriority(resistantPriority, for: .horizontal)
		animationView.setContentCompressionResistancePriority(resistantPriority, for: .vertical)
		animationView.setContentHuggingPriority(resistantPriority, for: .horizontal)
		animationView.setContentHuggingPriority(resistantPriority, for: .vertical)
		
		animationView.backgroundBehavior = .pauseAndRestore
		
		let keypath = AnimationKeypath(keypath: "Слой-фигура 4.Прямоугольник 1.Заливка 1.Color")
		let colorProvider = ColorValueProvider(UIColor.clear.lottieColorValue)
		animationView.setValueProvider(colorProvider, keypath: keypath)
		
		return animationView
	}
	
	private func updateSpinner(with color: UIColor) {
		let colorProvider = ColorValueProvider(color.lottieColorValue)
		
		let primarySpinnerColorKeypath = AnimationKeypath(keypath: "Слой-фигура 3.Эллипс 1.Обводка 1.Color")
		animationView.setValueProvider(colorProvider, keypath: primarySpinnerColorKeypath)
		
		let secondarySpinnerColorKeypath = AnimationKeypath(keypath: "Слой-фигура 2.Эллипс 1.Обводка 1.Color")
		animationView.setValueProvider(colorProvider, keypath: secondarySpinnerColorKeypath)
	}
	
	func applyCellState(_ state: State) {
		switch state {
			case .data:
				animationView.isHidden = true
				placeholderImageView.isHidden = true
				animationView.stop()
				
			case .unknown:
				animationView.isHidden = true
				placeholderImageView.isHidden = false
				animationView.stop()
				
			case .processing:
				animationView.isHidden = false
				placeholderImageView.isHidden = true
				animationView.play()
		}
	}
	
	private enum Constants {
		static let imageAttachmentCellWidth: CGFloat = 150
	}
}
