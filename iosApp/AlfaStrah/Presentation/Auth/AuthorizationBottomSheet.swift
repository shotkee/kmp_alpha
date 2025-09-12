//
//  AuthorizationBottomSheet.swift
//  AlfaStrah
//
//  Created by Makson on 17.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import TinyConstraints

enum AuthorizationBottomSheet
{
	enum ButtonType
	{
		case registration
		case gosuslugi
		case email
		case phone
	}
	
	static func showAllRegistrationMethodsBottomSheet(
		from: ViewController,
		registration: @escaping (() -> Void),
		gosuslugi: @escaping (() -> Void),
		email: @escaping (() -> Void),
		phone: @escaping (() -> Void)
	)
	{
		let bottomSheetController = BaseBottomSheetViewController()
		bottomSheetController.set(
			title: NSLocalizedString("auth_sign_all_methods_registration_title", comment: "")
		)
		
		bottomSheetController.add(
			view: createInfoView(
				description: NSLocalizedString("auth_sign_all_methods_registration_description", comment: ""),
				registration: registration,
				gosuslugi: gosuslugi,
				email: email,
				phone: phone
			)
		)
		bottomSheetController.set(style: .empty)
		bottomSheetController.closeTapHandler = { [weak from] in
			from?.dismiss(animated: true)
		}
		
		from.showBottomSheet(contentViewController: bottomSheetController)
	}
	
	static func showErrorOTPAuthorizationBottomSheet(
		from: ViewController,
		title: String,
		description: String,
		registration: @escaping (() -> Void),
		gosuslugi: @escaping (() -> Void),
		email: @escaping (() -> Void)
	)
	{
		let bottomSheetController = BaseBottomSheetViewController()
		bottomSheetController.set(
			title: title
		)
		
		bottomSheetController.add(
			view: createInfoView(
				description: description,
				registration: registration,
				gosuslugi: gosuslugi,
				email: email
			)
		)
		bottomSheetController.set(style: .empty)
		bottomSheetController.closeTapHandler = { [weak from] in
			from?.dismiss(animated: true)
		}
		
		from.showBottomSheet(contentViewController: bottomSheetController)
	}
	
	private static func createInfoView(
		description: String,
		registration: @escaping (() -> Void),
		gosuslugi: @escaping (() -> Void),
		email: @escaping (() -> Void),
		phone: (() -> Void)? = nil
	) -> UIView
	{
		let view = UIView()
		let stackView = UIStackView()
		stackView.axis = .vertical
		view.addSubview(stackView)
		stackView.edgesToSuperview()
		
		// descriptionLabel
		let descriptionLabel = UILabel()
		descriptionLabel <~ Style.Label.primaryText
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = description
		descriptionLabel.textAlignment = .left
		stackView.addArrangedSubview(descriptionLabel)
		stackView.setCustomSpacing(32, after: descriptionLabel)
		
		let buttonStackView = UIStackView()
		buttonStackView.axis = .vertical
		buttonStackView.spacing = 8
		
		buttonStackView.addArrangedSubview(
			createButton(
				type: .registration,
				action: registration
			)
		)
		
		buttonStackView.addArrangedSubview(
			createButton(
				type: .gosuslugi,
				action: gosuslugi
			)
		)
		
		buttonStackView.addArrangedSubview(
			createButton(
				type: .email,
				action: email
			)
		)
		
		if let phoneAction = phone
		{
			buttonStackView.addArrangedSubview(
				createButton(
					type: .phone,
					action: phoneAction
				)
			)
		}
		
		stackView.addArrangedSubview(
			buttonStackView
		)
		
		return view
	}
	
	private static func createButton(
		type: ButtonType,
		action: (() -> Void)? = nil
	) -> RoundEdgeButton
	{		
		let button = RoundEdgeButton()
		button <~ Style.RoundedButton.oldOutlinedButtonSmall
		button.height(48)
		button.action = action
		
		switch type
		{
			case .registration:
				button.setTitle(NSLocalizedString("all_registration_methods_registration_title", comment: ""), for: .normal)
			
			case .gosuslugi:
				button.setTitle(NSLocalizedString("all_registration_methods_gosuslugi_title", comment: ""), for: .normal)
				button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
				button.setImage(UIImage(named: "icon-esia-logo"), for: .normal)
			
			case .email:
				button.setTitle(NSLocalizedString("all_registration_methods_email_title", comment: ""), for: .normal)
			
			case .phone:
				button.setTitle(NSLocalizedString("all_registration_methods_phone_title", comment: ""), for: .normal)
		}
		
		return button
	}
}
