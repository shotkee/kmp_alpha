//
//  StoriesViewController.swift
//  AlfaStrah
//
//  Created by Makson on 26.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

import UIKit
import SDWebImage

// swiftlint:disable line_length file_length
class StoriesViewController: UINavigationController, UIGestureRecognizerDelegate {
    var input: Input!
    var output: Output!
    
    struct Input {
        let stories: [Story]
        let selectedStoryIndex: Int
        let viewedStoriesPage: [Int: Int]
    }
    
    struct Output {
        let openWebView: (URL, URL?, @escaping () -> Void) -> Void
        let openBrowser: (URL) -> Void
        let onStoryShown: (Story, AnalyticsParam.NavigationSource) -> Void
        let onStoryPageShown: (Story, Int, Bool, AnalyticsParam.Stories.PageNavigationTrigger) -> Void
        let onPageAction: (Story, Int, AnalyticsParam.Stories.PageStatus, AnalyticsParam.Stories.PageAction, URL?, TimeInterval) -> Void
        let updateCurrentViewedPageIndex: (Int, Int) -> Void
        let close: () -> Void
    }
    
    // MARK: - Outlets
    private var containerView = UIView()
    private var contentStackView = UIStackView()
    
    // MARK: - Variables
    private var selectedStoryIndex: Int = 0
    private var storiesViewControllers: [StoryViewController] = []
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var isOpenWebview: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        self.delegate = self
        self.navigationBar.isHidden = true
        transitioningDelegate = self
		view.backgroundColor = .Background.backgroundContent
        selectedStoryIndex = input.selectedStoryIndex
        setupStoriesViewControllers()
        setupAlreadyPresentedStories()
        setupRightScreenEdgePanGestureRecognizer()
        setupLeftScreenEdgePanGestureRecognizer()
        setupSwipeDown()
    }
    
    private func setupRightScreenEdgePanGestureRecognizer() {
        let panGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(onRightScreenEdgePanGestureRecognizer))
        panGesture.edges = .right
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func onRightScreenEdgePanGestureRecognizer(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let translate = gesture.translation(in: view)
        let percent = abs(translate.x) / view.bounds.size.width
        
        switch gesture.state {
            case .began:
                interactionController = UIPercentDrivenInteractiveTransition()
                guard let viewController = storiesViewControllers[safe: selectedStoryIndex + 1]
                else { return }
				
                viewControllers.removeAll { $0 == viewController }
                pushViewController(viewController, animated: true)
        
            case .changed:
                interactionController?.update(percent)
            case .ended, .cancelled:
                interactionController?.completionSpeed = 1.5
                if percent > 0.5 {
                    interactionController?.finish()
                    selectedStoryIndex = min(
                        input.stories.count - 1,
                        selectedStoryIndex + 1
                    )
                } else {
                    interactionController?.cancel()
                }
                interactionController = nil
            case .possible, .failed:
                break
            @unknown default:
                break
        }
    }
    
    private func setupLeftScreenEdgePanGestureRecognizer() {
        let panGesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(onLeftScreenEdgePanGestureRecognizer)
        )
        panGesture.edges = .left
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func onLeftScreenEdgePanGestureRecognizer(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let translate = gesture.translation(in: view)
        let percent = abs(translate.x) / view.bounds.size.width
      
        switch gesture.state {
            case .began:
                interactionController = UIPercentDrivenInteractiveTransition()
                popViewController(animated: true)
                
            case .changed:
                interactionController?.update(percent)
            case .ended, .cancelled:
                interactionController?.completionSpeed = 1.5
                if percent > 0.5 {
                    interactionController?.finish()
                    selectedStoryIndex = max(
                        0,
                        selectedStoryIndex - 1
                    )
                } else {
                    interactionController?.cancel()
                }
                interactionController = nil
            case .possible, .failed:
                break
            @unknown default:
                break
        }
    }
    
    private func setupStoriesViewControllers() {
        for index in 0 ..< input.stories.count {
            storiesViewControllers.append(
                createStoryViewController(
                    isFirstStory: index == 0,
                    story: input.stories[index],
                    currentViewedPageIndex: input.viewedStoriesPage[input.stories[index].id] ?? 0
                )
            )
        }
    }
    
    private func setupAlreadyPresentedStories() {
        var alreadyPresentedViewControllers: [StoryViewController] = []
        
        for index in 0 ... selectedStoryIndex {
            alreadyPresentedViewControllers.append(storiesViewControllers[index])
        }
        
        alreadyPresentedViewControllers.last?.initialPageNavigationTrigger = .initial
        
        if let story = input.stories[safe: input.selectedStoryIndex]
        {
            output.onStoryShown(
                story,
                .main
            )
        }
        
        self.setViewControllers(alreadyPresentedViewControllers, animated: false)
    }
    
    func setupSwipeDown() {
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(swipeDownGesture)
        )
        swipeDown.direction = .down
        swipeDown.delegate = self
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc func swipeDownGesture(gesture: UIGestureRecognizer) {
        output.close()
    }
    
    private func createStoryViewController(
        isFirstStory: Bool,
        story: Story,
        currentViewedPageIndex: Int
    ) -> StoryViewController {
        let viewController = StoryViewController()
    
        viewController.input = .init(
            isFirstStory: isFirstStory,
            storyPages: story.pageList,
            currentViewedPageIndex: currentViewedPageIndex
        )
    
        viewController.output = .init(
            openWebView: { [weak self] url, urlShareable, completion in
                self?.isOpenWebview = true
                self?.output.openWebView(
                    url,
                    urlShareable,
                    {
                        [weak self] in
                        self?.isOpenWebview = false
                        completion()
                    }
                )
            },
            openBrowser: { [weak self] url in
                self?.output.openBrowser(url)
            },
            showNextStory: { [weak self] pageNavigationTrigger in
                guard let self = self,
                      !self.isOpenWebview
                else { return }
                
                if self.selectedStoryIndex < self.storiesViewControllers.count - 1 {
                    self.selectedStoryIndex += 1
                    
                    guard let viewController = self.storiesViewControllers[safe: self.selectedStoryIndex]
                    else {
                        self.output.close()
                        return
                    }
                    
                    viewController.initialPageNavigationTrigger = pageNavigationTrigger
                    
                    self.pushViewController(viewController, animated: true)
                    
                    self.output.onStoryShown(
                        story,
                        .anotherStory
                    )
                }
                else {
                    self.output.close()
                }
            },
            showPreviousStory: { [weak self] in
                guard let self = self
                else { return }
                
                if self.selectedStoryIndex > 0 {
                    self.selectedStoryIndex -= 1
                    
                    viewController.initialPageNavigationTrigger = .userAction
                    
                    self.popViewController(animated: true)
                    
                    self.output.onStoryShown(
                        story,
                        .anotherStory
                    )
                }
            },
            onPageShown: { [weak self] pageIndex, pageHasLoading, pageNavigationTrigger in
                self?.output.onStoryPageShown(
                    story,
                    pageIndex,
                    pageHasLoading,
                    pageNavigationTrigger
                )
            },
            onPageAction: { [weak self] pageIndex, pageStatus, action, link, time in
                self?.output.onPageAction(
                    story,
                    pageIndex,
                    pageStatus,
                    action,
                    link,
                    time
                )
            },
            updateCurrentViewedPageIndex: { [weak self] currentStoryPageIndex in
                guard let self = self,
                      let story = self.input.stories[safe: self.selectedStoryIndex]
                else { return }
                
                self.output.updateCurrentViewedPageIndex(
                    story.id,
                    currentStoryPageIndex
                )
            },
            close: output.close
        )
        
        return viewController
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

// MARK: - UINavigationControllerDelegate
extension StoriesViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            return AnimationLeftRightSwipeStoriesController(transitionType: .presenting)
        } else if operation == .pop {
            return AnimationLeftRightSwipeStoriesController(transitionType: .dismissing)
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        return interactionController
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension StoriesViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        AnimationLeftRightSwipeStoriesController(transitionType: .presenting)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        AnimationLeftRightSwipeStoriesController(transitionType: .dismissing)
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
