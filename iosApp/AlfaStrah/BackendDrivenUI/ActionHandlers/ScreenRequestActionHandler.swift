//
//  ScreenRequestActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 05.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ScreenRequestActionHandler: ActionHandler<ScreenRequestActionDTO>,
									  AlertPresenterDependency,
									  AnalyticsServiceDependency,
									  BackendDrivenServiceDependency {
		var alertPresenter: AlertPresenter!
		var analytics: AnalyticsService!
		var backendDrivenService: BackendDrivenService!
		
		required init(
			block: ScreenRequestActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let request = self.block.request
				else {
					syncCompletion()
					return
				}
				
				self.showRequestBackendDrivenViewController(
					action: self.block,
					from: from,
					request: request,
					syncCompletion: syncCompletion
				)
			}
		}
		
		private func showRequestBackendDrivenViewController(
			action: BDUI.ActionDTO,
			from: ViewController,
			request: RequestComponentDTO,
			syncCompletion: (() -> Void)?
		) {
			guard let flow = self.flow
			else {
				syncCompletion?()
				return
			}
			
			func createController(with result: Result<ContentWithInfoMessage, AlfastrahError>, from: ViewController) {
				switch result {
					case .success(let data):
						if let infoMessage = data.infoMessage {
							BDUI.ViewControllerUtils.showInfoMessageViewController(
								with: infoMessage,
								from: from,
								retryOperationCallback: {
									self.backendDrivenService.bduiObject(
										needPostData: false,
										addTimezoneParameter: false,
										formData: nil,
										for: request,
										completion: { [weak from] result in
											guard let from
											else { return }
											
											createController(with: result, from: from)
										}
									)
								}
							)
						} else {
							let screen = ScreenComponentDTO(body: data.content)
							
							switch screen.showType {
								case .horizontal, .vertical, .none:
									let viewController = BDUI.ViewControllerUtils.createBasicBackendDrivenViewController(
										with: screen,
										use: backendDrivenService,
										use: analytics,
										backendActionSelectorHandler: { eventSelector, viewController in
											guard let viewController
											else { return }
											
											self.flow?.handleBackendEvents(
												eventSelector,
												on: viewController,
												with: screen.screenId,
												isModal: screen.showType == .vertical,
												syncCompletion: syncCompletion
											)
										},
										syncCompletion: syncCompletion
									)
									
									ViewControllerUtils.show(
										viewController,
										isModal: screen.showType ?? .vertical == .vertical,
										from: from,
										in: flow
									)
								case .modal:
									let screenViewController = BDUI.ViewControllerUtils.createModalBackendDrivenViewController(
										with: screen,
										backendActionSelectorHandler: { eventSelector, viewController in
											guard let viewController
											else { return }
											
											self.flow?.handleBackendEvents(
												eventSelector,
												on: viewController,
												with: screen.screenId,
												isModal: true,
												syncCompletion: syncCompletion
											)
										},
										syncCompletion: syncCompletion	// sync completion for screen call calling from didAppear
									) as? ActionSheetContentViewController
									
									if let screenViewController{
										let actionSheetViewController = ActionSheetViewController(with: screenViewController)
										actionSheetViewController.enableDrag = true
										actionSheetViewController.enableTapDismiss = false
										from.present(actionSheetViewController, animated: true)
									}
							}
						}
						
					case .failure(let error):
						switch error {
							case .api, .network, .error:
								ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
								
							case .infoMessage(let infoMessage):
								BDUI.ViewControllerUtils.showInfoMessageViewController(
									with: infoMessage,
									from: from,
									retryOperationCallback: {
										self.backendDrivenService.bduiObject(
											needPostData: false,
											addTimezoneParameter: false,
											formData: nil,
											for: request,
											completion: { [weak from] result in
												guard let from
												else { return }
												
												createController(with: result, from: from)
											}
										)
									}
								)
						}
				}
			}
			
			self.backendDrivenService.bduiObject(
				needPostData: action.postDataNeedToSend,
				addTimezoneParameter: false,
				formData: nil,
				for: request,
				completion: { result in
					syncCompletion?()
					
					if let topViewController = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.viewController as? ViewController {
						createController(with: result, from: from)
					} else {
						ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
					}
				}
			)
		}
	}
}
