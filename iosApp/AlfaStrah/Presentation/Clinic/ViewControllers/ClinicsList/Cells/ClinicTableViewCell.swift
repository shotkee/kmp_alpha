//
//  ClinicTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 08.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class ClinicTableViewCell: UITableViewCell 
{
	static let id: Reusable<ClinicTableViewCell> = .fromClass()
	
	// MARK: - Outlets
	private var containerView = UIView()
	private var infomationStackView = createStackView(axis: .vertical)
	private var bottomStackView = createStackView(axis: .horizontal)
	private var advantagesView = UIView()
	private var advantagesStackView = createAdvantagesStackView()
	private var registerOnlineButton = createRegisterOnlineButton()
	private var phoneButton = RoundEdgeButton()
	private var websiteButton = RoundEdgeButton()
	
	// MARK: - Variables
	private var clinic: Clinic?
	private var tapWebSiteCallback: ((URL?) -> Void)?
	private var tapCallCallback: (([Phone]) -> Void)?
	private var tapClinicCallback: ((Clinic) -> Void)?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setupUI()
	}
}

extension ClinicTableViewCell
{
	func setup(
		clinic: Clinic,
		tapWebSiteCallback: @escaping ((URL?) -> Void),
		tapCallCallback: @escaping (([Phone]) -> Void),
		tapClinicCallback: @escaping ((Clinic) -> Void)
	)
	{
		self.clinic = clinic
		self.tapWebSiteCallback = tapWebSiteCallback
		self.tapCallCallback = tapCallCallback
		self.tapClinicCallback = tapClinicCallback
		infomationStackView.subviews.forEach { $0.removeFromSuperview() }
		setupClinicInformationView(clinic: clinic)
		setupAdvantagesView(serivceList: clinic.serviceList)
		bottomStackView.subviews.forEach { $0.removeFromSuperview() }
		setupRegisterOnlineButton(title: clinic.buttonText ?? "")
		setupWebsiteButton()
		setupPhoneButton()
		setupPhoneAndWebsiteStackView()
		setVisibleWebsiteButton()
		setVisiblePhoneButton()
	}
}

private extension ClinicTableViewCell
{
	static func createStackView(axis: NSLayoutConstraint.Axis) -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = axis
		stackView.spacing = 12
		
		return stackView
	}
	
	static func createAdvantagesStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 4
		
		return stackView
	}
	
	static func createRegisterOnlineButton() -> RoundEdgeButton
	{
		let button = RoundEdgeButton()
		button <~ Style.RoundedButton.primaryButtonSmall
		button.setTitle(
			NSLocalizedString("clinic_confirm_online", comment: ""),
			for: .normal
		)
		
		return button
	}
	
	func setupUI()
	{
		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		setupContainerView()
		setupInfomationStackView()
		setupBottomStackView()
	}
	
	private func setupContainerView() {
		containerView.backgroundColor = .Background.backgroundSecondary

		let cardView = containerView.embedded(
			margins: insets(v: 7, h: 18),
			hasShadow: true
		)
		
		contentView.addSubview(cardView)
		
		cardView.edges(to: contentView)
	}
	
	func setupInfomationStackView()
	{
		containerView.addSubview(infomationStackView)
		infomationStackView.edgesToSuperview(
			excluding: .bottom,
			insets: .init(
				top: 15,
				left: 15,
				bottom: 0,
				right: 15
			)
		)
	}
	
	func setupBottomStackView()
	{
		containerView.addSubview(bottomStackView)
		bottomStackView.edgesToSuperview(
			excluding: .top,
			insets: .init(
				top: 0,
				left: 15,
				bottom: 15,
				right: 15
			)
		)
		bottomStackView.topToBottom(of: infomationStackView, offset: 15)
	}
	
	func setupClinicInformationView(clinic: Clinic)
	{
		let clinicInformationView = ClinicInformationView(clinic: clinic)
		infomationStackView.addArrangedSubview(clinicInformationView)
	}
	
	func setupAdvantagesView(serivceList: [String])
	{
		advantagesView.addSubview(advantagesStackView)
		advantagesStackView.edgesToSuperview()
		advantagesStackView.subviews.forEach { $0.removeFromSuperview() }
		
		serivceList.forEach
		{
			text in
			
			advantagesStackView.addArrangedSubview(
				createAdvantagesLabelContainerView(text: text)
			)
		}
		
		infomationStackView.addArrangedSubview(advantagesView)
	}
	
	func createAdvantagesLabelContainerView(text: String) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		let label = UILabel()
		label <~ Style.Label.secondarySubhead
		label.numberOfLines = 2
		label.text = text
		
		view.addSubview(label)
		label.edgesToSuperview()
		
		return view
	}
	
	func setupRegisterOnlineButton(title: String)
	{
		bottomStackView.addArrangedSubview(registerOnlineButton)
		registerOnlineButton.setTitle(title, for: .normal)
		registerOnlineButton.addTarget(
			self,
			action: #selector(tapRegisterOnlineButton),
			for: .touchUpInside
		)
		registerOnlineButton.height(36)
	}
	
	@objc func tapRegisterOnlineButton()
	{
		guard let clinic = self.clinic
		else { return }
	
		self.tapClinicCallback?(clinic)
	}
	
	func setupWebsiteButton()
	{
		websiteButton <~ Style.RoundedButton.primaryButtonSmallWithoutBorder
		websiteButton.setImage(
			.Icons.website
				.resized(newWidth: 16)?
				.tintedImage(withColor: .Icons.iconAccent),
			for: .normal
		)
		websiteButton.contentEdgeInsets = UIEdgeInsets(
			top: 10,
			left: 10,
			bottom: 10,
			right: 10
		)
		websiteButton.addTarget(
			self,
			action: #selector(tapWebsiteButton),
			for: .touchUpInside
		)
		websiteButton.width(36)
		websiteButton.heightToWidth(of: websiteButton)
	}
	
	@objc func tapWebsiteButton()
	{
		tapWebSiteCallback?(self.clinic?.url)
	}
	
	func setupPhoneButton()
	{
		phoneButton <~ Style.RoundedButton.primaryButtonSmallWithoutBorder
		phoneButton.setImage(
			.Icons.largePhone
				.resized(newWidth: 16)?
				.tintedImage(withColor: .Icons.iconAccent),
			for: .normal
		)
		phoneButton.contentEdgeInsets = UIEdgeInsets(
			top: 10,
			left: 10,
			bottom: 10,
			right: 10
		)
		phoneButton.width(36)
		phoneButton.heightToWidth(of: phoneButton)
		
		phoneButton.addTarget(self, action: #selector(tapPhoneButton), for: .touchUpInside)
	}
	
	@objc func tapPhoneButton()
	{
		guard let clinic = clinic
		else { return }
		
		tapCallCallback?(clinic.phoneList ?? [])
	}
	
	func setupPhoneAndWebsiteStackView()
	{
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.addArrangedSubview(websiteButton)
		stackView.addArrangedSubview(phoneButton)
		bottomStackView.addArrangedSubview(stackView)
	}
	
	func setVisibleWebsiteButton()
	{
		guard let clinic = self.clinic
		else { return }
		
		self.websiteButton.isHidden = clinic.url == nil
	}
	
	func setVisiblePhoneButton()
	{
		guard let clinic = self.clinic
		else { return }
		
		self.phoneButton.isHidden = (clinic.phoneList ?? []).isEmpty
	}
}
