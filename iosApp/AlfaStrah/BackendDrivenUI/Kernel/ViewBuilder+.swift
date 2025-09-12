//
//  ViewBuilder+.swift
//  AlfaStrah
//
//  Created by vit on 24.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI.ViewBuilder {
	// swiftlint:disable:next function_body_length
	// MARK: - Build Widget
	static func buildWidget<T: BDUI.Widget>(
		_ widgetDto: BDUI.WidgetDTO,
		layoutContentInset: CGFloat = 0,
		indexFormData: Bool = true,
		handleEvent: @escaping (BDUI.EventsDTO) -> Void,
		for _: T.Type
	) -> UIView? {
		guard let obj = widgetDto as? T.W
		else { return nil }
		
		if let onRenderAction = widgetDto.events?.onRender {
			BDUI.ViewBuilder.shared.logger?.debug("render event \(onRenderAction)")
			
			BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.subscribeForRender {
				let screenId = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.screenId
				let actionName = widgetDto.events?.onRender?.name
				
				BDUI.ViewBuilder.shared.logger?.debug("render event on screen id \(screenId) with action \(actionName)")
				
				handleEvent(BDUI.EventsDTO(onTap: nil, onRender: onRenderAction, onChange: nil))
			}
		}
			
		let consumeEventWithFormData = { (_ events: BDUI.EventsDTO) -> Void in
			guard let action = events.onTap as? BDUI.ActionRequestActionDTO,
				  let request = action.request
			else {
				handleEvent(events)
				return
			}
			
			switch action.type {
				case .actionActionRequest:
					BDUI.CommonActionHandlers.shared.handleActionRequest(
						action,
						request,
						handleEvent: handleEvent
					)
					
				default:
					handleEvent(events)
					
			}
		}
				
		let blockView = T.init(
			block: obj,
			horizontalInset: layoutContentInset,
			handleEvent: consumeEventWithFormData
		)
		
		switch widgetDto.type {
			case .widgetTextButtonCheckbox:
				break
			default:
				if indexFormData {
					Self.addFormDataToCurrentScreenEntry(from: widgetDto)
				}
		}
		
		return Self.createContainerView(
			insets: UIEdgeInsets(top: widgetDto.paddingTop ?? 0, left: 0, bottom: widgetDto.paddingBottom ?? 0, right: 0),
			blockView: blockView
		)
	}
	
	// MARK: - StoriesWidget
	func storiesWidget(
		_ block: BDUI.StoriesWidgetDTO,
		layoutContentInset: CGFloat = 0,
		handleEvent: @escaping (BDUI.EventsDTO) -> Void
	) -> UIView {
		let blockView = BDUI.StoriesWrapperView(
			block: block,
			horizontalInset: layoutContentInset,
			handleEvent: handleEvent
		)
		
		ApplicationFlow.shared.container.resolve(blockView)
		
		blockView.requestStories()
		
		guard let paddingTop = block.paddingTop,
			  let paddingBottom = block.paddingBottom
		else { return blockView }
		
		return Self.createContainerView(
			insets: UIEdgeInsets(top: paddingTop, left: 0, bottom: paddingBottom, right: 0),
			blockView: blockView
		)
	}
		
	private static func createContainerView(
		insets: UIEdgeInsets,
		blockView: UIView,
		spacerColor: UIColor = DebugMenu.shared.debugBDUI ? .red.withAlphaComponent(CGFloat(Float.random(in: 0.1..<0.5))) : .clear
	) -> UIView {
		let paddingView = UIView()
		
		if DebugMenu.shared.debugBDUI {
			if insets.top != 0 {
				let topPaddingView = UIView()
				topPaddingView.backgroundColor = spacerColor
				paddingView.addSubview(topPaddingView)
				
				topPaddingView.edgesToSuperview(excluding: .bottom)
				topPaddingView.height(insets.top)
			}
			
			if insets.bottom != 0 {
				let bottomPaddingView = UIView()
				bottomPaddingView.backgroundColor = spacerColor
				paddingView.addSubview(bottomPaddingView)
				
				bottomPaddingView.edgesToSuperview(excluding: .top)
				bottomPaddingView.height(insets.bottom)
			}
		}
		
		paddingView.addSubview(blockView)
		
		blockView.edgesToSuperview(insets: insets)
		
		return paddingView
	}
	
	private static func addFormDataToCurrentScreenEntry(from widget: BDUI.WidgetDTO) {
		guard let formDataEntry = widget.formData
		else { return }
		
		if BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData == nil {
			BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData = [formDataEntry]
		} else {
			BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData?.append(formDataEntry)
		}
	}
	
	// MARK: - Build Layout
	static func buildLayout<T: BDUI.Widget>(
		_ layoutDto: BDUI.LayoutDTO,
		with externalScreenId: String? = nil,
		layoutContentInset: CGFloat = 0,
		handleEvent: @escaping (BDUI.EventsDTO) -> Void,
		for _: T.Type
	) -> UIView? {
		guard let obj = layoutDto as? T.W
		else { return nil }
		
		if let onRenderAction = layoutDto.events?.onRender {
			BDUI.ViewBuilder.shared.logger?.debug("render event \(onRenderAction)")
			
			let renderAction = onRenderAction.type
			// TODO: handle lockBehaviour on render event
			BDUI.ViewBuilder.shared.logger?.debug("action lock behaviour \(onRenderAction.lockBehavior?.rawValue) in method \(renderAction)")

			
			BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.subscribeForRender {
				let screenId = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.screenId
				let actionName = layoutDto.events?.onRender?.name
				
				BDUI.ViewBuilder.shared.logger?.debug("render event on screen id \(screenId) with action \(actionName)")
				handleEvent(BDUI.EventsDTO(onTap: nil, onRender: onRenderAction, onChange: nil))
			}
		}
			
		let consumeLayoutAction = { (_ events: BDUI.EventsDTO) -> Void in
			var activityIndicatorContainerView: UIView?
			
			if let tapAction = events.onTap,
			   let lockBehaviour = tapAction.lockBehavior{
				switch lockBehaviour {
					case .disableElement:
						BDUI.ViewBuilder.shared.logger?.debug("action lock behaviour start spining on element \(tapAction.targetLayoutId) screenId \(tapAction.targetScreenId)")
						
						let currentScreenId: String? = externalScreenId != nil
							? externalScreenId
							: BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId
						
						if	let currentScreenId,
							let layoutId = tapAction.targetLayoutId,
							let containerView = BDUI.LayoutReplacementOperations.layoutEntries[currentScreenId]?[layoutId]?.containerView {
							
							activityIndicatorContainerView = BDUI.ViewControllerUtils.insertActivityIndicator(to: containerView)
						}
						
					case .disableScreen, .screenLoader:
						break
						
				}
			}
				
			func consume(_ action: BDUI.ActionDTO) {
				BDUI.ViewBuilder.shared.logger?.debug("action type \(action.type.rawValue)")
				
				switch action.type {
					case .actionActionRequest:
						if let action = action as? BDUI.ActionRequestActionDTO,
						   let request = action.request {
							BDUI.CommonActionHandlers.shared.handleActionRequest(
								action,
								request,
								handleEvent: handleEvent
							)
						}
						
					case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
						self.consumeLayoutActions(action, for: handleEvent, activityIndicatorContainerView: activityIndicatorContainerView)
						
					case .actionAlert:
						if let action = action as? BDUI.AlertActionDTO,
						   let alert = action.alert {
							BDUI.CommonActionHandlers.shared.showAlert(
								alert,
								actionHandler: { action in
									consume(action)
								}
							)
						}
						
					case .actionMulti:
						if let multiAction = action as? BDUI.MultipleActionsActionDTO,
						   let actions = multiAction.actions {
							
							if actions.isEmpty {
								handleEvent(events)
								return
							}
							
							// for "synchronous operations" queue it is necessary to restore the initial order of processing actions
							// since asynchronous processing implies performing action in "consuming" handler before handling that action in flow
							// also a synchronous operation must call a synchronous callback so the next sync operation can be launched
							for (index, action) in actions.enumerated() {
								if let mode = action.mode {
									switch action.type {
										case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
											BDUI.ActionExecutionSynchronization.proceed(
												priority: index,
												with: mode,
												actionName: action.name ?? "undefined",
												action: { syncCompletion in
													switch action.type {
														case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
															self.consumeLayoutActions(action, for: handleEvent, syncCompletion: syncCompletion)
															
														default:
															break
													}
												}
											)
											
										default:
											break
									}
								}
								
								if index == actions.endIndex - 1 {
									switch action.type {
										case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
											handleEvent(events)
											BDUI.ActionExecutionSynchronization.startActions()
											
										default:
											handleEvent(events)
											
									}
								}
							}
						}
							
						default:
							handleEvent(events)
				}
			}
			
			if let action = events.onTap {
				consume(action)
			}
			
			if let action = events.onRender {
				consume(action)
			}
		}
		
		func createLayout() -> UIView {
			let layoutView = T.init(
				block: obj,
				horizontalInset: layoutContentInset,
				handleEvent: { events in
					consumeLayoutAction(events)
				}
			)
			
			return Self.embed(
				externalScreenId,
				layoutDto,
				layoutView,
				with: layoutContentInset,
				handleEvent: consumeLayoutAction
			)
		}
			
		let currentScreenId: String? = externalScreenId != nil
			? externalScreenId
			: BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId
		
		if let tags = layoutDto.tags,
		   let currentFilteredLayoutId = BDUI.LayoutReplacementOperations.currentFilteredLayoutId,
		   let currentScreenId,
		   let filterTag = BDUI.LayoutReplacementOperations.layoutEntries[currentScreenId]?[currentFilteredLayoutId]?.willShownByTag {
			if tags.contains(filterTag) {
				return createLayout()
			} else {
				return UIView()
			}
		} else {
			return createLayout()
		}
	}
	
	private func handleReplaceOperation(
		_ externalScreenId: String? = nil,
		_ layoutId: String,
		_ layoutDto: BDUI.LayoutDTO,
		handleEvent: @escaping (BDUI.EventsDTO) -> Void
	) {
		// reset filter for current layout operations
		if let externalScreenId,
		   BDUI.LayoutReplacementOperations.layoutEntries[externalScreenId] != nil {
			BDUI.LayoutReplacementOperations.currentFilteredLayoutId = nil
		} else {
			if let screenId = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId{
				BDUI.LayoutReplacementOperations.currentFilteredLayoutId = nil
			}
		}
		
		guard let screenId = externalScreenId ?? BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId,
			  let containerView = BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[layoutId]?.containerView
		else { return }
		
		var replaceableLayoutId: String?
		
		if let layoutReplaces = BDUI.LayoutReplacementOperations.layoutEntries[BDUI.LayoutReplacementOperations.Constants.currentReplacementsKey]?.reversed(),
		   !layoutReplaces.isEmpty {
			// check if root layoutId should replace existing one with other layoutId
			if let rootReplace = layoutReplaces.first?.value,
			   let targetLayoutId = rootReplace.layoutParsedDictionary?[BDUI.LayoutDTO.Key.layoutId] as? String,
			   let existingLayoutEntry = BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[layoutId] {
				
				let savedLayoutEntry = existingLayoutEntry
				
				if layoutId != targetLayoutId {
					BDUI.LayoutReplacementOperations.layoutEntries[screenId]?.moveData(
						fromKey: layoutId,
						toKey: targetLayoutId
					)
					
					logger?.debug("layout replace - replace index from \(layoutId) to \(targetLayoutId)")
					
					replaceableLayoutId = targetLayoutId
				}
				
				// can recieve new nested layout entries during action replace ops and we have to add them at index
				for (key, value) in layoutReplaces {
					BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[key] = value
				}
				
				let currentLayoutId = replaceableLayoutId ?? layoutId
				
				if var currentLayoutEntry = BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[currentLayoutId] {
					
					currentLayoutEntry.containerView = savedLayoutEntry.containerView
					currentLayoutEntry.horizontalInset = savedLayoutEntry.horizontalInset
					currentLayoutEntry.eventHandler = savedLayoutEntry.eventHandler
										
					BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[currentLayoutId] = currentLayoutEntry
				}
			}
			
			BDUI.LayoutReplacementOperations.layoutEntries[BDUI.LayoutReplacementOperations.Constants.currentReplacementsKey] = nil
			
			BDUI.LayoutReplacementOperations.printLayoutData(with: logger, tag: "layout replace")
		}
		
		// if layoutId not change during replacement operation use layoutId from action
		let resultLayoutId = replaceableLayoutId ?? layoutId
		
		if let entry = BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[resultLayoutId],
		   let containerView = entry.containerView {
			
			logger?.debug("layout replace - for external screen \(screenId) - \(resultLayoutId) is found \(containerView)")
			
			BDUI.ViewBuilder.constructWidgetView(
				for: layoutDto,
				onExternalScreenWith: screenId,
				horizontalLayoutOneSideContentInset: Self.layoutContentInset(screenId: screenId, for: resultLayoutId) ?? 0,
				handleEvent: { events in
					if externalScreenId != nil {
						if let eventsHandler = BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[resultLayoutId]?.eventHandler {
							eventsHandler(events)
						}
					} else {
						handleEvent(events)
					}
				}
			)
			BDUI.LayoutReplacementOperations.printLayoutData(with: logger, tag: "layout replace")
		}
	}
	
	private static func consumeLayoutActions(
		_ action: BDUI.ActionDTO,
		for handleEvent: @escaping (BDUI.EventsDTO) -> Void,
		syncCompletion: (() -> Void)? = nil,
		activityIndicatorContainerView: UIView? = nil
	) {
		// NB! Do not handle actions here except actions for layout operations
		switch action.type {
			case .actionLayoutReplace:
				guard let action = action as? BDUI.LayoutReplaceActionDTO,
					  let layoutId = action.layoutId,
					  let layoutDto = action.layout?()
				else {
					syncCompletion?()
					return
				}
				
				// reset filter for current layout operations
				if let externalScreenId = action.screenId,
				   BDUI.LayoutReplacementOperations.layoutEntries[externalScreenId] != nil {
					BDUI.LayoutReplacementOperations.currentFilteredLayoutId = nil
				} else {
					if let screenId = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId{
						BDUI.LayoutReplacementOperations.currentFilteredLayoutId = nil
					}
				}
				
				BDUI.ViewBuilder.shared.handleReplaceOperation(
					action.screenId,
					layoutId,
					layoutDto,
					handleEvent: handleEvent
				)
				
				syncCompletion?()
				
			case .actionLayoutReplaceAsync:
				guard let action = action as? BDUI.LayoutReplaceAsyncActionDTO,
					  let layoutId = action.layoutId,
					  let request = action.request
				else {
					syncCompletion?()
					return
				}
				
				BDUI.ViewBuilder.shared.requestLayout(needPostData: action.postDataNeedToSend, with: request) { result in
					switch result {
						case .success(let data):
							DispatchQueue.main.async {
								if let layoutDto: BDUI.LayoutDTO = BDUI.ComponentDTO.mapData(from: data.content) {
									BDUI.ViewBuilder.shared.handleReplaceOperation(
										action.screenId,
										layoutId,
										layoutDto,
										handleEvent: handleEvent
									)
								}
								
								syncCompletion?()
							}
							
						case .failure(let error):
							ErrorHelper.show(error: error, alertPresenter: BDUI.ViewBuilder.shared.alertPresenter)
							activityIndicatorContainerView?.removeFromSuperview()
					}
				}
				
			case .actionLayoutFilter:
				guard let action = action as? BDUI.LayoutFilterActionDTO,
					  let layoutId = action.layoutId,
					  let filterTag = action.tag
				else { return }
				
				if let externalScreenId = action.screenId {
					BDUI.ViewBuilder.shared.logger?.debug("layout filter for external screen \(externalScreenId) - \(layoutId) - \(filterTag)")
				} else {
					if let screenId = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId {
						BDUI.ViewBuilder.shared.logger?.debug("layout filter internal screen  for \(screenId) - \(layoutId) - \(filterTag)")
						if let filterCallback = BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[layoutId]?.filterCallback {
							BDUI.ViewBuilder.shared.logger?.debug("layout filter filter call with \(filterTag)")
							filterCallback(screenId, layoutId, filterTag)
						}
					}
				}
				
				syncCompletion?()
				
			default:
				syncCompletion?()
				
		}
		// NB! Do not handle actions here except actions for layout operations
	}
	
	// MARK: - Utility
	private static func embed(
		_ externalScreenId: String?,
		_ layout: BDUI.LayoutDTO,
		_ blockView: UIView,
		with layoutContentInset: CGFloat,
		handleEvent: @escaping (BDUI.EventsDTO) -> Void
	) -> UIView {
		let insets = UIEdgeInsets(
			top: layout.paddingTop ?? 0,
			left: 0,
			bottom: layout.paddingBottom ?? 0,
			right: 0
		)
		
		let currentScreenId: String? = externalScreenId != nil
			? externalScreenId
			: BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId
		
		if let currentScreenId,
		   let layoutId = layout.layoutId,
		   let containerView = BDUI.LayoutReplacementOperations.layoutEntries[currentScreenId]?[layoutId]?.containerView {
			
			Self.replace(view: blockView, at: containerView, with: insets)
			
			return containerView
		} else {
			let containerView = Self.createContainerView(
				insets: insets,
				blockView: blockView
			)
			
			Self.addDebugLabel(to: containerView, layout.layoutId)
			
			let filterCallback = { (_ screenId: String, _ layoutId: String, _ tag: String?) in
				guard let layoutEntry = BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[layoutId]
				else { return }
				
				BDUI.LayoutReplacementOperations.currentFilteredLayoutId = layoutId
				
				BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[layoutId]?.willShownByTag = tag
				
				if let layoutBody: [String: Any] = BDUI.LayoutReplacementOperations.layoutEntries[screenId]?[layoutId]?.layoutParsedDictionary {
					if let layoutDto: BDUI.LayoutDTO = BDUI.ComponentDTO.mapData(from: layoutBody) {
						BDUI.ViewBuilder.constructWidgetView(
							for: layoutDto,
							handleEvent: { events in
								handleEvent(events)
							}
						)
					}
				}
			}
			
			if let constructingScreenId = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId,
			   let layoutId = layout.layoutId {
				let layoutBody: [String: Any]? = BDUI.LayoutReplacementOperations.layoutEntries[constructingScreenId]?[layoutId]?.layoutParsedDictionary
				let layoutСurrentFilterTag: String? = BDUI.LayoutReplacementOperations.layoutEntries[constructingScreenId]?[layoutId]?.willShownByTag
				
				BDUI.LayoutReplacementOperations.layoutEntries[constructingScreenId]?[layoutId] = (
					containerView,
					layoutContentInset,
					filterCallback,
					layoutBody,
					layoutСurrentFilterTag,
					handleEvent
				)
			}
			
			return containerView
		}
	}
	
	static private func layoutContentInset(screenId externalScreenId: String? = nil, for layoutId: String?) -> CGFloat? {
		let currentScreenId: String? = externalScreenId != nil
			? externalScreenId
			: BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenScreenId
		
		if let currentScreenId,
		   let layoutId,
		   let entry = BDUI.LayoutReplacementOperations.layoutEntries[currentScreenId]?[layoutId] {
			if entry.containerView != nil {
				return entry.horizontalInset
			}
		}
		
		return nil
	}
	
	private func requestLayout(
		needPostData: Bool,
		with request: BDUI.RequestComponentDTO,
		completion: @escaping (Result<BDUI.ContentWithInfoMessage, AlfastrahError>) -> Void
	) {
		guard request.url != nil
		else { return }
		
		self.backendDrivenService.bduiObject(
			needPostData: needPostData,
			addTimezoneParameter: true,
			formData: nil,
			for: request,
			completion: completion
		)
	}
	
	static private func addDebugLabel(to view: UIView, _ text: String?) {
		guard let text,
			  DebugMenu.shared.debugBDUI
		else { return }
		
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 8)
		label.text = text
		
		view.addSubview(label)
		label.topToSuperview(offset: -8)
		label.leadingToSuperview()
	}
	
	static private func replace(
		view: UIView,
		at containerView: UIView,
		with insets: UIEdgeInsets,
		spacerColor: UIColor = DebugMenu.shared.debugBDUI ? .red.withAlphaComponent(CGFloat(Float.random(in: 0.1..<0.5))) : .clear
	) {
		containerView.subviews.forEach({
			$0.removeFromSuperview()
		})
		
		if DebugMenu.shared.debugBDUI {
			if insets.top != 0 {
				let topPaddingView = UIView()
				topPaddingView.backgroundColor = spacerColor
				containerView.addSubview(topPaddingView)
				
				topPaddingView.edgesToSuperview(excluding: .bottom)
				topPaddingView.height(insets.top)
			}
			
			if insets.bottom != 0 {
				let bottomPaddingView = UIView()
				bottomPaddingView.backgroundColor = spacerColor
				containerView.addSubview(bottomPaddingView)
				
				bottomPaddingView.edgesToSuperview(excluding: .top)
				bottomPaddingView.height(insets.bottom)
			}
		}
		
		containerView.addSubview(view)
		view.edgesToSuperview(insets: insets)
	}
	
	// MARK: - Build Header
	static func buildHeader<T: BDUI.Header>(
		_ header: BDUI.HeaderDTO,
		layoutContentInset: CGFloat = 0,
		handleEvent: @escaping (BDUI.EventsDTO) -> Void,
		for _: T.Type
	) -> UIView? {
		guard let obj = header as? T.H
		else { return nil }
		
		let blockView = T.init(
			block: obj,
			horizontalInset: layoutContentInset,
			handleEvent: handleEvent
		)
				
		return blockView
	}
	
	// MARK: - Build Footer
	static func buildFooter<T: BDUI.Footer>(
		_ footer: BDUI.FooterDTO,
		layoutContentInset: CGFloat = 0,
		handleEvent: @escaping (BDUI.EventsDTO) -> Void,
		for _: T.Type
	) -> UIView? {
		guard let obj = footer as? T.F
		else { return nil }
		
		let blockView = T.init(
			block: obj,
			horizontalInset: layoutContentInset,
			handleEvent: handleEvent
		)
		
		return blockView
	}
}
