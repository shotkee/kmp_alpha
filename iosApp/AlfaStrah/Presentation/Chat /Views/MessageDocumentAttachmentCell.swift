//
//  MessageAttachmentCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 07.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class MessageDocumentAttachmentCell: MessageBubbleCell {
    static let myCell: Reusable<MessageDocumentAttachmentCell> = .class(id: "MyMessageDocumentAttachmentCell")
    static let operatorCell: Reusable<MessageDocumentAttachmentCell> = .class(id: "OperatorMessageDocumentAttachmentCell")

	private let documentAttachmentView = DocumentAttachmentView()
	private let containerView = UIView()
	
	private lazy var bubbleWidthConstraint: NSLayoutConstraint = {
		return containerView.widthAnchor.constraint(equalToConstant: 0)
	}()
	
	private lazy var bubbleHeightConstraint: NSLayoutConstraint = {
		return containerView.heightAnchor.constraint(equalToConstant: 0)
	}()
	
	var prepareForReuseCallback: (() -> Void)?
		
    override func setup() {
        super.setup()
		
		containerView.translatesAutoresizingMaskIntoConstraints = false
		bubbleView.addSubview(containerView)
		
		containerView.addSubview(documentAttachmentView)
		documentAttachmentView.edgesToSuperview(insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    }
	
    override func update() {
        super.update()

		if let attachment = message?.getData()?.getAttachment() {
			let attachmentFileInfo = attachment.getFileInfo()
			
			bubbleHeightConstraint.constant = Constants.documentAttachmentCellHeight
			bubbleWidthConstraint.constant = Constants.documentAttachmentCellWidth
			bubbleMaxWidth = Constants.documentAttachmentCellWidth
			
			let attachmentSize = attachmentFileInfo.getSize() ?? 0
			
			let style: DocumentAttachmentView.Appearance = isMine ? .outgoing : .incoming
			let attachmentState = attachment.getState()
			
			documentAttachmentView.set(
				title: attachmentFileInfo.getFileName(),
				description: attachmentSize == 0 ? "" : bytesCountFormatted(from: attachmentSize),
				style: style,
				attachmentState: attachmentState
			)
			
			updateErrorLabelIfNeeded(with: attachmentState)
		}
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		prepareForReuseCallback?()
	}
	
	private func updateErrorLabelIfNeeded(with attachmentState: AttachmentState) {
		switch attachmentState {
			case .retry(let reason, _):
				errorLabel.isHidden = false
				errorLabel.text = reason ?? NSLocalizedString("common_unknown_error", comment: "")
			case .downloading, .uploading, .local, .remote:
				errorLabel.isHidden = true
		}
	}
	
	func attachmentStateUpdate(_ state: AttachmentState, isMine: Bool) {
		let style: DocumentAttachmentView.Appearance = isMine ? .outgoing : .incoming
		
		documentAttachmentView.update(state, style: style)
		
		updateErrorLabelIfNeeded(with: state)
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
	
	private enum Constants {
		static let imageAttachmentCellWidth: CGFloat = 150
		static let documentAttachmentCellWidth: CGFloat = UIScreen.main.bounds.width * 2 / 3
		static let documentAttachmentCellHeight: CGFloat = 64
	}
}

class DocumentAttachmentView: UIView {
	enum Appearance {
		case incoming
		case outgoing
	}
	
	private let iconBackgroundView = UIView()
	private let iconImageView = UIImageView()
	private let filenameLabel = UILabel()
	private let sizeLabel = UILabel()
	
	private let progressView = ProgressCircleIndicator()
		
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clear
		
		addSubview(iconBackgroundView)
		iconBackgroundView.backgroundColor = .Background.blackOverlay
		iconBackgroundView.width(40)
		iconBackgroundView.heightToWidth(of: iconBackgroundView)
		iconBackgroundView.edgesToSuperview(excluding: .trailing)
		
		iconBackgroundView.layer.masksToBounds = true
		
		iconBackgroundView.addSubview(iconImageView)
		iconImageView.width(20)
		iconImageView.heightToWidth(of: iconImageView)
		iconImageView.center(in: iconBackgroundView)
		
		iconBackgroundView.addSubview(progressView)
		progressView.edges(to: iconBackgroundView)
		progressView.padding = 2
		
		addSubview(filenameLabel)
		filenameLabel.numberOfLines = 1
		filenameLabel <~ Style.Label.primaryText
		filenameLabel.topToSuperview()
		filenameLabel.leadingToTrailing(of: iconBackgroundView, offset: 8)
		filenameLabel.trailingToSuperview()
		
		addSubview(sizeLabel)
		sizeLabel.numberOfLines = 1
		sizeLabel <~ Style.Label.primaryCaption1
		sizeLabel.bottomToSuperview()
		sizeLabel.leadingToTrailing(of: iconBackgroundView, offset: 8)
		sizeLabel.trailingToSuperview()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		iconBackgroundView.layer.cornerRadius = iconBackgroundView.bounds.height / 2
	}
		
	func set(
		title: String,
		description: String,
		style: Appearance,
		attachmentState: AttachmentState
	) {
		filenameLabel.text = title
		sizeLabel.text = description
		
		let isDarkStyle = style == .incoming
				
		filenameLabel <~ { isDarkStyle
			? Style.Label.primaryText
			: Style.Label.contrastText
		}()
		
		sizeLabel <~ { isDarkStyle
			? Style.Label.primaryCaption1
			: Style.Label.contrastCaption1
		}()
		
		progressView.isHidden = true
		
		update(attachmentState, style: style)
	}
	
	func update(_ state: AttachmentState, style: Appearance) {
		let isDarkStyle = style == .incoming
		
		let imageTintColor: UIColor
		
		if #available(iOS 13.0, *) { // since inside cells auto-resolving color for userInterface style may work wrong
			imageTintColor = isDarkStyle
				? .Icons.iconPrimary.resolvedColor(with: traitCollection)
				: .Icons.iconContrast.resolvedColor(with: traitCollection)
		} else {
			imageTintColor = isDarkStyle ? .Icons.iconPrimary : .Icons.iconContrast
		}
		
		progressView.indicatorColor = imageTintColor
		
		var totalSizeInBytes: Int64?
		
		switch state {
			case .local(let size):
				iconImageView.image = .Icons.file.resized(newWidth: 20)?.tintedImage(withColor: imageTintColor)
				progressView.isHidden = true
				
				if let size {
					totalSizeInBytes = size
				}
				
			case .downloading(let progress, let size):
				iconImageView.image = .Icons.cross.resized(newWidth: 18)?.tintedImage(withColor: imageTintColor)
				progressView.proggress = progress
				progressView.isHidden = false
				
				if let size {
					totalSizeInBytes = size
				}
				
			case .uploading(let progress, let size):
				iconImageView.image = .Icons.cross.resized(newWidth: 18)?.tintedImage(withColor: imageTintColor)
				progressView.proggress = progress
				progressView.isHidden = false
				if let size {
					totalSizeInBytes = size
				}
				
			case .retry:
				iconImageView.image = .Icons.redo.resized(newWidth: 20)?.tintedImage(withColor: imageTintColor)
				progressView.isHidden = true
				
				totalSizeInBytes = nil
				
			case .remote(let size):
				iconImageView.image = .Icons.arrowDown.resized(newWidth: 20)?.tintedImage(withColor: imageTintColor)
				progressView.isHidden = true
				
				if let size {
					totalSizeInBytes = size
				}
				
		}
		
		if let totalSizeInBytes {
			sizeLabel.text = totalSizeInBytes == 0 ? "" : bytesCountFormatted(from: totalSizeInBytes)
		}
	}
}

class ProgressCircleIndicator: UIView {
	let containerView = UIView()
	let circleShape = CAShapeLayer()
	
	private lazy var insetsConstraints: [NSLayoutConstraint] = {
		return containerView.edgesToSuperview(insets: .zero)
	}()
	
	var padding: CGFloat = 0 {
		didSet {
			insetsConstraints.forEach {
				$0.constant = padding
			}
			
			update()
		}
	}
	
	var indicatorColor: UIColor = .Icons.iconContrast {
		didSet {
			circleShape.strokeColor = indicatorColor.cgColor
			
			update()
		}
	}
	
	var indicatorLineWidth: CGFloat = 1 {
		didSet {
			circleShape.lineWidth = indicatorLineWidth
			
			update()
		}
	}
	
	var proggress: CGFloat = 0.0 {
		didSet {
			circleShape.strokeEnd = proggress
			
			update()
		}
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(containerView)
		NSLayoutConstraint.activate(insetsConstraints)
		
		backgroundColor = .clear

		circleShape.fillColor = UIColor.clear.cgColor
		circleShape.strokeStart = 0.0
		circleShape.strokeEnd = proggress

		containerView.layer.addSublayer(circleShape)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		update()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		update()
	}
	
	private func update() {
		let height = containerView.frame.size.height / 2
		
		let circlePath = UIBezierPath(
			arcCenter: CGPoint(x: height - padding, y: height - padding),
			radius: height - padding * 2,
			startAngle: CGFloat(-0.5 * .pi),
			endAngle: CGFloat(1.5 * .pi),
			clockwise: true
		)
		
		circleShape.path = circlePath.cgPath
		circleShape.strokeColor = indicatorColor.cgColor
		circleShape.lineWidth = indicatorLineWidth
		
		containerView.layer.cornerRadius = containerView.frame.size.height / 2
	}
}
