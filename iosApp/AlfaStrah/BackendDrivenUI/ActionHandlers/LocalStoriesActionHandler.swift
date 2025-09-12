//
//  LocalStoriesActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 07.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LocalStoriesActionHandler: ActionHandler<LocalStoriesActionDTO> {
		required init(
			block: LocalStoriesActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let selectedStory = block.selectedStory
				else {
					syncCompletion()
					return
				}
				
				let storiesFlow = StoriesFlow(rootController: from)
				ApplicationFlow.shared.container.resolve(storiesFlow)
				
				storiesFlow.start(
					selectedStoryIndex: selectedStory.0,
					stories: selectedStory.1,
					viewedStoriesPage: selectedStory.2,
					completion: selectedStory.3
				)
				
				syncCompletion()
			}
		}
	}
}
