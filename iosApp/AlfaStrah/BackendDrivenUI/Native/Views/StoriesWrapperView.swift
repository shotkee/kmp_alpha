//
//  StoriesWrapperView.swift
//  AlfaStrah
//
//  Created by vit on 17.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy

extension BDUI {
	class StoriesWrapperView: WidgetView<StoriesWidgetDTO>,
							  StoriesServiceDependency {
		var storiesService: StoriesService!

		private let containerView = UIView()
		private var storyView: UIView?
		
		private var viewedStoriesPage: [Int: Int] = [:]
		
		required init(
			block: StoriesWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		func requestStories() {
			self.storiesService.getStories(
				isForced: true,
				screenWidth: Int(UIScreen.main.bounds.width)
			) { [weak self] result in
				switch result {
					case .success(let stories):
						self?.update(with: stories)
					case .failure:
						break
				}
			}
		}
		
		private func update(with stories: [Story]) {
			storyView?.removeFromSuperview()
			
			self.storyView = createStoryView(stories: stories)
			
			if let storyView {
				containerView.addSubview(storyView)
				storyView.edgesToSuperview()
			}
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
			containerView.height(102)
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
		}
		
		private func createStoryView(stories: [Story]) -> UIView {
			let storyView = StoryView()
			
			storyView.input = .init(
				stories: stories
			)
			
			storyView.output = .init(
				select: { [weak self] selectedIndex in
					guard let self = self
					else { return }
										
					let action = LocalStoriesActionDTO(
						mode: .async,
						.localActionStories,
						selectedStory: (
							selectedIndex,
							stories,
							self.viewedStoriesPage,
							{ [weak self] storyId, currentStoryPageIndex in
								self?.viewedStoriesPage[storyId] = currentStoryPageIndex
							}
						)
					)
					
					let events = EventsDTO(onTap: action, onRender: nil, onChange: nil)
					
					self.handleEvent?(events)
				}
			)
			
			return storyView
		}
	}
}
