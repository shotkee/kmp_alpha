//
//  LoyaltyFlow.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 5/20/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy
import UIKit

class LoyaltyFlow: DependencyContainerDependency, AlertPresenterDependency, LoggerDependency, AnalyticsServiceDependency,
        AccountServiceDependency, LoyaltyServiceDependency {
    enum Constants {
        static let alfaPointsProgramDetailsURL = "http://alfapoints.alfastrah.ru"
    }

    var container: DependencyInjectionContainer?
    var alertPresenter: AlertPresenter!
    var logger: TaggedLogger?
    var analytics: AnalyticsService!
    var accountService: AccountService!
    var loyaltyService: LoyaltyService!

    private weak var initialViewController: UINavigationController?
    private let storyboard = UIStoryboard(name: "Loyalty", bundle: nil)

    deinit {
        logger?.debug("")
    }

    func startModally(from controller: UIViewController) {
        let navigationController = RMRNavigationController()
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        initialViewController = navigationController
        
        guard let initialViewController = initialViewController
        else { return }
        
        makeLoyaltyController(from: initialViewController) {
            [weak initialViewController, weak controller] viewController in
            guard let controller = controller,
                  let initialViewController = initialViewController
            else { return }
            
            initialViewController.setViewControllers([ viewController ], animated: false)
            controller.present(initialViewController, animated: true)
        }
    }

    private func makeLoyaltyController(
        from viewController: UIViewController,
        completion: @escaping (UIViewController) -> Void
    ) {
        guard accountService.isAuthorized
        else { return }
        
        let hide = viewController.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title",
            comment: "")
        )
        accountService.getAccount(useCache: true) { [weak viewController] result in
            hide(nil)
            
            guard let viewController = viewController
            else { return }
            
            switch result {
                case .success(let userAccount):
                    let loyaltyInfoController: LoyaltyInfoController = self.storyboard.instantiate()
                    self.container?.resolve(loyaltyInfoController)
                    loyaltyInfoController.input = .init(
                        accountId: userAccount.id,
                        alfaPoints: { useCache, completion in
                            self.loyaltyService.loyalty(useCache: useCache) { completion($0) }
                        },
                        infoBlocks: { completion in
                            self.loyaltyService.loyaltyBlock { result in
                                completion(result)
                            }
                        },
                        infoBlockLink: { id, completion in
                            self.loyaltyService.getBlockLink(blockId: id) { result in
                                completion(result)
                            }
                        }
                    )
                    loyaltyInfoController.output = .init(
                        programDetails: { [weak loyaltyInfoController] in
                            guard let loyaltyInfoController = loyaltyInfoController
                            else { return }

                            self.openURL(url: Constants.alfaPointsProgramDetailsURL, fromViewController: loyaltyInfoController)
                        },
                        promoAction: { [weak loyaltyInfoController] newsItem in
                            guard
                                let loyaltyInfoController = loyaltyInfoController,
                                let newsItem = newsItem as? ActionNewsItemModel
                            else { return }

                            newsItem.action(loyaltyInfoController)
                        },
                        details: self.showDetails,
                        openURL: { url, viewController in self.openURL(url: url, fromViewController: viewController) }
                    )
                    loyaltyInfoController.addCloseButton {
                        viewController.presentingViewController?.dismiss(animated: true)
                    }
                    
                    completion(loyaltyInfoController)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func showDetails() {
        let viewController: LoyaltyHistoryViewController = .init()
        viewController.input = .init(
            loyaltyOperations: { count, offset, completion in
                self.loyaltyService.loyaltyOperations(count: count, offset: offset, completion: completion)
            }
        )
        initialViewController?.pushViewController(viewController, animated: true)
    }

    private func openURL(url: String, fromViewController: UIViewController) {
        SafariViewController.open(url, from: fromViewController)
    }
}
