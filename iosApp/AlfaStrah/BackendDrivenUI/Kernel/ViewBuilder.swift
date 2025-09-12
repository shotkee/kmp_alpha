//
//  ViewBuilder.swift
//  AlfaStrah
//
//  Created by vit on 24.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

import SDWebImage
import Legacy
import UIKit

// swiftlint:disable file_length
extension BDUI {
	class ViewBuilder: AlertPresenterDependency,
					   LoggerDependency,
					   BackendDrivenServiceDependency {
		var alertPresenter: AlertPresenter!
		var analytics: AnalyticsService!
		var backendDrivenService: BackendDrivenService!
		var logger: TaggedLogger?
		
		static let shared = ViewBuilder()
		
		typealias WidgetEntry = (view: UIView, widget: WidgetDTO)
		
		static let notConstructed: WidgetEntry = (UIView(), BDUI.WidgetDTO(body: [:]))
		
		@discardableResult static func constructWidgetView(
			for dto: WidgetDTO,
			onExternalScreenWith screenId: String? = nil,
			horizontalLayoutOneSideContentInset: CGFloat = 0,
			renderCallback: ((EventsDTO) -> Void)? = nil,
			handleEvent: @escaping (EventsDTO) -> Void
		) -> UIView {
			return constructView(
				for: dto,
				onExternalScreenWith: screenId,
				horizontalLayoutOneSideContentInset: horizontalLayoutOneSideContentInset,
				renderCalback: renderCallback,
				handleEvent: handleEvent
			).view
		}
		
		// MARK: - Mathod for VerticalCustomRadioButtonWidgetView compability ( backend-issue )
		@discardableResult static func constructWidgetEntry(
			for dto: WidgetDTO?,
			indexFormData: Bool = true,
			onExternalScreenWith screenId: String? = nil,
			horizontalLayoutOneSideContentInset: CGFloat = 0,
			renderCalback: ((EventsDTO) -> Void)? = nil,
			handleEvent: @escaping (EventsDTO) -> Void
		) -> WidgetEntry {
			return constructView(
				for: dto,
				indexFormData: indexFormData,
				onExternalScreenWith: screenId,
				horizontalLayoutOneSideContentInset: horizontalLayoutOneSideContentInset,
				renderCalback: renderCalback,
				handleEvent: handleEvent
			)
		}
		
		// swiftlint:disable:next function_body_length cyclomatic_complexity
		private static func constructView(
			for dto: ComponentDTO?,
			indexFormData: Bool = true,
			onExternalScreenWith screenId: String? = nil,
			horizontalLayoutOneSideContentInset: CGFloat = 0,
			renderCalback: ((BDUI.EventsDTO) -> Void)? = nil,
			handleEvent: @escaping (BDUI.EventsDTO) -> Void
		) -> WidgetEntry {
			guard let type = dto?.type,
				  let viewType = BDUI.Mapper.widgetEntries[type]?.viewType
			else { return notConstructed }
			
			switch dto {
				case let layout as LayoutDTO:
					if let view = Self.buildLayout(
						layout,
						layoutContentInset: horizontalLayoutOneSideContentInset,
						handleEvent: handleEvent,
						for: viewType
					) {
						return (view, layout)
					}
					
				case let widget as WidgetDTO:
					if widget.type == .widgetStories,
					   let storiesDTO = dto as? StoriesWidgetDTO {
						let storiesView = ViewBuilder.shared.storiesWidget(
							storiesDTO,
							layoutContentInset: horizontalLayoutOneSideContentInset,
							handleEvent: handleEvent
						)
						
						return (storiesView, storiesDTO)
					}
					
					if let view = Self.buildWidget(
						widget,
						layoutContentInset: horizontalLayoutOneSideContentInset,
						indexFormData: indexFormData,
						handleEvent: handleEvent,
						for: viewType
					) {
						return (view, widget)
					}
					
				default:
					break
			}
			
			return notConstructed
		}
		
		@discardableResult static func constructFooterView(
			for footer: FooterDTO,
			horizontalLayoutOneSideContentInset: CGFloat = 0,
			handleEvent: @escaping (BDUI.EventsDTO) -> Void
		) -> UIView {
			guard let viewType = BDUI.Mapper.footerEntries[footer.type]?.viewType
			else { return UIView() }
			
			if let view = Self.buildFooter(
				footer,
				layoutContentInset: horizontalLayoutOneSideContentInset,
				handleEvent: handleEvent,
				for: viewType
			) {
				return view
			}
			
			return UIView()
		}
		
		@discardableResult static func constructHeaderView(
			for header: HeaderDTO,
			horizontalLayoutOneSideContentInset: CGFloat = 0,
			handleEvent: @escaping (BDUI.EventsDTO) -> Void
		) -> UIView {
			guard let viewType = BDUI.Mapper.headerEntries[header.type]?.viewType
			else { return UIView() }
			
			if let view = Self.buildHeader(
				header,
				layoutContentInset: horizontalLayoutOneSideContentInset,
				handleEvent: handleEvent,
				for: viewType
			) {
				return view
			}
			
			return UIView()
		}
		
		static func constructNavigationHeader(
			for header: HeaderDTO,
			on viewController: ViewController,
			isModal: Bool = false,
			handleEvent: @escaping (BDUI.EventsDTO) -> Void,
			traitDidChange: (@escaping (UIUserInterfaceStyle) -> Void) -> Void
		) {
			let currentUserInterfaceStyle = viewController.traitCollection.userInterfaceStyle
			
			switch header.type {
				case .headerAlignLeftOneButtonDescription:
					return
					
				case .headerOneButton:
					guard let block = header as? OneButtonHeaderDTO
					else { return }
					
					viewController.title = block.title?.text
					
					if isModal {
						viewController.addCloseButton(position: .left) { [weak viewController] in
							if let events = block.events {
								handleEvent(events)
							} else {
								viewController?.dismiss(animated: true)
							}
						}
					} else {
						viewController.addBackButton { [weak viewController] in
							if let events = block.events {
								handleEvent(events)
							} else {
								if let navigationController = viewController?.navigationController {
									if navigationController.viewControllers.first === viewController {
										viewController?.dismiss(animated: true)
									} else {
										navigationController.popViewController(animated: true)
									}
								} else {
									viewController?.dismiss(animated: true)
								}
							}
						}
					}
					
					// set title color only if navigationTitleColor exist else use color which set globally from AppDelegate
					if let navigationTitleColor = block.title?.themedColor?.color(for: viewController.traitCollection.userInterfaceStyle) {
						viewController.navigationController?.navigationBar.titleTextAttributes = [
							.foregroundColor: navigationTitleColor
						]
					}
					
				case .headerTwoButtons:
					guard let block = header as? TwoButtonsHeaderDTO
					else { return }
					
					let updateTheme = { [weak viewController] (currentUserInterfaceStyle: UIUserInterfaceStyle) -> Void in
						guard let viewController
						else { return }
						
						if let title = block.title {
							viewController.navigationItem.titleView = Self.createTitleView(
								for: title,
								with: currentUserInterfaceStyle
							)
						}
						
						if let leftButton = block.leftButton {
							if let iconUrl = leftButton.themedImage?.url(for: currentUserInterfaceStyle) {
								SDWebImageManager.shared.loadImage(
									with: iconUrl,
									options: .highPriority,
									progress: nil,
									completed: { [weak viewController] image, _, _, _, _, _ in
										viewController?.addNavigationButton(
											icon: image,	// default with cross icon?
											position: .left
										) { [weak viewController] in
											if let events = leftButton.events {
												handleEvent(events)
											} else {
												Self.defaultClose(for: viewController, isModal: isModal)
											}
										}
									}
								)
							} else if let themedSizedButtonTitle = leftButton.themedSizedTitle {
								viewController.addNavigationButton(
									text: themedSizedButtonTitle.text,
									position: .left
								) { [weak viewController] in
									if let events = leftButton.events {
										handleEvent(events)
									} else {
										Self.defaultClose(for: viewController, isModal: isModal)
									}
								}
							}
						}
						
						if let rightButton = block.rightButton {
							if let iconUrl = rightButton.themedImage?.url(for: currentUserInterfaceStyle) {
								SDWebImageManager.shared.loadImage(
									with: iconUrl,
									options: .highPriority,
									progress: nil,
									completed: { [weak viewController] image, _, _, _, _, _ in
										viewController?.addNavigationButton(
											icon: image,
											position: .right
										) {
											if let events = rightButton.events {
												handleEvent(events)
											}
										}
									}
								)
							} else if let themedSizedButtonTitle = rightButton.themedSizedTitle {
								viewController.addNavigationButton(
									text: themedSizedButtonTitle.text,
									position: .right
								) {
									if let events = rightButton.events {
										handleEvent(events)
									}
								}
							}
						}
						
						if let navigationTitleColor = block.title?.themedColor?.color(for: viewController.traitCollection.userInterfaceStyle) {
							viewController.navigationController?.navigationBar.titleTextAttributes = [
								.foregroundColor: navigationTitleColor
							]
						}
					}
					
					updateTheme(currentUserInterfaceStyle)
					
					traitDidChange(updateTheme)
					
				case .none:
					return
					
				default:
					return
					
			}
		}
		
		private static func defaultClose(for viewController: ViewController?, isModal: Bool) {
			if isModal {
				viewController?.dismiss(animated: true)
			} else {
				viewController?.navigationController?.popViewController(animated: true)
			}
		}
		
		private static func createTitleView(
			for title: ThemedSizedTextComponentDTO,
			with userInterfaceStyle: UIUserInterfaceStyle
		) -> UIView {
			let titleStackView = UIStackView()
			
			titleStackView.alignment = .center
			titleStackView.axis = .vertical
			titleStackView.distribution = .fill
			titleStackView.spacing = 2
			
			let titleLabel = UILabel()
			titleLabel <~ StyleExtension.Label(title, for: userInterfaceStyle)
			
			titleStackView.addArrangedSubview(titleLabel)
			
			return titleStackView
		}
	}
}
