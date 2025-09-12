//
//  StoriesFlow.swift
//  AlfaStrah
//
//  Created by Makson on 04.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

class StoriesFlow: BaseFlow,
                   StoriesServiceDependency,
                   AccountServiceDependency {
    var storiesService: StoriesService!
    var accountService: AccountService!
    
    func start(
        selectedStoryIndex: Int,
        stories: [Story],
        viewedStoriesPage: [Int: Int],
        completion: @escaping (Int, Int) -> Void
    ) {
        
        let viewController = createStoriesViewContoller(
            selectedStoryIndex: selectedStoryIndex,
            stories: stories,
            viewedStoriesPage: viewedStoriesPage,
            completion: completion
        )
        
        fromViewController.present(
            viewController,
            animated: false
        )
    }
    
    private func createStoriesViewContoller(
        selectedStoryIndex: Int,
        stories: [Story],
        viewedStoriesPage: [Int: Int],
        completion: @escaping (Int, Int) -> Void
    ) -> StoriesViewController {
        let viewController = StoriesViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            stories: stories,
            selectedStoryIndex: selectedStoryIndex,
            viewedStoriesPage: viewedStoriesPage
        )
        
        viewController.output = .init(
            openWebView: { [weak viewController] url, urlShareable, completion in
                guard let viewController = viewController?.topViewController
                else { return }
                
                WebViewer.openDocument(
                    url,
                    needSharedUrl: true,
                    urlShareable: urlShareable,
                    from: viewController,
                    completion: completion
                )
            },
            openBrowser: { [weak viewController] url in
                UIApplication.shared.open(
                    url
                )
            },
            onStoryShown: { story, navigationSource in
                
                let pageIndex = viewedStoriesPage[story.id] ?? 0
                
                var propertes: [String: Any?] = [
					AnalyticsParam.Key.navigationSource: navigationSource,
                    AnalyticsParam.Stories.storyId: story.id,
                    AnalyticsParam.Stories.storyTitle: story.title,
                    AnalyticsParam.Stories.pageIndex: pageIndex
                ]
                if navigationSource == .main {
                    propertes[AnalyticsParam.Stories.storySeen] = story.status == .viewed
                }
                self.analytics.track(
                    event: AnalyticsEvent.Stories.storyOpen,
                    properties: propertes
                )
            },
            onStoryPageShown: { story, pageIndex, pageHasLoading, pageNavigationTrigger in
                self.analytics.track(
                    event: AnalyticsEvent.Stories.storyPageOpen,
                    properties: [
                        AnalyticsParam.Stories.storyId: story.id,
                        AnalyticsParam.Stories.storyTitle: story.title,
                        AnalyticsParam.Stories.pageIndex: pageIndex,
                        AnalyticsParam.Stories.pageHasLoading: pageHasLoading,
                        AnalyticsParam.Stories.pageNavigationTrigger: pageNavigationTrigger.rawValue
                    ]
                )
                
                self.preloadingBackgroundAndContentImages(
                    story: story,
                    pageIndex: pageIndex
                )
                
                // if user opened last page
                // find same story in current cache, if exists
                if self.accountService.isAuthorized,
                   !self.accountService.isDemo,
                   pageIndex == story.pageList.count - 1,
                   let story = self.storiesService.stories.first(where: { $0.id == story.id }),
                   story.status != .viewed {
                    self.storiesService.markStoriesAsRead(storiesIds: [story.id])
                }
            },
            onPageAction: { story, pageIndex, pageStatus, action, link, time in
                var properties: [String: Any?] = [
                    AnalyticsParam.Stories.pageStatus: pageStatus.rawValue,
                    AnalyticsParam.Stories.pageAction: action.rawValue,
                    AnalyticsParam.Stories.storyId: story.id,
                    AnalyticsParam.Stories.storyTitle: story.title,
                    AnalyticsParam.Stories.pageIndex: pageIndex
                ]
                if let link = link {
                    properties[AnalyticsParam.Stories.pageActionLink] = link.absoluteString
                }
                if action != .pause {
                    properties[AnalyticsParam.Stories.pageActionTime] = time
                }
                self.analytics.track(
                    event: AnalyticsEvent.Stories.storyPageAction,
                    properties: properties
                )
            },
            updateCurrentViewedPageIndex: { [weak viewController] storyId, currentStoryPageIndex in
                completion(storyId, currentStoryPageIndex)
            },
            close: { [weak viewController] in
                viewController?.dismiss(animated: false)
            }
        )
        
        return viewController
    }
    
    private func preloadingBackgroundAndContentImages(
        story: Story,
        pageIndex: Int
    ){
        if let page = story.pageList[safe: pageIndex + 1] {
            storiesService.loadingImage(url: page.body?.image)
            storiesService.loadingImage(url: page.body?.backgroundImage)
        }
        
        if let page = story.pageList[safe: pageIndex + 2] {
            storiesService.loadingImage(url: page.body?.image)
            storiesService.loadingImage(url: page.body?.backgroundImage)
        }
    }
}
