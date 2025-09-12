//
//  NavigateWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 05.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

extension BDUI {
	class NavigateWidgetView: WidgetView<NavigateWidgetDTO>,
							  UICollectionViewDelegate,
							  UICollectionViewDataSource,
							  UICollectionViewDelegateFlowLayout {
		private let tallestCollectionViewCellHeight: CGFloat
		private let cellDynamicWidths: [CGFloat]
		
		private let cellWidth: CGFloat
		private let paddingHorizontal: CGFloat
		
		private let containerView = UIView()
		private lazy var collectionView: UICollectionView = createCollectionView()
		
		required init(
			block: NavigateWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.cellWidth = 0
			
			let cellSizes = block.items?.map {
				Self.cellSize(
					for: $0.isActive ? $0.activeStateWidget : $0.nonActiveStateWidget,
					with: 0
				)
			} ?? []
			
			self.tallestCollectionViewCellHeight = cellSizes.map { $0.height }.max() ?? .leastNormalMagnitude
			
			self.cellDynamicWidths = cellSizes.map { $0.width }
			
			self.paddingHorizontal = block.paddingHorizontal ?? 12
			
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
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
			addSubview(containerView)
			containerView.edgesToSuperview()
			
			setupCollectionView()
		}
		
		private func setupCollectionView() {
			containerView.addSubview(collectionView)
			
			collectionView.edgesToSuperview()
			collectionView.clipsToBounds = false
			
			collectionView.height(tallestCollectionViewCellHeight)
		}
		
		private func createCollectionView() -> UICollectionView {
			let lineLayout = UICollectionViewFlowLayout()
			
			lineLayout.minimumInteritemSpacing = self.paddingHorizontal
			lineLayout.scrollDirection = .horizontal
			
			let collectionView = UICollectionView(frame: .zero, collectionViewLayout: lineLayout)
			collectionView.dataSource = self
			collectionView.delegate = self
			
			collectionView.backgroundColor = .clear
			collectionView.scrollIndicatorInsets = .zero
			collectionView.showsVerticalScrollIndicator = false
			collectionView.showsHorizontalScrollIndicator = false
			
			collectionView.allowsSelection = false
			
			collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
			
			collectionView.registerDummyCell()
			collectionView.registerReusableCell(NavigateWidgetCell.id)
			
			return collectionView
		}
		
		// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
		func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return block.items?.count ?? 0
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			layout collectionViewLayout: UICollectionViewLayout,
			sizeForItemAt indexPath: IndexPath
		) -> CGSize {
			return CGSize(
				width: self.cellWidth == 0
				? self.cellDynamicWidths[indexPath.row]
				: self.cellWidth,
				height: self.tallestCollectionViewCellHeight
			)
		}
		
		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			guard let item = block.items?[safe: indexPath.row],
				  let selector = item.isActive ? item.activeStateWidget : item.nonActiveStateWidget
			else { return collectionView.dequeueDummyReusableCell(for: indexPath) }
			
			let cell = collectionView.dequeueReusableCell(
				NavigateWidgetCell.id,
				indexPath: indexPath
			)
			cell.set(
				selector: selector,
				handleEvent: { events in
					self.handleEvent?(events)
					
					self.block.items?.forEach { $0.isActive = false }
					
					self.block.items?[safe: indexPath.row]?.isActive = true
					
					self.collectionView.reloadData()
				}
			)
			
			return cell
		}
		
		// MARK: - self size calculation
		static func cellSize(for selector: WidgetDTO?, with cardWith: CGFloat) -> CGSize{
			guard let selector
			else { return .zero }
			
			let cell = NavigateWidgetCell()
			
			cell.set(selector: selector, handleEvent: { _ in })
			
			return
			cell.systemLayoutSizeFitting(
				CGSize(width: cardWith, height: 0),
				withHorizontalFittingPriority: cardWith == 0 ? .fittingSizeLevel : .required,
				verticalFittingPriority: .fittingSizeLevel
			)
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let backgroundThemedColor = block.themedBackgroundColor {
				containerView.backgroundColor = backgroundThemedColor.color(for: currentInterfaceStyle)
			}
			
			collectionView.reloadData()
		}
	}
	
	class NavigateWidgetCell: UICollectionViewCell {
		static let id: Reusable<NavigateWidgetCell> = .fromClass()
		
		private
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			clearStyle()
		}
		
		func set(
			selector: WidgetDTO,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			let view = ViewBuilder.constructWidgetView(
				for: selector,
				handleEvent: handleEvent
			)
			
			contentView.addSubview(view)
			view.edgesToSuperview()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func prepareForReuse() {
			super.prepareForReuse()
			
			contentView.subviews.forEach({ $0.removeFromSuperview() })
		}
	}
}
