//
//  WidgetSelector+.swift
//  AlfaStrah
//
//  Created by vit on 19.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import OrderedCollections

// swiftlint:disable file_length
extension BDUI.WidgetSelector {
	func buildWidget<T: UIView & BDUI.WidgetInitializable>(
		_ block: T.W,
		layoutContentInset: CGFloat = 0,
		indexFormData: Bool = true,
		handleEvent: @escaping (BDUI.EventSelector) -> Void,
		for _: T.Type
	) -> UIView {
		if let onRenderAction = block.event?.onRender {
			logger?.debug("render event \(onRenderAction)")
			
			BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.subscribeForRender {
				let screenId = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.screenId
				let actionName = block.event?.onRender?.name
				
				self.logger?.debug("render event on screen id \(screenId) with action \(actionName)")
				
				handleEvent(BDUI.EventSelector(onTap: nil, onRender: onRenderAction, onChange: nil))
			}
		}
			
		let consumeEventWithFormData = { (_ eventSelector: BDUI.EventSelector) -> Void in
			guard let action = eventSelector.onTap
			else {
				handleEvent(eventSelector)
				return
			}
			
			switch action.method {
				case .actionActionRequest(request: let request):
					BDUI.CommonActionHandlers.shared.handleActionRequest(
						action,
						request,
						handleEvent: handleEvent
					)
					
				default:
					handleEvent(eventSelector)
					
			}
		}
			
		let blockView = T.init(
			block: block,
			horizontalInset: layoutContentInset,
			handleEvent: consumeEventWithFormData
		)
		
		switch block.type {
			case .widgetTextButtonCheckbox:
				break
			default:
				if indexFormData {
					Self.addFormDataToCurrentScreenEntry(from: block)
				}
		}
		
		return Self.createContainerView(
			insets: UIEdgeInsets(top: block.paddingTop ?? 0, left: 0, bottom: block.paddingBottom ?? 0, right: 0),
			blockView: blockView
		)
	}
	
	// MARK: - StoriesWidget
	func storiesWidget(
		_ block: BDUI.StoriesWidgetDTO,
		layoutContentInset: CGFloat = 0,
		handleEvent: @escaping (BDUI.EventSelector) -> Void
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
		
	static func createContainerView(
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
	
	static private func addFormDataToCurrentScreenEntry(from widget: BDUI.WidgetDTO) {
		guard let formDataEntry = widget.formData
		else { return }
		
		if BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData == nil {
			BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData = [formDataEntry]
		} else {
			BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.postData?.append(formDataEntry)
		}
	}
}
// swiftlint:enable file_length
