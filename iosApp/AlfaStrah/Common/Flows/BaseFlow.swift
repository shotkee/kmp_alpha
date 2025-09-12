//
//  BaseFlow.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

enum ViewControllerShowMode {
    case modal
    case push
}

// fix opening menu when long press in navigation bar back button
//	https://forums.developer.apple.com/forums/thread/653913?answerId=634040022#634040022
class BackBarButtonItem: UIBarButtonItem {
	// long press menu available only in IOS 14
	@available(iOS 14.0, *)
	override var menu: UIMenu? {
		set {
		  // Don't set the menu here for fix this long press menu problem
		}
		get {
			return super.menu
		}
	}
}

class BaseFlow: DependencyContainerDependency, AlertPresenterDependency, LoggerDependency, AnalyticsServiceDependency {
    var container: DependencyInjectionContainer?
    var alertPresenter: AlertPresenter!
    var logger: TaggedLogger?
    var analytics: AnalyticsService!

    weak var fromViewController: UIViewController!
    weak var navigationController: UINavigationController?
    var topModalController: UIViewController {
        UIHelper.findTopModal(controller: fromViewController)
    }
    var ownNavigationController: Bool = false
    let iPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

    required init(rootController: UIViewController) {
        fromViewController = rootController
    }

    deinit {
        logger?.debug("")
    }

    // MARK: - Navigation

    @discardableResult
    func createAndShowNavigationController(
        viewController: UIViewController?,
        mode: ViewControllerShowMode,
		showBackButton: Bool = true,
        asInitial isInitial: Bool = false,
        animated: Bool = true
    ) -> UINavigationController {
        switch mode {
            case .push:
				let backButton = BackBarButtonItem(
					image: .Icons.chevronLargeLeft,
					style: .plain,
					target: self,
					action: #selector(popViewController)
				)
				
				if let viewController, showBackButton {
					viewController.navigationItem.leftBarButtonItem = backButton
				}

                if let navigationController = navigationController {
                    if let viewController = viewController {
                        if isInitial {
                            navigationController.setViewControllers(
                                [ viewController ],
                                animated: animated
                            )
                        } else {
                            navigationController.pushViewController(viewController, animated: animated)
                        }
                    }
                    return navigationController
                } else if let navigationController = fromViewController?.navigationController {
                    self.navigationController = navigationController
					
                    if let viewController = viewController {
                        if isInitial {
                            navigationController.setViewControllers(
                                [ viewController ],
                                animated: animated
                            )
                        } else {
                            navigationController.pushViewController(
                                viewController, animated: animated
                            )
                        }
                    }
                    ownNavigationController = false
                    return navigationController
                } else {
                    return presentController(viewController, animated: animated)
                }
            case .modal:
                return presentController(viewController, animated: animated)
        }
    }
	
	@objc private func popViewController() {
		navigationController?.popViewController(animated: true)
	}

    @discardableResult
    private func presentController(
        _ viewController: UIViewController?,
        animated: Bool = true
    ) -> UINavigationController {
        let navigationController = RMRNavigationController()
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        if let viewController = viewController {
            navigationController.viewControllers = [ viewController ]
        }
        if let topController = self.navigationController?.topViewController {
            topController.present(navigationController, animated: animated, completion: nil)
        } else {
            self.navigationController = navigationController
            fromViewController?.present(navigationController, animated: animated, completion: nil)
        }
        ownNavigationController = true
        
        return navigationController
    }

    func close(completion: (() -> Void)? = nil) {
        if ownNavigationController {
            navigationController?.dismiss(animated: true, completion: completion)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func showError(_ error: Error)
    {
        ErrorHelper.show(
            error: error,
            alertPresenter: alertPresenter
        )
    }
}
