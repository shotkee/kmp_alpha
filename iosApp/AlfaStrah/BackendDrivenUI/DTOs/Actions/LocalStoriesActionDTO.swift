//
//  LocalStoriesActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 05.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LocalStoriesActionDTO: ActionDTO {
		typealias SelectedStoryEntry = (
			selectedStoryIndex: Int,
			stories: [Story],
			viewedStoriesPage: [Int: Int],
			completion: (Int, Int) -> Void
		)
		
		let selectedStory: SelectedStoryEntry?
		
		required init(body: [String: Any]) {
			self.selectedStory = nil
			
			super.init(body: body)
		}
		
		init(
			mode: BDUI.ActionDTO.ActionMode = .async,
			_ type: BackendComponentType,
			selectedStory: SelectedStoryEntry
		) {
			self.selectedStory = selectedStory
			super.init(mode: mode, type)
		}
	}
}
