//
//  StoriesService.swift
//  AlfaStrah
//
//  Created by Makson on 07.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

protocol StoriesService {
    var stories: [Story] { get }
    func getStories(
        isForced: Bool,
        screenWidth: Int,
        completion: @escaping (Result<[Story], AlfastrahError>) -> Void
    )
    func loadingImage(url: URL?)
    func subscribeForStoryUpdates(listener: @escaping ([Story]) -> Void) -> Subscription
    func markStoriesAsRead(storiesIds: [Int])
}
