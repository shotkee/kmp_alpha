//
//  TagImageWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 09.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

extension BDUI {
	class TagImageWidgetView: WidgetView<TagImageWidgetDTO>,
							  UICollectionViewDataSource,
							  UICollectionViewDelegate,
							  UICollectionViewDelegateFlowLayout {
		private let cardWidth: CGFloat
		
		struct Constants {
			static let tagViewHeight: CGFloat = 24
			static let contentInset: CGFloat = 16
			static let imageViewWidth: CGFloat = 126
			static let imageViewOffsetToContent: CGFloat = 8
			static let tagCollectionLayoutMinimumLineSpacing: CGFloat = 6
			static let tagCollectionLayoutMinimumInteritemSpacing: CGFloat = 10
		}
		
		private var tags: [TagWithIconWidgetDTO] = [] {
			didSet {
				tagsCollectionView.reloadData()
			}
		}
		
		private let containerView = UIView()
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let imageView = UIImageView()
		
		private lazy var tagsCollectionView: UICollectionView = {
			let layout = SingleRowTagsCollectionViewFlowLayout()
			
			layout.minimumLineSpacing = Constants.tagCollectionLayoutMinimumLineSpacing
			layout.minimumInteritemSpacing = Constants.tagCollectionLayoutMinimumInteritemSpacing
			
			let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
			collectionView.registerReusableCell(TagWithIconCollectionViewCell.id)
			
			collectionView.dataSource = self
			collectionView.delegate = self
			
			collectionView.isUserInteractionEnabled = false
			
			collectionView.isScrollEnabled = false
			collectionView.bounces = false
			collectionView.alwaysBounceVertical = false
			collectionView.alwaysBounceHorizontal = false
			collectionView.scrollIndicatorInsets = .zero
			collectionView.showsVerticalScrollIndicator = false
			collectionView.showsHorizontalScrollIndicator = false
			
			collectionView.backgroundColor = .clear
			
			return collectionView
		}()
		
		private lazy var tagCollectionViewHeightConstraint: Constraint = {
			return tagsCollectionView.height(0)
		}()
		
		private lazy var stackBottomConstraint: Constraint = {
			return contentStackView.bottomToSuperview(relation: .equalOrLess)
		}()
		
		private lazy var tagsCollectionViewBottomConstraint: Constraint = {
			return tagsCollectionView.bottomToSuperview(offset: -Constants.contentInset)
		}()
		
		required init(
			block: TagImageWidgetDTO,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.cardWidth = UIScreen.main.bounds.width - horizontalInset * 2
			
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		private func setupUI() {
			addSubview(cardView)
			cardView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			
			cardView.cornerRadius = 16
			
			cardView.set(content: containerView)
			containerView.addSubview(contentStackView)
			
			contentStackView.topToSuperview()
			contentStackView.leadingToSuperview()
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins =
			UIEdgeInsets(
				top: Constants.contentInset,
				left: Constants.contentInset,
				bottom: 12,
				right: Constants.contentInset
			)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 12
			contentStackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(titleLabel)
			
			titleLabel.numberOfLines = 0
			titleLabel.textAlignment = .left
			
			contentStackView.addArrangedSubview(descriptionLabel)
			
			descriptionLabel.numberOfLines = 0
			descriptionLabel.textAlignment = .left
			
			containerView.addSubview(imageView)
			
			imageView.width(Constants.imageViewWidth)
			imageView.heightToWidth(of: imageView)
			imageView.topToSuperview(offset: Constants.contentInset, relation: .equalOrGreater)
			imageView.bottomToSuperview()
			imageView.trailingToSuperview()
			imageView.leadingToTrailing(of: contentStackView, offset: Constants.imageViewOffsetToContent)
			imageView.contentMode = .scaleAspectFit
			
			containerView.addSubview(tagsCollectionView)
			tagsCollectionView.topToBottom(of: contentStackView, relation: .equalOrGreater)
			tagsCollectionView.leadingToSuperview(offset: Constants.contentInset)
			tagsCollectionView.trailing(to: contentStackView, relation: .equalOrGreater)
			tagsCollectionViewBottomConstraint.isActive = true
			tagCollectionViewHeightConstraint.isActive = true
			
			if let tags = block.tags {
				tagsCollectionViewBottomConstraint.isActive = !tags.isEmpty
				stackBottomConstraint.isActive = tags.isEmpty
				
				tagCollectionViewHeightConstraint.constant =
				tagsCollectionViewSize(
					width: cardWidth,
					tags: tags
				).height // pre-calculate content size for tags collection view
				
				// fill collection witn data
				self.tags = tags
			} else {
				tagsCollectionViewBottomConstraint.isActive = false
				stackBottomConstraint.isActive = true
			}
			
			if action != nil {
				setupTapGestureRecognizer()
			}
			
			updateTheme()
		}
		
		private func tagsCollectionViewSize(
			width: CGFloat,
			minimumLineSpacing: CGFloat = Constants.tagCollectionLayoutMinimumLineSpacing,
			minimumInteritemSpacing: CGFloat = Constants.tagCollectionLayoutMinimumInteritemSpacing,
			itemHeight: CGFloat = Constants.tagViewHeight,
			tags: [TagWithIconWidgetDTO]
		) -> CGSize {
			let correctedWidth = width
			- Constants.imageViewWidth
			- Constants.imageViewOffsetToContent
			- Constants.contentInset * 2
			
			let itemHeight = itemHeight + minimumLineSpacing
			
			var height: CGFloat = 0
			var tempWidth = correctedWidth
			
			for tag in tags {
				let size = self.cellSize(tag: tag, for: itemHeight)
				
				let itemWidth = size.width + minimumInteritemSpacing
				
				tempWidth -= itemWidth
				
				if tempWidth <= 0 { // sum of tems lengths exceeded row lenght
					height += itemHeight
					
					tempWidth = correctedWidth - itemWidth
					
					if tempWidth <= 0 { // last item is longer than row
						height += itemHeight
						
						tempWidth = correctedWidth
					}
				}
			}
			
			if tempWidth < correctedWidth { // if any items on last row
				height += itemHeight
			}
			
			height -= minimumLineSpacing // no need line-space after last element
			
			return CGSize(width: correctedWidth, height: height)
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
		
		func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return tags.count
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			layout collectionViewLayout: UICollectionViewLayout,
			sizeForItemAt indexPath: IndexPath
		) -> CGSize {
			guard let tag = tags[safe: indexPath.row]
			else { return .zero }
			
			return self.cellSize(tag: tag, for: Constants.tagViewHeight)
		}
		
		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(TagWithIconCollectionViewCell.id, indexPath: indexPath)
			
			cell.set(tags[indexPath.row])
			
			return cell
		}
		
		// MARK: - self size calculation
		private func cellSize(tag: TagWithIconWidgetDTO, for height: CGFloat) -> CGSize{
			let cell = TagWithIconCollectionViewCell()
			
			cell.set(tag)
			
			let correctedWidth = self.cardWidth
			- Constants.imageViewWidth
			- Constants.imageViewOffsetToContent
			- Constants.contentInset * 2
			
			let computedCellSize = cell.systemLayoutSizeFitting(
				CGSize(width: correctedWidth, height: height),
				withHorizontalFittingPriority: .fittingSizeLevel,
				verticalFittingPriority: .required
			)
			
			return CGSize(
				width: min(correctedWidth, computedCellSize.width),
				height: computedCellSize.height
			)
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
			
			tagsCollectionView.reloadData()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let title = block.themedTitle {
				titleLabel.text = title.text
				
				let color = title.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
				
				titleLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.headline1)
			}
			
			if let description = block.themedDescription {
				descriptionLabel.text = description.text
				
				let color = description.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textSecondary
				
				descriptionLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.subhead)
			}
			
			if let imageUrl = block.themedImage?.url(for: currentUserInterfaceStyle) {
				imageView.sd_setImage(with: imageUrl)
			}
			
			let backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			
			cardView.contentColor = backgroundColor
			containerView.backgroundColor = backgroundColor
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
}
