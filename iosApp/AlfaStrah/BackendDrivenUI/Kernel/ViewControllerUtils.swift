//
//  ViewControllerUtils.swift
//  AlfaStrah
//
//  Created by vit on 24.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy
import UIKit

extension BDUI {
	enum ViewControllerUtils {
		// MARK: - Deprecated Dms method
		static func showBackendDrivenViewController(
			from: ViewController,
			for url: URL,
			with headers: [String: String],
			use backendDrivenService: BackendDrivenService,
			use analyticsService: AnalyticsService,
			backendActionSelectorHandler: @escaping (EventsDTO, ViewController?) -> Void,
			syncCompletion: (() -> Void)?,
			completion: @escaping () -> Void
		) {
			func show(_ viewController: ViewController, isModal: Bool) {
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
			
			backendDrivenService.backendDrivenData(url: url, headers: headers) { [weak from] result in
				completion()
				
				guard let from
				else { return }
				
				switch result {
					case .success(let data):
						if let screenBackendComponent = DataComponentDTO(body: data.content).screen {
							let viewController = ViewControllerUtils.createBasicBackendDrivenViewController(
								with: screenBackendComponent,
								use: backendDrivenService,
								use: analyticsService,
								backendActionSelectorHandler: backendActionSelectorHandler,
								syncCompletion: syncCompletion
							)
							
							show(viewController, isModal: screenBackendComponent.showType ?? .vertical == .vertical)
						}
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: from.alertPresenter)
						
				}
			}
		}
		
		static func createBasicBackendDrivenViewController(
			with screenBackendComponent: ScreenComponentDTO,
			use backendDrivenService: BackendDrivenService,
			use analyticsService: AnalyticsService,
			use logger: TaggedLogger? = nil,
			isRootController: Bool = false,
			tabIndex: Int? = nil,
			backendActionSelectorHandler: @escaping (EventsDTO, ViewController?) -> Void,
			syncCompletion: (() -> Void)?
		) -> ViewController {
			let viewController = ScreenBasicViewController()
			
			if let screenId = screenBackendComponent.screenId {
				if isRootController,
				   let tabIndex {
					ScreensHierarchyIndexing.initTabIfNeeded(tabIndex)
					
					ScreensHierarchyIndexing.tabs[tabIndex]
						.screensEntriesStack.push(
							ScreenEntry(screenId: screenId, viewController: viewController)
						)
				} else if !isRootController {
					if tabIndex == -1 {
						if ScreensHierarchyIndexing.floatingTab == nil {
							ScreensHierarchyIndexing.floatingTab = ScreensHierarchyIndexing.TabStack()
							ScreensHierarchyIndexing.setActiveTab(-1)
						}
						
						ScreensHierarchyIndexing.floatingTab?.screensEntriesStack.push(
							ScreenEntry(screenId: screenId, viewController: viewController)
						)
					} else {
						ScreensHierarchyIndexing.activeTab?.screensEntriesStack.push(
							ScreenEntry(screenId: screenId, viewController: viewController)
						)
					}
				}
			}
			
			print("instance viewController basic create \(String(describing: viewController))")
			
			viewController.input = .init(
				screenBasicBackendComponent: screenBackendComponent,
				pullToRefresh: { [weak viewController] render, completion in
					guard let url = render.url
					else {
						completion(.failure(AlfastrahError.unknownError))
						return
					}
					
					var headersDict: [String: String] = [:]
					
					if let renderHeaders = render.headers {
						for header in renderHeaders {
							if let headerName = header.header,
							   let headerValue = header.value {
								headersDict[headerName] = headerValue
							}
						}
					}
					
					backendDrivenService.backendDrivenData(url: url, headers: headersDict) { [weak viewController] result in
						guard let viewController
						else { return }
						
						switch result {
							case .success(let data):
								DispatchQueue.main.async { [weak viewController] in
									// reset LayoutOperationsBDUI data for screen
									if let screenId = screenBackendComponent.screenId {
										LayoutReplacementOperations.layoutEntries[screenId] = nil
										
										ScreensHierarchyIndexing.activeTab?.screensEntriesStack.pop()
									}
									
									if let screenBackendComponent = DataComponentDTO(body: data.content).screen {
										ScreensHierarchyIndexing.activeTab?.screensEntriesStack.push(
											ScreenEntry(screenId: screenBackendComponent.screenId ?? "", viewController: viewController)
										)
										
										viewController?.notify.reload(screenBackendComponent)
									}
									
									completion(.success(()))
								}
								
							case .failure(let error):
								completion(.failure(error))
						}
					}
				},
				isAppRootContoller: isRootController
			)
			
			viewController.output = .init(
				handleEvent: { [weak viewController] selector in
					guard let viewController
					else { return }
					
					backendActionSelectorHandler(selector, viewController)
					selector.onTap?.onSendAnalyticEvent(analyticsService, selector.onTap?.analyticEvent)
				},
				toChat: { [weak viewController] in
					guard let viewController
					else { return }
					
					let chatFlow = ChatFlow()
					ApplicationFlow.shared.container.resolve(chatFlow)
					chatFlow.show(from: viewController, mode: .fullscreen)
				},
				close: { [weak viewController] in
					switch screenBackendComponent.showType {
						case .vertical, .none, .modal:
							viewController?.dismiss(animated: true)
						case .horizontal:
							break
					}
				},
				loaded: {
					FormDataOperations.printPostData()
				},
				firstAppear: {
					syncCompletion?()
					LayoutReplacementOperations.printLayoutData(with: logger, tag: "layout replace")
				},
				desctructed: { [weak viewController] in
					if let screenId = screenBackendComponent.screenId {
						ScreensHierarchyIndexing.activeTab?.screensEntriesStack.storage.removeAll(where: { $0.screenId == screenId })
						LayoutReplacementOperations.layoutEntries[screenId] = nil
					}
					
					print("instance viewController \(String(describing: viewController)) deinit screenId \(screenBackendComponent.screenId)")
				}
			)
			
			return viewController
		}
		
		static func createModalBackendDrivenViewController(
			with screenBackendComponent: ScreenComponentDTO,
			backendActionSelectorHandler: @escaping (EventsDTO, ViewController?) -> Void,
			syncCompletion: (() -> Void)?
		) -> ViewController {
			let viewController = ScreenModalViewController()
			
			if let screenId = screenBackendComponent.screenId {
				ScreensHierarchyIndexing.activeTab?.screensEntriesStack.push(ScreenEntry(screenId: screenId, viewController: viewController))
			}
			
			print("instance viewController modal create \(String(describing: viewController))")
			
			viewController.input = .init(
				screenBackendComponent: screenBackendComponent
			)
			
			viewController.output = .init(
				handleEvent: { [weak viewController] selector in
					guard let viewController
					else { return }
					
					backendActionSelectorHandler(selector, viewController)
				},
				toChat: { [weak viewController] in
					guard let viewController
					else { return }
					
					let chatFlow = ChatFlow()
					ApplicationFlow.shared.container.resolve(chatFlow)
					chatFlow.show(from: viewController, mode: .fullscreen)
				},
				close: { [weak viewController] in
					viewController?.dismiss(animated: true)
				},
				loaded: {
					FormDataOperations.printPostData()
				},
				appeared: {
					syncCompletion?()
				},
				destructed: { [weak viewController] in
					if let screenId = screenBackendComponent.screenId {
						ScreensHierarchyIndexing.activeTab?.screensEntriesStack.storage.removeAll(where: { $0.screenId == screenId })
						LayoutReplacementOperations.layoutEntries[screenId] = nil
					}
					
					print("instance viewController \(String(describing: viewController)) deinit screenId \(screenBackendComponent.screenId)")
				}
			)
			
			return viewController
		}
		
		static func insertActivityIndicator(to view: UIView) -> UIView {
			var visibleSuperViewHeight: CGFloat = 0
			
			let containerView = UIView()
			containerView.backgroundColor = .Background.background.withAlphaComponent(0.6)
			
			view.addSubview(containerView)
			containerView.edgesToSuperview()
			
			let viewBounds = view.bounds
			
			if let window = UIApplication.shared.windows.first {
				let safeAreaBottom = window.safeAreaInsets.bottom
				
				let superviewFrameInWindowSpace = view.convert(viewBounds, to: window)
				
				let superviewHeightInWindowSpace = window.bounds.height - superviewFrameInWindowSpace.origin.y
				
				visibleSuperViewHeight = min(viewBounds.height, superviewHeightInWindowSpace - safeAreaBottom)
			}
			
			let activityIndicatorView = ActivityIndicatorView(frame: .zero)
			activityIndicatorView.clearBackgroundColor()
			
			containerView.addSubview(activityIndicatorView)
			
			let indicatorViewHeight = min(viewBounds.height - viewBounds.height * 0.2, Constants.replacementIndicatorHeightMax)
			
			activityIndicatorView.height(indicatorViewHeight)
			activityIndicatorView.widthToHeight(of: activityIndicatorView)
			
			activityIndicatorView.topToSuperview(offset: visibleSuperViewHeight * 0.5 - indicatorViewHeight)
			activityIndicatorView.centerXToSuperview()
			
			activityIndicatorView.animating = true
			
			return containerView
		}
		
		// MARK: - Info Message
		static func showInfoMessageViewController(
			with infoMessage: InfoMessage,
			from: ViewController,
			retryOperationCallback: @escaping () -> Void
		) {
			let viewController = InfoMessageViewController()
			
			from.container?.resolve(viewController)
			
			viewController.input = .init(infoMessage: infoMessage)
			
			viewController.output = .init(
				close: { [weak viewController] in
					guard let viewController
					else { return }
					
					ViewControllerUtils.close(infoMessageViewController: viewController) {}
				},
				retry: { [weak viewController] in
					guard let viewController
					else { return }
					
					ViewControllerUtils.retry(
						isModal: from.navigationController == nil,
						infoMessageViewController: viewController
					) {
						retryOperationCallback()
					}
				},
				toChat: {
					ApplicationFlow.shared.show(item: .tabBar(.chat))
				}
			)
			
			viewController.title = from.title
			
			if let navigationController = from.navigationController {
				navigationController.pushViewController(viewController, animated: true)
			} else {
				// show navigation bar anyway
				let navigationController = RMRNavigationController(rootViewController: viewController)
				navigationController.strongDelegate = RMRNavigationControllerDelegate()
				
				viewController.addCloseButton(position: .right) { [weak viewController] in
					viewController?.dismiss(animated: true)
				}
				
				from.present(
					navigationController,
					animated: true
				)
			}
		}
		
		private static func close(infoMessageViewController: ViewController, completion: @escaping () -> Void) {
			if let navigationController = infoMessageViewController.navigationController {
				navigationController.popViewController(animated: true)
			} else {
				infoMessageViewController.dismiss(animated: true)
			}
		}
		
		private static func retry(
			isModal: Bool,
			infoMessageViewController: ViewController,
			completion: @escaping () -> Void
		) {
			if isModal {
				infoMessageViewController.dismiss(animated: true) {
					completion()
				}
			} else {
				infoMessageViewController.navigationController?.popViewController(animated: true)
				completion()
			}
		}
		
		static func show(_ viewController: ViewController, isModal: Bool, from: ViewController, in flow: ActionHandlerFlow) {
			func showModally() {
				let navigationController = RMRNavigationController()
				navigationController.strongDelegate = RMRNavigationControllerDelegate()
				
				navigationController.setViewControllers([ viewController ], animated: true)
				from.present(navigationController, animated: true, completion: nil)
			}
			
			if isModal {
				showModally()
			} else {
				if flow.initialViewController == from.navigationController { // over tabbar
					showModally()
				} else {
					from.navigationController?.pushViewController(viewController, animated: true)
				}
			}
		}
		
		// MARK: - Constants
		struct Constants {
			static let replacementIndicatorHeightMax: CGFloat = 82
		}
	}
}
