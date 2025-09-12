//
//  LayoutHorizontalScrollView.swift
//  AlfaStrah
//
//  Created by vit on 15.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HorizontalScrollLayoutView: LayoutView<HorizontalScrollLayoutDTO>,
									  UICollectionViewDelegate,
									  UICollectionViewDataSource,
									  UICollectionViewDelegateFlowLayout {
		private let items: [WidgetDTO]
		
		private let containerView = UIView()
		private let cardWidth: CGFloat
		private let cellWidth: CGFloat
		private let tallestCollectionViewCellHeight: CGFloat
		private let cellDynamicWidths: [CGFloat]
		
		private lazy var collectionView: UICollectionView = createCollectionView()
		
		required init(
			block: HorizontalScrollLayoutDTO,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.cardWidth = block.cardWidth ?? 0
			self.items = block.content ?? []
			
			// calc cells heights for items and find tallest
			let cellWidth: CGFloat
			
			switch block.cardWidthMode {
				case .fixed, .none:
					cellWidth = self.items.count > 1
					? UIScreen.main.bounds.width * cardWidth - horizontalInset * 2
					: UIScreen.main.bounds.width - horizontalInset * 2
				case .dynamic:
					cellWidth = 0
			}
			
			self.cellWidth = cellWidth
			
			let cellSizes = items.map { Self.cellSize(for: $0, with: cellWidth) }
			
			self.tallestCollectionViewCellHeight = cellSizes.map { $0.height }.max() ?? .leastNormalMagnitude
			
			self.cellDynamicWidths = cellSizes.map { $0.width }
			
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func createCollectionView() -> UICollectionView {
			let lineLayout = UICollectionViewFlowLayout()
			
			lineLayout.minimumInteritemSpacing = 12
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
			collectionView.registerReusableCell(LayoutViewContainerCollectionCell.id)
			
			return collectionView
		}
		
		private func setupUI() {
			backgroundColor = .clear
			
			setupCollectionView()
		}
		
		private func setupCollectionView() {
			addSubview(collectionView)
			
			collectionView.edgesToSuperview()
			collectionView.clipsToBounds = false
			
			collectionView.height(tallestCollectionViewCellHeight)
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
			return CGSize(
				width: self.cellWidth == 0
				? self.cellDynamicWidths[indexPath.row]
				: self.cellWidth,
				height: self.tallestCollectionViewCellHeight
			)
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
				withHorizontalFittingPriority: cardWith == 0 ? .fittingSizeLevel : .required,
				verticalFittingPriority: .fittingSizeLevel
			)
		}
	}
}
