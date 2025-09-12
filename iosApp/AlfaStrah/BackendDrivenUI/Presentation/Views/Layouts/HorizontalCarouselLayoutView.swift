//
//  HorizontalCarouselLayoutView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 24.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

extension BDUI {
	class HorizontalCarouselLayoutView: LayoutView<HorizontalCarouselLayoutDTO>,
										UIScrollViewDelegate {
		required init(
			block: HorizontalCarouselLayoutDTO,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		private let pageControl = UIPageControl()
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			let margin: CGFloat = 18
			let spacing: CGFloat = 8
			
			// stack
			let stackView = UIStackView()
			stackView.axis = .vertical
			addSubview(stackView)
			stackView.verticalToSuperview()
			stackView.horizontalToSuperview(insets: .horizontal(margin - spacing / 2))
			
			// scroll
			let scrollView = UIScrollView()
			scrollView.clipsToBounds = false
			scrollView.isPagingEnabled = true
			scrollView.showsHorizontalScrollIndicator = false
			scrollView.delegate = self
			stackView.addArrangedSubview(scrollView)
			scrollView.contentLayoutGuide.height(to: scrollView)
			
			// widgets stack
			let widgetsStackView = UIStackView(arrangedSubviews: widgets())
			widgetsStackView.axis = .horizontal
			widgetsStackView.spacing = spacing
			scrollView.addSubview(widgetsStackView)
			widgetsStackView.verticalToSuperview()
			widgetsStackView.horizontalToSuperview(insets: .horizontal(spacing / 2))
			widgetsStackView.arrangedSubviews.forEach { widgetView in
				widgetView.width(
					to: self,
					offset: -2 * self.horizontalInset
				)
			}
			
			// page control
			pageControl.isUserInteractionEnabled = false
			pageControl.numberOfPages = widgetsStackView.subviews.count
			stackView.addArrangedSubview(pageControl)
			
			updateTheme()
		}
		
		private func widgets() -> [UIView] {
			return block.content?.compactMap {
				ViewBuilder.constructWidgetView(
					for: $0,
					horizontalLayoutOneSideContentInset: self.horizontalInset,
					handleEvent: { events in
						self.handleEvent?(events)
					}
				)
			} ?? []
		}
		
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
		}
		
		// MARK: - Dark Theme Support
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			pageControl.currentPageIndicatorTintColor = block.activeColor?.color(for: currentUserInterfaceStyle)
			pageControl.pageIndicatorTintColor = block.inactiveColor?.color(for: currentUserInterfaceStyle)
			
		}
	}
}
