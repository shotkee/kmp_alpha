//
//  ScreenModalViewController.swift
//  AlfaStrah
//
//  Created by vit on 26.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

extension BDUI {
	class ScreenModalViewController: ViewController,
									 ActionSheetContentViewController {
		var animationWhileTransition: (() -> Void)?
		
		struct Notify {
			let reload: (_ screen: ScreenComponentDTO) -> Void
		}
		
		private(set) lazy var notify = Notify(
			reload: { [weak self] screenComponent in
				guard let self,
					  self.isViewLoaded
				else { return }
				
				screenBackendComponent = screenComponent
				needRebuildLayout = true
				
				updateUI()
			}
		)
		
		private var needRebuildLayout: Bool = false
		
		private var screenBackendComponent: ScreenComponentDTO?
		
		struct Constants {
			static let layoutContentInset: CGFloat = 18
			static let topMaxOffset: CGFloat = 60 + (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 48)
			static let maxControllerHeight: CGFloat = UIScreen.main.bounds.height - topMaxOffset
		}
		
		var input: Input!
		var output: Output!
		
		struct Input {
			let screenBackendComponent: ScreenComponentDTO
		}
		
		struct Output {
			let handleEvent: ((EventsDTO) -> Void)?
			let toChat: () -> Void
			let close: () -> Void
			let loaded: () -> Void
			let appeared: () -> Void
			let destructed: () -> Void
		}
		
		private var scrollView = UIScrollView()
		private var layoutView = UIView()
		
		private let headerViewContainer = UIView()
		private let titleLabel = UILabel()
		
		private var footerView: UIView?
		
		private var safeAreaBottomCorrection: CGFloat = 0
		
		private var safeAreaBottomHeight: CGFloat {
			return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 34
		}
		
		private lazy var scrollViewHeightConstraint: Constraint = {
			return scrollView.height(50)
		}()
		
		override func viewDidLoad() {
			super.viewDidLoad()
			
			screenBackendComponent = input.screenBackendComponent
			setupUI()
			
			output.loaded()
		}
		
		private func updateUI() {
			if needRebuildLayout {
				self.clearViewControllerRootView()
				self.setupUI()
				self.needRebuildLayout = false
			}
		}
		
		private func clearViewControllerRootView() {
			view.subviews.forEach({ $0.removeFromSuperview() })
			scrollView = UIScrollView()
		}
		
		override func viewDidAppear(_ animated: Bool) {
			super.viewDidAppear(animated)
			
			output.appeared()
			
			if screenBackendComponent?.events?.onRender != nil {
				handleRenderAction()
			}
			
			startRenderEventsForLayouts()
		}
		
		private func startRenderEventsForLayouts() {
			ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.startRenderSubscriptions()
		}
		
		private func handleRenderAction() {
			if let events = screenBackendComponent?.events {
				self.output.handleEvent?(events)
			}
		}
		
		private func setupUI() {
			view.backgroundColor = screenBackendComponent?.backgroundColor?.color(for: traitCollection.userInterfaceStyle)
			
			setupHeader()
			setupStaticLayout()
			setupLayout()
			setupFooter()
		}
		
		override func viewDidLayoutSubviews() {
			super.viewDidLayoutSubviews()
			
			let inset = footerView?.bounds.height ?? 0
			
			if self.footerView != nil,
			   scrollView.contentInset.bottom != inset {
				scrollView.contentInset.bottom = inset
			}
			
			let topOffset = UIScreen.main.bounds.height - layoutView.bounds.height - headerViewContainer.bounds.height
			
			let updateScrollHeight = topOffset > Constants.topMaxOffset + self.safeAreaBottomCorrection + inset
			scrollViewHeightConstraint.constant = updateScrollHeight
			? layoutView.bounds.height + self.safeAreaBottomHeight + inset
			: Constants.maxControllerHeight
			
			scrollView.isScrollEnabled = !updateScrollHeight
		}
		
		// MARK: - Header
		private func setupHeader() {
			guard let header = screenBackendComponent?.header
			else { return }
			
			view.addSubview(headerViewContainer)
			headerViewContainer.leadingToSuperview(offset: Constants.layoutContentInset)
			headerViewContainer.trailingToSuperview(offset: Constants.layoutContentInset)
			
			let topOffset: CGFloat = is7IphoneOrLess() ? 10 : 0
			headerViewContainer.topToSuperview(offset: topOffset, usingSafeArea: true)
			
			let headerView = ViewBuilder.constructHeaderView(
				for: header,
				handleEvent: { [weak self] events in
					self?.output.handleEvent?(events)
				}
			)
			
			headerViewContainer.addSubview(headerView)
			headerView.edgesToSuperview()
		}
		
		// MARK: - Footer
		func setupFooter() {
			guard let footerSelector = screenBackendComponent?.footer
			else {
				self.safeAreaBottomCorrection = self.safeAreaBottomHeight
				return
			}
			
			self.footerView = ViewBuilder.constructFooterView(
				for: footerSelector,
				horizontalLayoutOneSideContentInset: Constants.layoutContentInset,
				handleEvent: { [weak self] events in
					self?.output.handleEvent?(events)
				}
			)
			
			guard let footerView = self.footerView
			else { return }
			
			view.addSubview(footerView)
			
			footerView.edgesToSuperview(excluding: .top, usingSafeArea: true)
		}
		
		private func setupStaticLayout() {
			scrollView.bounces = true
			scrollView.alwaysBounceVertical = true
			
			view.addSubview(scrollView)
			
			scrollView.edgesToSuperview(excluding: .top)
			scrollView.topToBottom(of: headerViewContainer)
		}
		
		// MARK: - Layout
		private func setupLayout() {
			guard let layout = screenBackendComponent?.layout
			else { return }
			
			let horizontalLayoutOneSideContentInset: CGFloat
			
			switch layout.type {
				case .layoutOneColumn:
					horizontalLayoutOneSideContentInset = Constants.layoutContentInset
					
				case .layoutTwoColumns:
					horizontalLayoutOneSideContentInset = Constants.layoutContentInset
					
				default:
					horizontalLayoutOneSideContentInset = 0
			}
						
			self.layoutView = ViewBuilder.constructWidgetView(
				for: layout,
				horizontalLayoutOneSideContentInset: horizontalLayoutOneSideContentInset,
				handleEvent: { [weak self] events in
					self?.output.handleEvent?(events)
				}
			)
			
			scrollView.addSubview(layoutView)
			
			layoutView.edgesToSuperview()
			layoutView.width(to: view)
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			view.backgroundColor = screenBackendComponent?.backgroundColor?.color(for: currentUserInterfaceStyle)
			
			scrollView.subviews.forEach({ $0.removeFromSuperview() })
			setupLayout()
			
			setupFooter()
		}
		
		deinit {
			output.destructed()
		}
	}
}
