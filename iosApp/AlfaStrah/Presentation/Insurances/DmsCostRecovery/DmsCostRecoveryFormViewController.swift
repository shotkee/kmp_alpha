//
//  DmsCostRecoveryFormViewController.swift
//  AlfaStrah
//
//  Created by vit on 27.12.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryFormViewController: ViewController {
    @IBOutlet private var pagesProgressBarView: PagesProgressBarView!
    @IBOutlet private var pageControllerContainerView: UIView!
    
    private var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    private var currentViewControllerIndex: Int = 0
    
    struct Input {
        let viewControllers: [UIViewController]
    }
    
    var input: Input!
    
    override func viewDidLoad() {
		view.backgroundColor = .Background.backgroundContent
        super.viewDidLoad()
                
        pagesProgressBarView.buildItems(count: input.viewControllers.count)
        pagesProgressBarView.setIndex(self.currentViewControllerIndex)
        
        title = NSLocalizedString("dms_cost_recovery", comment: "")
        
        addChild(pageViewController)
		pageControllerContainerView.backgroundColor = .Background.backgroundContent
        pageControllerContainerView.addSubview(pageViewController.view)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: pageViewController.view, in: pageControllerContainerView)
        )
        
        guard let firstPage = input.viewControllers.first
        else { return }
        
        pageViewController.setViewControllers([firstPage], direction: .forward, animated: false, completion: nil)
    }
        
    func showNextPage() {
        guard let viewController = self.input.viewControllers[safe: self.currentViewControllerIndex + 1]
        else { return }

        self.currentViewControllerIndex += 1
        pagesProgressBarView.setIndex(self.currentViewControllerIndex)
        
        pageViewController.setViewControllers(
            [viewController],
            direction: .forward,
            animated: true,
            completion: nil
        )
    }
    
    func showPreviousPage() {
        guard let viewController = self.input.viewControllers[safe: self.currentViewControllerIndex - 1]
        else { return }

        self.currentViewControllerIndex -= 1
        pagesProgressBarView.setIndex(self.currentViewControllerIndex)
        
        pageViewController.setViewControllers(
            [viewController],
            direction: .reverse,
            animated: true,
            completion: nil
        )
    }
    
    func getCurrentPageIndex() -> Int {
        return self.currentViewControllerIndex
    }
}
