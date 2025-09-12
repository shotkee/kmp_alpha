//
//  ActionHandlerFlow.swift
//  AlfaStrah
//
//  Created by vit on 05.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

// swiftlint:disable file_length
extension BDUI {
	class ActionHandlerFlow: AccountServiceDependency,
							 AlertPresenterDependency,
							 AnalyticsServiceDependency,
							 ApplicationSettingsServiceDependency,
							 BackendDrivenServiceDependency,
							 DependencyContainerDependency,
							 InsurancesServiceDependency,
							 LoggerDependency {
		var accountService: AccountService!
		var alertPresenter: AlertPresenter!
		var analytics: AnalyticsService!
		var applicationSettingsService: ApplicationSettingsService!
		var backendDrivenService: BackendDrivenService!
		var insurancesService: InsurancesService!
		var logger: TaggedLogger?
		
		var container: DependencyInjectionContainer?
		
		var initialViewController: UINavigationController
		
		init() {
			let navigationController = RMRNavigationController()
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			initialViewController = navigationController
		}
		
		// swiftlint:disable:next function_body_length
		func handleBackendEvents(
			_ events: EventsDTO,
			on viewController: ViewController,
			with screenId: String?,
			isModal: Bool,
			syncCompletion: (() -> Void)?
		) {
			// swiftlint:disable:next function_body_length cyclomatic_complexity
			container?.resolve(viewController)
			
			if let tapAction = events.onTap {
				print("action lock behaviour \(events.onTap?.lockBehavior?.rawValue) in method \(events.onTap?.type.rawValue)")
				
				handleAction(tapAction, events, on: viewController, isModal: isModal, syncCompletion: syncCompletion)
			}
			
			if let renderAction = events.onRender {
				print("action lock behaviour \(events.onRender?.lockBehavior?.rawValue) in method \(events.onRender?.type.rawValue)")
				
				handleAction(renderAction, events, on: viewController, isModal: isModal, syncCompletion: syncCompletion)
			}
		}
		
		func handleAction(
			_ action: BDUI.ActionDTO,
			_ events: BDUI.EventsDTO? = nil,
			on viewController: ViewController,
			isModal: Bool,
			syncCompletion: (() -> Void)?
		) {
			let lockCompletion = BDUI.CommonActionHandlers.shared.handleLockBehavior(for: action)
			
#if DEBUG
			print("bdui action \(action.name) execute")
#endif
			if let actionHandler = Self.selectActionHandler(for: action, in: self, isModal: isModal) {
				actionHandler(
					viewController,
					{ formDataToReplace in
						switch action.type {
							case .actionFlowOsagoSchemeAuto, .actionFlowOsagoPhotoUpload: // patching form data
								FormDataOperations.replaceFormData(
									for: events,
									with: formDataToReplace,
									action: { [weak viewController] eventSelector in
										guard let viewController,
											  let action = eventSelector.onTap
										else { return }
		
										self.handleAction(action, events, on: viewController, isModal: isModal, syncCompletion: syncCompletion)
									}
								)
							default:
								break
						}
					}
				) { [weak viewController] in
					lockCompletion?(nil)
					syncCompletion?()
					print("bdui action \(action.name) flow completion was called")
				}
				
				return
			}
			
			switch action.type {
				case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
					// NB! Do not handle actions here except actions for navigation or screen render
					break
					
				default:
					lockCompletion?(nil)
					syncCompletion?()
					
			}
		}
	}
}
// swiftlint:enable file_length
