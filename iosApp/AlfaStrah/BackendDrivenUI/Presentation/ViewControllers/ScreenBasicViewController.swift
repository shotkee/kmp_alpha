//
//  BackendDrivenViewController.swift
//  AlfaStrah
//
//  Created by vit on 28.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

extension BDUI {
	class ScreenBasicViewController: ViewController,
									 UIScrollViewDelegate {
		enum State {
			case loading
			case failure
			case data
		}
		
		struct Notify {
			let reload: (_ screen: ScreenComponentDTO) -> Void
			let update: (_ state: State) -> Void
		}
		
		private(set) lazy var notify = Notify(
			reload: { [weak self] screenComponent in
				guard let self,
					  self.isViewLoaded
				else { return }
				
				screenBasicBackendComponent = screenComponent
				needRebuildLayout = true
				
				updateUI()
			},
			update: { [weak self] state in
				guard let self = self,
					  self.isViewLoaded
				else { return }
				
				self.update(with: state)
			}
		)
		
		private var screenBasicBackendComponent: ScreenComponentDTO?
		
		private var needRebuildLayout: Bool = false
		
		private var updateThemeCallBack: ((UIUserInterfaceStyle) -> Void)?
		
		private var headerView: UIView?
		private var footerView: UIView?
		private var scrollDidScrollEnabled = false
		
		struct Constants {
			static let layoutContentInset: CGFloat = 18
			static let bottomContentInset: CGFloat = 66
		}
		
		var input: Input!
		var output: Output!
		
		struct Input {
			let screenBasicBackendComponent: ScreenComponentDTO
			let pullToRefresh: (RequestComponentDTO, @escaping (Result<Void, Error>) -> Void) -> Void
			let isAppRootContoller: Bool
		}
		
		struct Output {
			let handleEvent: ((EventsDTO) -> Void)?
			let toChat: () -> Void
			let close: () -> Void
			let loaded: () -> Void
			let firstAppear: () -> Void
			let desctructed: () -> Void
		}
		
		private var scrollView = UIScrollView()
		private var pullToRefreshView: PullToRefreshView?
		
		private let operationStatusView = OperationStatusView()
		
		private lazy var onRenderSubscirptions: Subscriptions<Void> = Subscriptions()
		
		override func viewDidLoad() {
			super.viewDidLoad()
			
			screenBasicBackendComponent = input.screenBasicBackendComponent
			setupUI()
			
			output.loaded()
		}
		
		override func viewWillAppear(_ animated: Bool) {
			super.viewWillAppear(animated)
			
			if input.isAppRootContoller {
				self.navigationController?.setNavigationBarHidden(true, animated: false)
			}
		}
		
		private func updateUI() {
			if self.needRebuildLayout && !(pullToRefreshView?.pullToRefreshInProgress ?? false)  {
				self.clearViewControllerRootView()
				self.setupUI()
				self.needRebuildLayout = false
			}
		}
		
		private var firstAppear = true
		
		override func viewDidAppear(_ animated: Bool) {
			super.viewDidAppear(animated)
			
			if firstAppear {
				output.firstAppear()
				
				firstAppear = false
			}
			
			if screenBasicBackendComponent?.events?.onRender != nil {
				handleRenderAction()
			}
			
			startRenderEventsForLayouts()
			
			updateScrollContentInset()
			
			subscribeForKeyboardNotifications()
		}
		
		private func updateScrollContentInset() {
			if let inset = footerView?.bounds.height,
			   self.footerView != nil,
			   scrollView.contentInset.bottom != inset {
				scrollView.contentInset.bottom = inset
			}
		}
		
		override func viewDidDisappear(_ animated: Bool) {
			super.viewDidDisappear(animated)
			
			scrollDidScrollEnabled = false
			
			NotificationCenter.default.removeObserver(self)
		}
		
		private func startRenderEventsForLayouts() {
			ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.startRenderSubscriptions()
		}
		
		private func handleRenderAction() {
			if let events = screenBasicBackendComponent?.events {
				self.output.handleEvent?(events)
			}
		}
		
		override func viewWillDisappear(_ animated: Bool) {
			super.viewWillDisappear(animated)
			
			if input.isAppRootContoller {
				self.navigationController?.setNavigationBarHidden(false, animated: false)
			}
		}
		
		private func setupUI() {
			update(with: .data)
			
			view.backgroundColor = screenBasicBackendComponent?.backgroundColor?.color(for: traitCollection.userInterfaceStyle)
			
			setupPullToRefreshView()
			setupStaticLayout()
			setupHeader()
			setupLayout()
			setupFooter()
			
			setupOperationStatusView()
		}
		
		private func setupOperationStatusView() {
			view.addSubview(operationStatusView)
			operationStatusView.edgesToSuperview()
		}
		
		private func update(with state: State) {
			switch state {
				case .loading:
					operationStatusView.isHidden = false
					let state: OperationStatusView.State = .loading(.init(
						title: NSLocalizedString("common_load", comment: ""),
						description: nil,
						icon: nil
					))
					operationStatusView.notify.updateState(state)
				case .data:
					operationStatusView.isHidden = true
				case .failure:
					operationStatusView.isHidden = false
					let state: OperationStatusView.State = .info(.init(
						title: NSLocalizedString("common_error_accured_title", comment: ""),
						description: NSLocalizedString("common_please_try_again_or_write_to_chat", comment: ""),
						icon: .Icons.cross.resized(newWidth: 32)?.withRenderingMode(.alwaysTemplate)
					))
					
					let buttons: [OperationStatusView.ButtonConfiguration] = [
						.init(
							title: NSLocalizedString("common_contact_to_chat", comment: ""),
							isPrimary: false,
							action: { [weak self] in
								self?.output.toChat()
							}
						),
						.init(
							title: NSLocalizedString("common_try_again", comment: ""),
							isPrimary: true,
							action: { [weak self] in
								guard let self,
									  let pullToRefresh = self.screenBasicBackendComponent?.pullToRefresh
								else { return }
								
								self.update(with: .loading)
								
								self.input.pullToRefresh(pullToRefresh) { result in
									switch result {
										case .success:
											self.update(with: .data)
										case .failure:
											self.update(with: .failure)
									}
								}
							}
						)
					]
					operationStatusView.notify.updateState(state)
					operationStatusView.notify.buttonConfiguration(buttons)
			}
		}
		
		private func clearViewControllerRootView() {
			view.subviews.forEach({ $0.removeFromSuperview() })
			scrollView = UIScrollView()
		}
		
		@objc func closeTap() {
			output.close()
		}
		
		// MARK: - Header
		private func setupHeader() {
			guard let header = screenBasicBackendComponent?.header
			else { return }
			
			if input.isAppRootContoller {
				self.headerView = ViewBuilder.constructHeaderView(
					for: header,
					handleEvent: { [weak self] events in
						self?.output.handleEvent?(events)
					}
				)
				
				guard let headerView = self.headerView
				else { return }
				
				scrollView.addSubview(headerView)
				
				headerView.horizontalToSuperview(
					insets: UIEdgeInsets(top: 0, left: Constants.layoutContentInset, bottom: 0, right: Constants.layoutContentInset)
				)
				headerView.topToSuperview()
				
			} else {
				ViewBuilder.constructNavigationHeader(
					for: header,
					on: self,
					isModal: {
						switch screenBasicBackendComponent?.showType {
							case .vertical, .none, .modal:
								return true
								
							case .horizontal:
								return false
								
						}
					}(),
					handleEvent: { [weak self] events in
						self?.output.handleEvent?(events)
					},
					traitDidChange: { updateThemeCallback in
						self.updateThemeCallBack = updateThemeCallback
					}
				)
			}
		}
		
		// MARK: - Footer
		func setupFooter() {
			guard let footerSelector = screenBasicBackendComponent?.footer
			else { return }
			
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
			scrollView.translatesAutoresizingMaskIntoConstraints = false
			scrollView.bounces = true
			scrollView.alwaysBounceVertical = true
			
			view.addSubview(scrollView)
			
			scrollView.edgesToSuperview()
		}
		
		// MARK: - PullToRefresh
		private func setupPullToRefreshView() {
			guard let pullToRefresh = screenBasicBackendComponent?.pullToRefresh
			else { return }
			
			pullToRefreshView = PullToRefreshView()
			
			guard let pullToRefreshView = self.pullToRefreshView
			else { return }
			
			pullToRefreshView.refreshDataCallback = { [weak self] completion in
				guard let self
				else { return }
				
				self.input.pullToRefresh(pullToRefresh) { [weak self] result in
					completion()
					
					guard let self
					else { return }
					
					switch result {
						case .success:
							self.update(with: .data)
							
						case .failure:
							self.update(with: .failure)
							
					}
				}
			}
			
			pullToRefreshView.scrollView = scrollView
			scrollView.delegate = self
			
			view.insertSubview(pullToRefreshView, at: 0)
			pullToRefreshView.edgesToSuperview(excluding: .bottom)
			
			pullToRefreshView.animationCompletion = { [weak self] in
				guard let self
				else { return }
				
				if self.needRebuildLayout {
					self.clearViewControllerRootView()
					self.setupUI()
					self.needRebuildLayout = false
				}
			}
		}
		
		// MARK: - UIScrollViewDelegate
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			if scrollDidScrollEnabled {
				pullToRefreshView?.didScrollCallback(scrollView)
			}
		}
		
		func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
			scrollDidScrollEnabled = true 	// setNavigationBarHidden triggers p2r fix
		}
		
		func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
			pullToRefreshView?.didEndDraggingCallcback(scrollView, willDecelerate: decelerate)
		}
		
		// MARK: - Layout
		private func setupLayout() {
			guard let layout = screenBasicBackendComponent?.layout
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
			
			let layoutView = ViewBuilder.constructWidgetView(
				for: layout,
				horizontalLayoutOneSideContentInset: horizontalLayoutOneSideContentInset,
				handleEvent: { [weak self] events in
					self?.output.handleEvent?(events)
				}
			)
			
			scrollView.addSubview(layoutView)
			
			if let headerView = self.headerView {
				layoutView.topToBottom(of: headerView)
			} else {
				layoutView.topToSuperview()
			}
			
			layoutView.leadingToSuperview()
			layoutView.trailingToSuperview()
			layoutView.bottomToSuperview(offset: self.tabBarController == nil ? 0 : -Constants.bottomContentInset)
			
			layoutView.width(to: view)
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			self.updateThemeCallBack?(currentUserInterfaceStyle)
			
			view.backgroundColor = screenBasicBackendComponent?.backgroundColor?.color(for: currentUserInterfaceStyle)
		}
		
		var destructCallback: (() -> Void)?
		
		deinit {
			output.desctructed()
			destructCallback?()
		}
		
		override func viewDidLayoutSubviews() {
			super.viewDidLayoutSubviews()
			
			if keyboardIsHidden {
				updateScrollContentInset()
			}
		}
		
		private var keyboardIsHidden = true
		
		// MARK: - Keyboard notifications handling
		private func subscribeForKeyboardNotifications() {
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(keyboardWillShow),
				name: UIResponder.keyboardWillShowNotification,
				object: nil
			)
			
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(keyboardDidHide),
				name: UIResponder.keyboardDidHideNotification,
				object: nil
			)
		}
		
		@objc func keyboardWillShow(_ notification: NSNotification) {
			keyboardIsHidden = false
		}
		
		@objc func keyboardDidHide(_ notification: NSNotification) {
			keyboardIsHidden = true
			updateScrollContentInset()
		}
	}
}
