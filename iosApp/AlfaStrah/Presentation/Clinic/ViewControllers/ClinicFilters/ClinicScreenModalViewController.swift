//
//  ClinicScreenModalViewController.swift
//  AlfaStrah
//
//  Created by Makson on 16.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class ClinicScreenModalViewController: ViewController,
								 ActionSheetContentViewController
{
	var animationWhileTransition: (() -> Void)?
	
	struct Constants {
		static let layoutContentInset: CGFloat = 18
		static let topMaxOffset: CGFloat = 60 + (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 48)
		static let maxControllerHeight: CGFloat = UIScreen.main.bounds.height - topMaxOffset
		static let safeAreaBottomHeight: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 34
	}
	
	var input: Input!
	var output: Output!
	
	struct Input 
	{
		let title: String
		let clinicFilterInformations: [ClinicFilterInformation]
	}

	struct Output
	{
		let close: () -> Void
	}
	private var stackView = UIStackView()
	private var scrollView = UIScrollView()
	private var layoutView = UIView()
	
	private let headerViewContainer = UIView()
	private let titleLabel = UILabel()
	
	private var footerView: UIView?
	
	private lazy var scrollViewHeightConstraint: Constraint = {
		return scrollView.height(50)
	}()
	
	override func viewDidLoad() 
	{
		super.viewDidLoad()
		
		setupUI()
	}
	
	private func setupUI() 
	{
		view.backgroundColor = .Background.backgroundSecondary
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
		
		let updateScrollHeight = topOffset > Constants.topMaxOffset + inset
		scrollViewHeightConstraint.constant = updateScrollHeight
			? layoutView.bounds.height + inset
			: Constants.maxControllerHeight
		
		scrollView.isScrollEnabled = !updateScrollHeight
	}
	
	// MARK: - Header
	private func setupHeader()
	{
		view.addSubview(headerViewContainer)
		headerViewContainer.leadingToSuperview(offset: Constants.layoutContentInset)
		headerViewContainer.trailingToSuperview(offset: Constants.layoutContentInset)
		headerViewContainer.topToSuperview()
		
		let headerView = createHeaderView()
		headerViewContainer.addSubview(headerView)
		headerView.edgesToSuperview(
			insets: .bottom(15)
		)
	}
	
	func createHeaderView() -> UIView
	{
		let view = UIView()
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 9
		
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.primaryTitle1
		titleLabel.numberOfLines = 2
		titleLabel.text = title
		titleLabel.textAlignment = .left
		titleLabel.text = input.title
		stackView.addArrangedSubview(titleLabel)
		
		view.addSubview(stackView)
		stackView.edgesToSuperview(
			insets: .init(
				top: 8,
				left: 3,
				bottom: 8,
				right: 3
			)
		)
		
		let crossButton = UIButton(type: .system)
		crossButton.setImage(
			.Icons.cross,
			for: .normal
		)
		crossButton.tintColor = .Icons.iconAccentThemed
		crossButton.size(
			.init(width: 24, height: 24)
		)
		crossButton.addTarget(
			self,
			action: #selector(onClose),
			for: .touchUpInside
		)
		
		let containerView = UIView()
		containerView.addSubview(crossButton)
		crossButton.verticalToSuperview(insets: .vertical(3))
		crossButton.horizontalToSuperview()
		stackView.addArrangedSubview(containerView)
		
		return view
	}
		
	// MARK: - Footer
	func setupFooter() {
		self.footerView = createFooterView()
		
		guard let footerView = self.footerView
		else { return }
		
		view.addSubview(footerView)
		
		footerView.edgesToSuperview(
			excluding: .top, usingSafeArea: true
		)
		
		footerView.topToBottom(of: scrollView)
	}
	
	private func createFooterView() -> UIView
	{
		let view = UIView()
		let understandButton = RoundEdgeButton()
		understandButton <~ Style.RoundedButton.oldPrimaryButtonSmall
		understandButton.setTitle(
			NSLocalizedString("common_understand", comment: ""),
			for: .normal
		)
		view.addSubview(understandButton)
		understandButton.edgesToSuperview(
			insets: .init(
				top: 0,
				left: 18,
				bottom: 15,
				right: 18
			)
		)
		understandButton.height(48)
		understandButton.addTarget(
			self,
			action: #selector(onClose),
			for: .touchUpInside
		)
		
		return view
	}
	
	@objc private func onClose()
	{
		self.output.close()
	}
		
	private func setupStaticLayout() {
		scrollView.bounces = true
		scrollView.alwaysBounceVertical = true
		scrollView.showsVerticalScrollIndicator = true
		
		view.addSubview(scrollView)
		
		scrollView.horizontalToSuperview()
		scrollView.topToBottom(of: headerViewContainer)
	}
	
	// MARK: - Layout
	private func setupLayout() 
	{
		self.layoutView = createInfoView()
		scrollView.addSubview(layoutView)
		layoutView.edgesToSuperview(insets: .horizontal(15))
		layoutView.width(view.frame.width - 30)
	}
	
	private func createInfoView() -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		// stackView
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 16
		view.addSubview(stackView)
		stackView.edgesToSuperview()
		
		input.clinicFilterInformations.forEach 
		{
			let view = createInfoView(
				title: $0.title,
				description: $0.description
			)
			
			stackView.addArrangedSubview(
				view
			)
		}
		
		return view
	}
	
	private func createInfoView(
		title: String,
		description: String
	) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		// stackView
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 5
		view.addSubview(stackView)
		stackView.edgesToSuperview()
		
		// titleLabel
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.primaryHeadline1
		titleLabel.numberOfLines = 0
		titleLabel.text = title
		titleLabel.textAlignment = .left
		
		// descriptionLabel
		let descriptionLabel = UILabel()
		descriptionLabel <~ Style.Label.primaryText
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = description
		descriptionLabel.textAlignment = .left
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(descriptionLabel)
		
		return view
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) 
	{
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() 
	{
		view.backgroundColor = .Background.backgroundSecondary
		scrollView.subviews.forEach({ $0.removeFromSuperview() })
		setupLayout()
		setupFooter()
	}
}
