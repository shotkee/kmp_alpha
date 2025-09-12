//
//  ActionHandlers.swift
//  AlfaStrah
//
//  Created by vit on 19.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

import Legacy
import UIKit

extension BDUI {
	class CommonActionHandlers: NSObject,
								AlertPresenterDependency,
								AnalyticsServiceDependency,
								BackendDrivenServiceDependency {
		var alertPresenter: AlertPresenter!
		var analytics: AnalyticsService!
		var backendDrivenService: BackendDrivenService!
		
		static let shared = CommonActionHandlers()
		
		var container: DependencyInjectionContainer?
		
		typealias LockCompletion = ((_ completion: (() -> Void)?) -> Void)
		
		private var lockCompletion: LockCompletion?
		
		// MARK: - Lock Behavior
		func handleLockBehavior(for action: ActionDTO) -> LockCompletion? {
			if let from = ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.viewController as? ViewController,
			   let lockBehaviour = action.lockBehavior {
				
				switch lockBehaviour {
					case .disableElement:
#if DEBUG
						print("bdui action lock behaviour disable element - action request")
#endif
						return nil
						
					case .disableScreen:
#if DEBUG
						print("bdui action lock behaviour disable screen - action request")
#endif
						from.view.isUserInteractionEnabled = false
						return { [weak from] (_ completion: (() -> Void)?) -> Void in
							from?.view.isUserInteractionEnabled = true
						}
						
					case .screenLoader:
#if DEBUG
						print("bdui action lock behaviour show indicator - action request")
#endif
						from.view.isUserInteractionEnabled = false
						let indicatorComplectionCallback = from.showLoadingIndicator(message: nil, withDelay: 0.3)
						
						return { [weak from] (_ completion: (() -> Void)?) -> Void in
							from?.view.isUserInteractionEnabled = true
							indicatorComplectionCallback(completion)
#if DEBUG
							print("bdui action lock behaviour show indicator - action request - removed")
#endif
						}
				}
			}
			
			return nil
		}
		
		// MARK: - Action Request
		func handleActionRequest(
			_ action: ActionDTO,
			_ request: RequestComponentDTO,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.lockCompletion = handleLockBehavior(for: action)
			
			self.backendDrivenService.bduiObject(
				needPostData: action.postDataNeedToSend,
				addTimezoneParameter: false,
				formData: ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData,
				for: request,
				completion: { result in
					self.handleActionRequestResult(
						action,
						request,
						result,
						handleEvent: { action in
#if DEBUG
							print("bdui action lock behaviour show indicator - action request - completed")
#endif
							self.lockCompletion?(nil)
							handleEvent(action)
						}
					)
				}
			)
		}
		
		private func handleActionRequestResult(
			_ action: ActionDTO,
			_ request: RequestComponentDTO,
			_ result: Result<ContentWithInfoMessage, AlfastrahError>,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			switch result {
				case .success(let data):
					if let action: ActionDTO = BDUI.ComponentDTO.mapData(from: data.content) {
						let events = EventsDTO(onTap: action, onRender: nil, onChange: nil)
						
						handleEvent(events)
					} else {
						ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
					}
					
				case .failure(let error):
					switch error {
						case .api, .network, .error:
							ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
							
						case .infoMessage(let infoMessage):
							print("info message utils fired")
							
							guard let from = UIHelper.topViewController() as? ViewController
							else { return }
							
							ViewControllerUtils.showInfoMessageViewController(
								with: infoMessage,
								from: from,
								retryOperationCallback: {
									CommonActionHandlers.shared.handleActionRequest(
										action,
										request,
										handleEvent: handleEvent
									)
								}
							)
					}
			}
		}
		
		// MARK: - Navigate To
		func navigateBack(to screenId: String, completion: @escaping () -> Void) {
			if let targetViewController = ScreensHierarchyIndexing.activeTab?.screensEntriesStack
				.storage.first(where: { $0.screenId == screenId })?.viewController {
				
				/// dismiss all presented controllers by target controller
				if targetViewController.presentedViewController != nil{
					targetViewController.dismiss(animated: true) {
						completion()
					}
					return
				} else {
					ScreensHierarchyIndexing.printScreenStack()
					Self.modifyNavigationStackIfNeeded(for: targetViewController)
					completion()
					return
				}
			}
			
			// MARK: - Backend Issue - check screenID "main" when OSAGO event BDUI started from native main screen
			if screenId == "main" {
				ApplicationFlow.shared.show(item: .tabBar(.home))
				reset()
				ScreensHierarchyIndexing.activeTabIndex = 0
			}
		}
		
		private static func modifyNavigationStackIfNeeded(for targetViewController: UIViewController) {
			if let navigationController = targetViewController.navigationController {
				var viewControllers = navigationController.viewControllers
				
				for viewController in viewControllers.reversed() {
					if ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.viewController === viewController {
						ScreensHierarchyIndexing.activeTab?.screensEntriesStack.pop()
					}
					
					viewControllers.removeLast()
					
					if targetViewController === ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.viewController {
						break
					}
				}
				
				navigationController.setViewControllers(viewControllers, animated: true)
			}
		}
		
		// MARK: - Screen Replace
		func replace(
			screen: () -> ScreenComponentDTO?,
			forScreenId screenId: String?,
			logger: TaggedLogger? = nil
		) {
			if screenId == nil,
			   let activeTab = ScreensHierarchyIndexing.activeTab,
			   let topScreenId = activeTab.topBackendScreenScreenId {
				LayoutReplacementOperations.layoutEntries[topScreenId] = nil
				let screenStackIndex = activeTab.screensEntriesStack.storage.count - 1
				
				reload(screen: screen, for: screenStackIndex)
			} else if let screenId,
					  let screenStackIndex = ScreensHierarchyIndexing.activeTab?.screensEntriesStack.storage
				.firstIndex(where: { $0.screenId == screenId }) {
				LayoutReplacementOperations.layoutEntries[screenId] = nil
				
				reload(screen: screen, for: screenStackIndex)
			}
			
			LayoutReplacementOperations.printLayoutData(with: logger, tag: "screen replace")
			FormDataOperations.printPostData()
		}
		
		private func reload(screen: () -> ScreenComponentDTO?, for screenStackIndex: Int) {
			guard let screenComponent = screen(),
				  let storage = ScreensHierarchyIndexing.activeTab?.screensEntriesStack.storage[screenStackIndex]
			else { return }
			
			if let viewController = storage.viewController as? ScreenBasicViewController {
				ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData = nil
				viewController.notify.reload(screenComponent)
			} else if let viewController = storage.viewController as? ScreenModalViewController {
				ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData = nil
				viewController.notify.reload(screenComponent)
			}
			
			let reloadedScreenId = screenComponent.screenId ?? UUID().uuidString
			
			ScreensHierarchyIndexing.activeTab?.screensEntriesStack.storage[screenStackIndex].screenId = reloadedScreenId
		}
		
		// MARK: - Reset
		func reset() {
			LayoutReplacementOperations.layoutEntries = [:]
			ScreensHierarchyIndexing.tabs = []
			ScreensHierarchyIndexing.floatingTab = nil
		}
		
		// MARK: - Alert
		func showAlert(
			_ alert: AlertComponentDTO,
			actionHandler: @escaping (ActionDTO) -> Void
		) {
			guard let viewControlller = ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.viewController
			else { return }
			
			let actionSheet = UIAlertController(
				title: alert.title,
				message: alert.description,
				preferredStyle: .alert
			)
			
			if let buttons = alert.buttons {
				buttons.forEach { alertButton in
					actionSheet.addAction(
						UIAlertAction(
							title: alertButton.title,
							style: {
								switch $0.style {
									case .`default`, .none:
										return .default
										
									case .destructive:
										return .destructive
										
									case .cancel:
										return .cancel
										
								}
							} (alertButton),
							handler: { _ in
								guard let action = alertButton.action
								else { return }
								
								actionHandler(action)
							}
						)
					)
				}
			}
			
			viewControlller.present(
				actionSheet,
				animated: true
			)
		}
		
		// MARK: - Floating screen
		func showFloatingScreen(
			with sreenBackendComponent: ScreenComponentDTO?,
			from: ViewController,
			backendActionSelectorHandler: @escaping (EventsDTO, ViewController?) -> Void
		) {
			if let screenBackendComponent = sreenBackendComponent {
				let screenViewController = ViewControllerUtils.createBasicBackendDrivenViewController(
					with: screenBackendComponent,
					use: self.backendDrivenService,
					use: self.analytics,
					tabIndex: -1,
					backendActionSelectorHandler: backendActionSelectorHandler,
					syncCompletion: nil
				)
				
				CommonActionHandlers.show(
					screenViewController,
					from: from,
					isModal: screenBackendComponent.showType == .vertical
				)
			}
		}
		
		private static func show(_ viewController: ViewController, from: ViewController, isModal: Bool) {
			if isModal {
				let navigationController = RMRNavigationController()
				navigationController.strongDelegate = RMRNavigationControllerDelegate()
				
				navigationController.setViewControllers([ viewController ], animated: true)
				from.present(navigationController, animated: true, completion: nil)
			} else {
				if let navigationController = from.navigationController {
					navigationController.pushViewController(viewController, animated: true)
				}
			}
		}
	}
}
