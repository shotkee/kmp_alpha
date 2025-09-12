//
//  TwoColumnsLayoutView.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

extension BDUI {
	class TwoColumnsLayoutView: LayoutView<TwoColumnsLayoutDTO>,
								UICollectionViewDelegate,
								UICollectionViewDataSource,
								UICollectionViewDelegateFlowLayout{
		struct Constants {
			static let minimumInteritemSpacing: CGFloat = 12
		}
		
		private let items: [WidgetDTO]
		private let containerView = UIView()
		private let cellWidth: CGFloat
		private let tallestCollectionViewCellSize: CGSize
		
		private lazy var collectionView: UICollectionView = createCollectionView()
		
		private lazy var collectionViewHeightConstraint: Constraint = {
			return collectionView.height(0)
		}()
		
		required init(
			block: TwoColumnsLayoutDTO,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.items = block.content ?? []
			
			// calc cells heights for items and find tallest
			let cellWidth = (UIScreen.main.bounds.width - horizontalInset * 2 - Constants.minimumInteritemSpacing) / 2
			self.cellWidth = cellWidth
			
			let cellHeight = items
				.map { Self.cellSize(for: $0, with: cellWidth).height }
				.reduce(CGFloat.leastNormalMagnitude, { max($0, $1) })
			
			self.tallestCollectionViewCellSize = CGSize(width: cellWidth, height: cellHeight)
			
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func createCollectionView() -> UICollectionView {
			let flowLayout = UICollectionViewFlowLayout()
			
			flowLayout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
			flowLayout.minimumLineSpacing = 0
			flowLayout.scrollDirection = .vertical
			
			let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
			collectionView.dataSource = self
			collectionView.delegate = self
			
			collectionView.backgroundColor = .clear
			
			collectionView.isScrollEnabled = false
			collectionView.bounces = false
			collectionView.alwaysBounceVertical = false
			collectionView.alwaysBounceHorizontal = false
			collectionView.scrollIndicatorInsets = .zero
			collectionView.showsVerticalScrollIndicator = false
			collectionView.showsHorizontalScrollIndicator = false
			
			let inset = horizontalInset
			collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
			
			collectionView.registerDummyCell()
			collectionView.registerReusableCell(LayoutViewContainerCollectionCell.id)
			
			return collectionView
		}
		
		override func layoutSubviews() {
			super.layoutSubviews()
			
			collectionViewHeightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
		}
		
		private func setupUI() {
			backgroundColor = .clear
			
			setupCollectionView()
		}
		
		private func setupCollectionView(){
			addSubview(collectionView)
			
			collectionView.edgesToSuperview()
			collectionView.clipsToBounds = false
			
			collectionViewHeightConstraint.isActive = true
		}
		
		// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
		func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return items.count
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			layout collectionViewLayout: UICollectionViewLayout,
			sizeForItemAt indexPath: IndexPath
		) -> CGSize {
			return tallestCollectionViewCellSize
		}
		
		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			guard let selector = items[safe: indexPath.row]
			else { return collectionView.dequeueDummyReusableCell(for: indexPath) }
			
			let cell = collectionView.dequeueReusableCell(
				LayoutViewContainerCollectionCell.id,
				indexPath: indexPath
			)
			cell.set(
				selector: selector,
				handleEvent: { events in
					self.handleEvent?(events)
				}
			)
			
			return cell
		}
		
		// MARK: - Dark Theme Support
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			collectionView.reloadData()
		}
		
		// MARK: - self size calculation
		static private func cellSize(for selector: WidgetDTO, with cardWith: CGFloat) -> CGSize{
			let cell = LayoutViewContainerCollectionCell()
			
			cell.set(selector: selector, handleEvent: { _ in })
			
			return
			cell.systemLayoutSizeFitting(
				CGSize(width: cardWith, height: 0),
				withHorizontalFittingPriority: .required,
				verticalFittingPriority: .fittingSizeLevel
			)
		}
	}
}
