//
//  IconTextTagCircleWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 14.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

extension BDUI {
	class IconTextTagCircleWidgetView: WidgetView<IconTextTagCircleWidgetDTO>,
									   UICollectionViewDataSource,
									   UICollectionViewDelegate,
									   UICollectionViewDelegateFlowLayout {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		private let iconImageView = UIImageView()
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let accessoryImageView = UIImageView()
		
		struct Constants {
			static let tagViewHeight: CGFloat = 24
			static let contentInset: CGFloat = 16
			static let accessoryViewWidth: CGFloat = 24
			static let accessoryViewOffsetToContent: CGFloat = 8
			static let tagCollectionLayoutMinimumLineSpacing: CGFloat = 6
			static let tagCollectionLayoutMinimumInteritemSpacing: CGFloat = 10
		}
		
		private lazy var tagsCollectionView: UICollectionView = {
			let layout = SingleRowTagsCollectionViewFlowLayout()
			
			layout.minimumLineSpacing = Constants.tagCollectionLayoutMinimumLineSpacing
			layout.minimumInteritemSpacing = Constants.tagCollectionLayoutMinimumInteritemSpacing
			
			let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
			collectionView.registerReusableCell(LayoutViewContainerCollectionCell.id)
			
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
		
		private let cardWidth: CGFloat
		
		private var tags: [WidgetDTO] = [] {
			didSet {
				tagsCollectionView.reloadData()
			}
		}
		
		required init(
			block: IconTextTagCircleWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.cardWidth = UIScreen.main.bounds.width - horizontalInset * 2
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
			contentStackView.alignment = .leading
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(iconImageView)
			iconImageView.height(32)
			iconImageView.width(52)
			
			contentStackView.addArrangedSubview(spacer(12))
			
			contentStackView.addArrangedSubview(titleLabel)
			titleLabel.numberOfLines = 0
			titleLabel.textAlignment = .left
			
			contentStackView.addArrangedSubview(spacer(4))
			
			contentStackView.addArrangedSubview(descriptionLabel)
			descriptionLabel.numberOfLines = 0
			descriptionLabel.textAlignment = .left
			
			containerView.addSubview(accessoryImageView)
			
			accessoryImageView.width(Constants.accessoryViewWidth)
			accessoryImageView.heightToWidth(of: accessoryImageView)
			accessoryImageView.centerYToSuperview()
			accessoryImageView.topToSuperview(offset: Constants.contentInset, relation: .equalOrGreater)
			accessoryImageView.bottomToSuperview(offset: -Constants.contentInset, relation: .equalOrLess)
			accessoryImageView.trailingToSuperview(offset: Constants.contentInset)
			accessoryImageView.leadingToTrailing(of: contentStackView, offset: Constants.accessoryViewOffsetToContent)
			
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
			tags: [WidgetDTO]
		) -> CGSize {
			let correctedWidth = width
			- Constants.accessoryViewWidth
			- Constants.accessoryViewOffsetToContent
			- Constants.contentInset * 2
			
			let itemHeight = itemHeight + minimumLineSpacing
			
			var height: CGFloat = 0
			var tempWidth = correctedWidth
			
			for tag in tags {
				let size = Self.cellSize(selector: tag, for: itemHeight)
				
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
			
			return Self.cellSize(selector: tag, for: Constants.tagViewHeight)
		}
		
		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(LayoutViewContainerCollectionCell.id, indexPath: indexPath)
			
			cell.set(
				selector: tags[indexPath.row],
				handleEvent: { [weak self] events in
					self?.handleEvent?(events)
				}
			)
			
			return cell
		}
		
		// MARK: - self size calculation
		static func cellSize(selector: WidgetDTO, for height: CGFloat) -> CGSize{
			let cell = LayoutViewContainerCollectionCell()
			
			cell.set(
				selector: selector,
				handleEvent: { events in }
			)
			
			return
			cell.systemLayoutSizeFitting(
				CGSize(width: 0, height: height),
				withHorizontalFittingPriority: .fittingSizeLevel,
				verticalFittingPriority: .required
			)
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
			
			tagsCollectionView.reloadData()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let title = block.title {
				titleLabel <~ StyleExtension.Label(title, for: currentUserInterfaceStyle)
			}
			
			if let description = block.descirption {
				descriptionLabel <~ StyleExtension.Label(description, for: currentUserInterfaceStyle)
			}
			
			if let accessoryImageUrl = block.iconRight?.url(for: currentUserInterfaceStyle) {
				accessoryImageView.sd_setImage(with: accessoryImageUrl)
			}
			
			if let iconImageUrl = block.iconTop?.url(for: currentUserInterfaceStyle) {
				iconImageView.sd_setImage(with: iconImageUrl)
			}
			
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
		}
	}
}
