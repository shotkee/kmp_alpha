//
//  RestStoriesService.swift
//  AlfaStrah
//
//  Created by Makson on 07.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy
import SDWebImage

// swiftlint:disable file_length
class RestStoriesService: StoriesService, Updatable {
    private let applicationSettingsService: ApplicationSettingsService
    private let rest: FullRestClient
    private let store: Store
    private let authorizer: HttpRequestAuthorizer
    
    init(
        applicationSettingsService: ApplicationSettingsService,
        rest: FullRestClient,
        store: Store,
        authorizer: HttpRequestAuthorizer
    ) {
        self.applicationSettingsService = applicationSettingsService
        self.rest = rest
        self.store = store
        self.authorizer = authorizer
    }
    
    private(set) var stories: [Story] = [] {
        didSet {
            preloadingPreviewImageStories()
            preloadingFirstPageStories()
            storySubscriptions.fire(stories)
        }
    }
    
    private var storySubscriptions: Subscriptions<[Story]> = Subscriptions()
    private var storiesRequestIsPending = false
    private var storiesRequestCompletions: [(Result<[Story], AlfastrahError>) -> Void] = []
                
    func subscribeForStoryUpdates(listener: @escaping ([Story]) -> Void) -> Subscription {
        storySubscriptions.add(listener)
    }
    
    private func preloadingPreviewImageStories() {
        for story in stories {
            loadingImage(url: story.preview)
        }
    }
    
    func loadingImage(url: URL?) {
        SDWebImageManager.shared.loadImage(
            with: url,
            options: .highPriority,
            context: [.imageCache: RestStoriesService.createImageCached()],
            progress: nil,
            completed: { _, _, _, _, _, _ in }
        )
    }
    
    @discardableResult static func createImageCached() -> SDImageCache {
        let imageCache = SDImageCache(namespace: "stories")
        imageCache.config.maxDiskAge = 60 * 60 * 24 * 30 * 2
        
        return imageCache
    }
    
    private func preloadingFirstPageStories() {
        for story in stories {
            if let page = story.pageList.first {
                loadingImage(url: page.body?.backgroundImage)
                loadingImage(url: page.body?.image)
            }
        }
    }
    
    func getStories(
        isForced: Bool,
        screenWidth: Int,
        completion: @escaping (Result<[Story], AlfastrahError>) -> Void
    ) {
        if !stories.isEmpty && !isForced {
            completion(.success(self.stories))
        }
        else {
            storiesRequestCompletions.append(completion)
                        
            if !storiesRequestIsPending {
                storiesRequestIsPending = true
                
                rest.read(
					path: "/api/stories",
					id: nil,
					parameters: [
						"screen_width": "\(screenWidth)"
					],
					headers: [:],
					responseTransformer: ResponseTransformer(
						key: "story_list",
						transformer: ArrayTransformer(
							transformer: StoryTransformer()
						)
					),
					completion: mapCompletion { [weak self] result in
						guard let self = self
						else { return }
								
						switch result {
							case .success(let stories):
								self.stories = stories
							case .failure:
								self.stories = self.stories
						}
						
						self.storiesRequestCompletions.forEach { $0(result) }
						self.storiesRequestCompletions.removeAll()
						self.storiesRequestIsPending = false
					}
				)
            }
        }
    }
    
    func markStoriesAsRead(storiesIds: [Int]) {
        rest.create(
            path: "/api/stories/read",
            id: nil,
            object: [
                "story_ids": storiesIds
            ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, Any>()
            ),
            responseTransformer: VoidTransformer(),
            completion: { result in
                switch result {
                    case .success:
                        var stories = self.stories
                        var hasUpdates = false
                        
                        for (index, story) in self.stories.enumerated() {
                            if storiesIds.contains(story.id),
                               story.status == .unviewed {
                                stories[index] = story.updating(status: .viewed)
                                hasUpdates = true
                            }
                        }
                        
                        if hasUpdates {
                            self.stories = stories
                        }
                        
                    case .failure:
                        break
                }
            }
        )
    }
    
    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func erase(logout: Bool) {
        self.stories = []
    }
}
