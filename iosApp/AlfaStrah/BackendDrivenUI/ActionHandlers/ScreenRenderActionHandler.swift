//
//  ScreenRenderActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 05.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ScreenRenderActionHandler: ActionHandler<ScreenRenderActionDTO>,
									 AlertPresenterDependency,
									 AnalyticsServiceDependency,
									 BackendDrivenServiceDependency {
		var alertPresenter: AlertPresenter!
		var analytics: AnalyticsService!
		var backendDrivenService: BackendDrivenService!
		
		required init(
			block: ScreenRenderActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let flow = self.flow,
					  let screen = self.block.screen?()
				else {
					syncCompletion()
					return
				}

				if BackendComponentType.screenBottomToolbar == screen.type
					|| BackendComponentType.screenBasic == screen.type  {

					let screenViewController = BDUI.ViewControllerUtils.createBasicBackendDrivenViewController(
						with: screen,
						use: self.backendDrivenService,
						use: self.analytics,
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
						syncCompletion: syncCompletion// sync completion for screen call calling from didAppear
					)

					ViewControllerUtils.show(screenViewController, isModal: screen.showType == .vertical, from: from, in: flow)
				} else {
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
		}
	}
}
