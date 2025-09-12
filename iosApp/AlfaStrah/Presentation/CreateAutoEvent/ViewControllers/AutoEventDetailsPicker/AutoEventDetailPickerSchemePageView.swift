//
//  AutoEventDetailPickerSchemePageView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 22.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit

class AutoEventDetailPickerSchemePageView: UIView,
										   UIScrollViewDelegate {
	private var updateSelection: (() -> Void)?
	private var singleSelection: (([Int], _ selectionCallback: ((Bool) -> Void)?) -> Void)?
	
	private var partsLists: [BDUI.SchemeItemsListComponentDTO] = [] {
		didSet {
			updateDetailsState()
		}
	}
	
	private lazy var scrollView = creteScrollView()
	private let detailsContainerView = createDetailsContainerView()
	private lazy var zoomInButton = createZoomInButton()
	private lazy var zoomOutButton = createZoomOutButton()
	
	private var detailsButtons: [(button: AutoEventDetailPickerDetailButton, action: (() -> Detail)?)] = []
	
	init() {
		super.init(frame: .zero)
		
		setupUI()
		updateTheme()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		scrollView.minimumZoomScale = bounds.width / Constants.size.width
		scrollView.maximumZoomScale = scrollView.minimumZoomScale * 2
		if scrollView.zoomScale < scrollView.minimumZoomScale {
			scrollView.zoomScale = scrollView.minimumZoomScale
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		updateZoomButtons()
	}
	
	private func setupUI() {
		backgroundColor = .clear
		
		// scroll
		addSubview(scrollView)
		scrollView.edgesToSuperview()
		scrollView.layer.cornerRadius = 16
		
		// details container
		scrollView.addSubview(detailsContainerView)
		detailsContainerView.size(Constants.size)
		detailsContainerView.edgesToSuperview()
		
		// details
		setupDetails()
		
		// zoom buttons stack
		let zoomButtonsStack = UIStackView()
		zoomButtonsStack.axis = .vertical
		zoomButtonsStack.spacing = 12
		addSubview(zoomButtonsStack)
		zoomButtonsStack.trailingToSuperview()
		zoomButtonsStack.centerYToSuperview(offset: -5)
		
		// zoom in button
		zoomButtonsStack.addArrangedSubview(zoomInButton)
		
		// zoom out button
		zoomButtonsStack.addArrangedSubview(zoomOutButton)
	}
	
	private func setupDetails() {
		Self.details.forEach { detail in
			let detailButton = AutoEventDetailPickerDetailButton(
				defaultImageName: detail.defaultImageName,
				selectedImageName: detail.selectedImageName
			)
			detailsContainerView.addSubview(detailButton)
			detailButton.topToSuperview(offset: detail.origin.y)
			detailButton.leftToSuperview(offset: detail.origin.x)
			detailButton.addTarget(
				self,
				action: #selector(onDetailButton),
				for: .touchUpInside
			)
						
			let action = { () -> Detail in
				return detail
			}
			
			detailsButtons.append((detailButton, action))
		}
	}
	
	private func updateDetailsState() {
		for (index, detail) in Self.details.enumerated() {
			if let detailButton = detailsButtons[safe: index]?.button,
			   let part = self.partsLists
					.compactMap({ $0.items })
					.reduce([], +)
					.first(where: { $0.id == detail.id[0] }) {
				
				detailButton.isSelected = part.isSelected
			}
		}
	}
	
	private func creteScrollView() -> UIScrollView {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.delegate = self
		return scrollView
	}
	
	private static func createDetailsContainerView() -> UIView {
		let detailsContainerView = UIView()
		detailsContainerView.backgroundColor = .clear
		return detailsContainerView
	}
	
	private struct Detail {
		let id: [Int]
		let defaultImageName: String
		let selectedImageName: String
		let origin: CGPoint
	}
	
	private static let details: [Detail] = [
		.init(
			id: [15],
			defaultImageName: "front_bumper",
			selectedImageName: "front_bumper_selected",
			origin: .init(x: 98.37, y: 1)
		),
		.init(
			id: [23],
			defaultImageName: "front_door_glass_left",
			selectedImageName: "front_door_glass_left_selected",
			origin: .init(x: 98.17, y: 164.16)
		),
		.init(
			id: [24],
			defaultImageName: "front_door_glass_right",
			selectedImageName: "front_door_glass_right_selected",
			origin: .init(x: 216.16, y: 164.16)
		),
		.init(
			id: [17],
			defaultImageName: "front_door_left",
			selectedImageName: "front_door_left_selected",
			origin: .init(x: 40.72, y: 150.36)
		),
		.init(
			id: [16],
			defaultImageName: "front_door_right",
			selectedImageName: "front_door_right_selected",
			origin: .init(x: 249.08, y: 150.36)
		),
		.init(
			id: [5],
			defaultImageName: "front_fender_left",
			selectedImageName: "front_fender_left_selected",
			origin: .init(x: 40.29, y: 27.1)
		),
		.init(
			id: [6],
			defaultImageName: "front_fender_right",
			selectedImageName: "front_fender_right_selected",
			origin: .init(x: 249.48, y: 27.1)
		),
		.init(
			id: [32],
			defaultImageName: "front_wheel_left",
			selectedImageName: "front_wheel_left_selected",
			origin: .init(x: 13, y: 57.53)
		),
		.init(
			id: [33],
			defaultImageName: "front_wheel_right",
			selectedImageName: "front_wheel_right_selected",
			origin: .init(x: 274.6, y: 57.53)
		),
		.init(
			id: [1],
			defaultImageName: "hood",
			selectedImageName: "hood_selected",
			origin: .init(x: 102.9, y: 27.96)
		),
		.init(
			id: [11],
			defaultImageName: "headlight_left",
			selectedImageName: "headlight_left_selected",
			origin: .init(x: 105.61, y: 40.61)
		),
		.init(
			id: [10],
			defaultImageName: "headlight_right",
			selectedImageName: "headlight_right_selected",
			origin: .init(x: 197.96, y: 40.61)
		),
		.init(
			id: [36],
			defaultImageName: "airbag_driver",
			selectedImageName: "airbag_driver_selected",
			origin: .init(x: 114.56, y: 116.19)
		),
		.init(
			id: [37],
			defaultImageName: "airbag_passenger",
			selectedImageName: "airbag_passenger_selected",
			origin: .init(x: 188.78, y: 116.19)
		),
		.init(
			id: [9],
			defaultImageName: "radiator_grill",
			selectedImageName: "radiator_grill_selected",
			origin: .init(x: 145.81, y: 1.54)
		),
		.init(
			id: [14],
			defaultImageName: "rear_bumper",
			selectedImageName: "rear_bumper_selected",
			origin: .init(x: 99.1, y: 409.94)
		),
		.init(
			id: [27],
			defaultImageName: "rear_door_glass_left",
			selectedImageName: "rear_door_glass_left_selected",
			origin: .init(x: 100.29, y: 236.79)
		),
		.init(
			id: [28],
			defaultImageName: "rear_door_glass_right",
			selectedImageName: "rear_door_glass_right_selected",
			origin: .init(x: 214.82, y: 236.79)
		),
		.init(
			id: [18],
			defaultImageName: "rear_door_left",
			selectedImageName: "rear_door_left_selected",
			origin: .init(x: 40.55, y: 228.95)
		),
		.init(
			id: [20, 21],
			defaultImageName: "rear_door_or_trunk_lid",
			selectedImageName: "rear_door_or_trunk_lid_selected",
			origin: .init(x: 100.62, y: 333.89)
		),
		.init(
			id: [19],
			defaultImageName: "rear_door_right",
			selectedImageName: "rear_door_right_selected",
			origin: .init(x: 249.08, y: 228.95)
		),
		.init(
			id: [7],
			defaultImageName: "rear_fender_left",
			selectedImageName: "rear_fender_left_selected",
			origin: .init(x: 41.94, y: 287.91)
		),
		.init(
			id: [8],
			defaultImageName: "rear_fender_right",
			selectedImageName: "rear_fender_right_selected",
			origin: .init(x: 248.1, y: 287.91)
		),
		.init(
			id: [29],
			defaultImageName: "rear_sidewall_glass_left",
			selectedImageName: "rear_sidewall_glass_left_selected",
			origin: .init(x: 100.69, y: 288.75)
		),
		.init(
			id: [30],
			defaultImageName: "rear_sidewall_glass_right",
			selectedImageName: "rear_sidewall_glass_right_selected",
			origin: .init(x: 229.26, y: 288.75)
		),
		.init(
			id: [34],
			defaultImageName: "rear_wheel_left",
			selectedImageName: "rear_wheel_left_selected",
			origin: .init(x: 19.43, y: 315.76)
		),
		.init(
			id: [35],
			defaultImageName: "rear_wheel_right",
			selectedImageName: "rear_wheel_right_selected",
			origin: .init(x: 268.26, y: 315.76)
		),
		.init(
			id: [31],
			defaultImageName: "rear_window",
			selectedImageName: "rear_window_selected",
			origin: .init(x: 103.2, y: 305.22)
		),
		.init(
			id: [2],
			defaultImageName: "roof",
			selectedImageName: "roof_selected",
			origin: .init(x: 124.18, y: 174.64)
		),
		.init(
			id: [38],
			defaultImageName: "airbag_side_left",
			selectedImageName: "airbag_side_left_selected",
			origin: .init(x: 131.48, y: 187.19)
		),
		.init(
			id: [39],
			defaultImageName: "airbag_side_right",
			selectedImageName: "airbag_side_right_selected",
			origin: .init(x: 191.38, y: 187.19)
		),
		.init(
			id: [11],
			defaultImageName: "taillight_left",
			selectedImageName: "taillight_left_selected",
			origin: .init(x: 101.55, y: 374.15)
		),
		.init(
			id: [13],
			defaultImageName: "taillight_right",
			selectedImageName: "taillight_right_selected",
			origin: .init(x: 201.09, y: 374.15)
		),
		.init(
			id: [3],
			defaultImageName: "threshold_left",
			selectedImageName: "threshold_left_selected",
			origin: .init(x: 22.04, y: 115.16)
		),
		.init(
			id: [4],
			defaultImageName: "threshold_right",
			selectedImageName: "threshold_right_selected",
			origin: .init(x: 308.22, y: 115.16)
		),
		.init(
			id: [22],
			defaultImageName: "windscreen",
			selectedImageName: "windscreen_selected",
			origin: .init(x: 107.13, y: 140.52)
		),
		.init(
			id: [25],
			defaultImageName: "rear_view_mirror_left",
			selectedImageName: "rear_view_mirror_left_selected",
			origin: .init(x: 84.82, y: 138.05)
		),
		.init(
			id: [26],
			defaultImageName: "rear_view_mirror_right",
			selectedImageName: "rear_view_mirror_right_selected",
			origin: .init(x: 228.77, y: 138.05)
		),
	]
	
	@objc private func onDetailButton(_ sender: UIButton) {
		if let buttonEntry = detailsButtons.first(where: { $0.0 === sender }) {
			if let detail = buttonEntry.1?() {
				if detail.id.count > 1 {
					singleSelection?(detail.id) { selected in
						sender.isSelected = selected
					}
				} else {
					if let part = self.partsLists.compactMap({ $0.items }).reduce([], +).first(where: {
						$0.id == detail.id[0]
					}) {
						sender.isSelected.toggle()
						part.isSelected = sender.isSelected
					}
				}
				
				updateSelection?()
			}
		}
	}
		
	private func createZoomInButton() -> UIButton {
		let zoomInButton = Self.createZoomButton(image: .Icons.plus)
		zoomInButton.addTarget(
			self,
			action: #selector(onZoomInButton),
			for: .touchUpInside
		)
		return zoomInButton
	}
	
	private func createZoomOutButton() -> UIButton {
		let zoomOutButton = Self.createZoomButton(image: .Icons.minus)
		zoomOutButton.addTarget(
			self,
			action: #selector(onZoomOutButton),
			for: .touchUpInside
		)
		return zoomOutButton
	}
	
	private static func createZoomButton(image: UIImage) -> UIButton {
		let button = UIButton()
		button.setImage(
			image,
			for: .normal
		)
		button.tintColor = .Icons.iconPrimary
		button.width(Constants.zoomButtonWidth)
		button.aspectRatio(1)
		
		button.clipsToBounds = false
		button.layer.shadowRadius = 18
		button.layer.shadowOffset = .init(
			width: 0,
			height: 3
		)
		button.layer.shadowPath = UIBezierPath(
			roundedRect: .init(
				origin: .zero,
				size: .init(
					width: Constants.zoomButtonWidth,
					height: Constants.zoomButtonWidth
				)
			),
			cornerRadius: Constants.zoomButtonWidth / 2
		).cgPath
		button.layer.shadowOpacity = 1
		
		updateZoomButton(button)
		
		return button
	}
	
	private func updateZoomButtons() {
		Self.updateZoomButton(zoomInButton)
		Self.updateZoomButton(zoomOutButton)
	}
	
	private static func updateZoomButton(_ button: UIButton) {
		button.setBackgroundImage(
			.backgroundImage(
				withColor: .Background.segmentedControl,
				size: .init(
					width: Constants.zoomButtonWidth,
					height: Constants.zoomButtonWidth
				)
			).roundedImage,
			for: .normal
		)
		
		button.layer.shadowColor = UIColor.Shadow.shadow.cgColor
	}
	
	@objc private func onZoomInButton() {
		scrollView.setZoomScale(
			min(
				scrollView.maximumZoomScale,
				scrollView.zoomScale + Constants.zoomStep
			),
			animated: true
		)
	}
	
	@objc private func onZoomOutButton() {
		scrollView.setZoomScale(
			max(
				scrollView.minimumZoomScale,
				scrollView.zoomScale - Constants.zoomStep
			),
			animated: true
		)
	}
	
	func configure(
		with partsLists: [BDUI.SchemeItemsListComponentDTO],
		updateSelection: @escaping () -> Void,
		singleSelection: @escaping ([Int], _ selectionCallback: ((Bool) -> Void)?) -> Void
	) {
		self.partsLists = partsLists
		self.updateSelection = updateSelection
		self.singleSelection = singleSelection
	}
	
	// MARK: - UIScrollViewDelegate
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return detailsContainerView
	}
	
	// MARK: - Constants
	
	enum Constants {
		static let size = CGSize(
			width: 343,
			height: 446
		)
		static let zoomButtonWidth: CGFloat = 42
		static let zoomStep: CGFloat = 0.5
	}
}
