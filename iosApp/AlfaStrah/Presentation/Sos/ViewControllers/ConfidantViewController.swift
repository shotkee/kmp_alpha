//
//  ConfidantViewController.swift
//  AlfaStrah
//
//  Created by Makson on 05.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints
import IQKeyboardManagerSwift
import ContactsUI
import Contacts

class ConfidantViewController: ViewController,
								 CNContactPickerDelegate,
								 UITextPasteDelegate
{
	enum State 
	{
		case failure
		case filled
	}
	
	enum Mode
	{
		case save
		case saveChanges(Confidant)
	}
	
	// MARK: - Outlets
	private let previousNextView = IQPreviousNextView()
	private let initialsStackView = UIStackView()
	private let nameTextField = CommonTextInput()
	private let phoneTextField = CommonTextInput()
	private let buttonsStackView = UIStackView()
	private let selectContactButton = RoundEdgeButton()
	private let saveOrChangesButton = RoundEdgeButton()
	private var bottomButtonsStackViewConstraint: Constraint?
	private let operationStatusView = OperationStatusView()
	
	private lazy var deleteBarButton = createNavigationBarButton(
		title: NSLocalizedString("common_delete", comment: ""),
		selector: #selector(deleteButtonTap)
	)
	
	private var state: State = .filled
	
	// MARK: - Contacts
	private let store = CNContactStore()
	
	struct Input {
		var mode: Mode
	}

	struct Output {
		var delete: () -> Void
		var goToUserContacts: (CNContactPickerViewController) -> Void
		var saveOrChangesData: (_ name: String, _ phone: String) -> Void
		var goToSettings: () -> Void
		var goToChat: () -> Void
	}

	var input: Input!
	var output: Output!
	
	struct Notify {
		let updateWithState: (_ state: State) -> Void
	}
	
	// swiftlint:disable:next trailing_closure
	private(set) lazy var notify = Notify(
		updateWithState: { [weak self] state in
			guard let self = self,
				  self.isViewLoaded
			else { return }

			self.update(with: state)
		}
	)

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupUI()
    }
	
	private func setupUI()
	{
		view.backgroundColor = .Background.backgroundContent
		title = NSLocalizedString("sos_confidant_title", comment: "")
		switch input.mode
		{
			case .save:
				navigationItem.rightBarButtonItem = nil
			
			case .saveChanges:
				navigationItem.rightBarButtonItem = deleteBarButton
		}
		setupPreviousNextView()
		setupInitialsStackView()
		setupNameTextField()
		setupPhoneTextField()
		setupButtonsStackView()
		setupSelectСontactButton()
		setupSaveOrChangesButton()
		subscribeForKeyboardNotifications()
		setupOperationStatusView()
		update(with: state)
		switch input.mode {
			case .save:
				setTextTextFields(initialsPerson: nil, phone: nil)
			
			case .saveChanges(let confidant):
				setTextTextFields(initialsPerson: confidant.name, phone: confidant.phone.plain)
		}
	}
	
	private func setupOperationStatusView()
	{
		view.addSubview(operationStatusView)
		operationStatusView.edgesToSuperview()
	}
	
	private func update(with state: State) 
	{
		self.state = state
		switch state
		{
			case .failure:
				let state: OperationStatusView.State = .info(
					.init(
						title: NSLocalizedString("sos_confidant_error_title", comment: ""),
						description: NSLocalizedString("sos_confidant_error_description", comment: ""),
						icon: .Icons.cross
					)
				)
			
				let buttons: [OperationStatusView.ButtonConfiguration] = [
					.init(
						title: NSLocalizedString("common_go_to_chat", comment: ""),
						isPrimary: false,
						action: { [weak self] in
							self?.output.goToChat()
						}
					),
					.init(
						title: NSLocalizedString("sos_confidant_error_retry_button", comment: ""),
						isPrimary: true,
						action: { [weak self] in
							self?.update(with: .filled)
						}
					)
				]
				operationStatusView.notify.updateState(state)
				operationStatusView.notify.buttonConfiguration(buttons)
			
				navigationItem.rightBarButtonItem = nil
				operationStatusView.isHidden = false
			
			case .filled:
				operationStatusView.isHidden = true
				switch input.mode
				{
					case .save:
						navigationItem.rightBarButtonItem = nil
				
					case .saveChanges:
						navigationItem.rightBarButtonItem = deleteBarButton
				}
		}
	}
	
	private func setupPreviousNextView()
	{
		view.addSubview(previousNextView)
		previousNextView.edgesToSuperview(
			excluding: .bottom,
			insets: .init(
				top: 16,
				left: 18,
				bottom: 0,
				right: 18
			)
		)
	}
	
	private func setupInitialsStackView()
	{
		initialsStackView.axis = .vertical
		initialsStackView.spacing = 9
		previousNextView.addSubview(initialsStackView)
		initialsStackView.edgesToSuperview()
	}
	
	private func setupNameTextField()
	{
		nameTextField.validateAsYouType = false
		nameTextField.textField.placeholder = NSLocalizedString("sos_confidant_name_text_field_placeholder", comment: "")
		nameTextField.textField.autocapitalizationType = .none
		nameTextField.textField.addTarget(
			self,
			action: #selector(nameTextFieldEditingChanged),
			for: .editingChanged
		)
		initialsStackView.addArrangedSubview(nameTextField)
	}
	
	@objc private func nameTextFieldEditingChanged()
	{
		updateEnableSaveOrDoneButton()
	}
	
	private func setupPhoneTextField()
	{
		phoneTextField.validateAsYouType = false
		phoneTextField.textField.pasteDelegate = self
		phoneTextField.textField.placeholder = NSLocalizedString("sos_confidant_phone_text_field_placeholder", comment: "")
		phoneTextField.textField.keyboardType = .phonePad
		phoneTextField.textField.autocapitalizationType = .none
		phoneTextField.textField.addTarget(
			self,
			action: #selector(phoneTextFieldEditingChanged),
			for: .editingChanged
		)
		initialsStackView.addArrangedSubview(phoneTextField)
	}
	
	@objc private func phoneTextFieldEditingChanged()
	{
		updateEnableSaveOrDoneButton()
	}
	
	private func setupButtonsStackView()
	{
		buttonsStackView.axis = .vertical
		buttonsStackView.spacing = 10
		view.addSubview(buttonsStackView)
		buttonsStackView.horizontalToSuperview(insets: .horizontal(15))
		buttonsStackView.topToBottom(
			of: previousNextView,
			offset: 16,
			relation: .equalOrGreater
		)
		bottomButtonsStackViewConstraint = buttonsStackView.bottomToSuperview(offset: -15, usingSafeArea: true)
		
	}
	
	private func createNavigationBarButton(
		title: String,
		selector: Selector
	) -> UIBarButtonItem {
		
		let barButtonItem = UIBarButtonItem(
			title: title,
			style: .plain,
			target: self,
			action: selector
		)
		
		barButtonItem <~ Style.Button.NavigationItemRed(title: title)

		return barButtonItem
	}
	
	private func setupSelectСontactButton()
	{
		selectContactButton <~ Style.RoundedButton.outlinedButtonLarge
		selectContactButton.setTitle(
			NSLocalizedString("sos_confidant_select_contact_button", comment: ""),
			for: .normal
		)
		selectContactButton.addTarget(self, action: #selector(selectСontactButtonTap), for: .touchUpInside)
		buttonsStackView.addArrangedSubview(selectContactButton)
		selectContactButton.height(48)
	}
	
	@objc func selectСontactButtonTap()
	{
		switch CNContactStore.authorizationStatus(for: .contacts)
		{
			case .notDetermined:
				requestAccess()

			case .restricted:
				break

			case .denied:
				output.goToSettings()

			case .authorized:
				presentUserContacts()

			@unknown default:
				break
		}
	}
	
	private func requestAccess()
	{
		store.requestAccess(for: .contacts)
		{
			[weak self] granted, _ in
				
			guard granted
			else
			{ return }
				
			DispatchQueue.main.async
			{
				[weak self] in
				
				self?.presentUserContacts()
			}
		}
	}
	
	private func presentUserContacts()
	{
		let contactPickerViewController = CNContactPickerViewController()
		contactPickerViewController.delegate = self
		output.goToUserContacts(contactPickerViewController)
	}
	
	private func setupSaveOrChangesButton()
	{
		let titleButton: String
		
		switch input.mode
		{
			case .save:
				titleButton = "sos_confidant_save_button"
			
			case .saveChanges:
				titleButton = "sos_confidant_save_changes_button"
		}
		
		saveOrChangesButton <~ Style.RoundedButton.primaryButtonLarge
		saveOrChangesButton.setTitle(
			NSLocalizedString(
				titleButton,
				comment: ""
			),
			for: .normal
		)
		saveOrChangesButton.addTarget(self, action: #selector(saveOrChangesButtonTap), for: .touchUpInside)
		buttonsStackView.addArrangedSubview(saveOrChangesButton)
		saveOrChangesButton.height(48)
	}
	
	private func updateEnableSaveOrDoneButton()
	{
		switch input.mode
		{
			case .save:
				saveOrChangesButton.isEnabled = !nameTextField.textField.text.isEmptyOrNil && !phoneTextField.textField.text.isEmptyOrNil
			
			case .saveChanges(let confidant):
				saveOrChangesButton.isEnabled = !nameTextField.textField.text.isEmptyOrNil 
					&& !phoneTextField.textField.text.isEmptyOrNil
					&& (confidant.name != nameTextField.textField.text || confidant.phone.plain != phoneTextField.textField.text)
		}
	}
	
	// MARK: - Keyboard notifications handling
	private func subscribeForKeyboardNotifications() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillChange),
			name: UIResponder.keyboardWillChangeFrameNotification,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}
	
	@objc func keyboardWillChange(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification)
	}
	
	@objc func keyboardWillHide(_ notification: NSNotification) {
		bottomButtonsStackViewConstraint?.constant = -15
	}
	
	func moveViewWithKeyboard(notification: NSNotification) {
		guard let userInfo = notification.userInfo,
			  let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
		else { return }
		
		let bottomPadding: CGFloat = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0
			? 15
			: -15
		
		let constraintConstant = -keyboardHeight + bottomPadding
		
		if  bottomButtonsStackViewConstraint?.constant != constraintConstant {
			bottomButtonsStackViewConstraint?.constant = constraintConstant
		}
	}
	
	@objc private func saveOrChangesButtonTap()
	{
		if let name = nameTextField.textField.text,
		   let phone = phoneTextField.textField.text
		{
			view.endEditing(true)
			output.saveOrChangesData(name, phone)
		}
	}
	
	@objc private func deleteButtonTap()
	{
		view.endEditing(true)
		output.delete()
	}
	
	func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact)
	{
		picker.dismiss(
			animated: true,
			completion: {
				updateColorNavigationBar(isSystemNavBarColor: false)
		})
		
		let initialsPerson = getInitialsPerson(
			name: contact.givenName,
			surname: contact.familyName
		)
			
		if contact.phoneNumbers.count == 1
		{
			self.setTextTextFields(
				initialsPerson: initialsPerson,
				phone: self.sanitizedPhoneNumber(
					phone: contact.phoneNumbers[0].value.stringValue
				)
			)
		}
		else if contact.phoneNumbers.count > 1
		{
			presentNumbersUserOfAvailableAlert(
				initialsPerson: initialsPerson,
				phoneNumbers: contact.phoneNumbers
			)
		}
		else if contact.phoneNumbers.isEmpty
		{
			setTextTextFields(
				initialsPerson: initialsPerson,
				phone: nil
			)
		}
	}
	
	private func presentNumbersUserOfAvailableAlert(
		initialsPerson: String?,
		phoneNumbers: [CNLabeledValue<CNPhoneNumber>]
	)
	{
		let multiplePhoneNumbersAlert = UIAlertController(
			title: initialsPerson,
			message: nil,
			preferredStyle: .actionSheet
		)
			
		for phoneNumber in phoneNumbers
		{
			let phone = phoneNumber.value.stringValue
				
			let numberAction = UIAlertAction(
				title: phone,
				style: .default,
				handler:
			{
				[weak self] _ in
				
				guard let self
				else { return }
					
				self.setTextTextFields(
					initialsPerson: initialsPerson,
					phone: self.sanitizedPhoneNumber(phone: phone)
				)
			})
			
			multiplePhoneNumbersAlert.addAction(numberAction)
		}
			
		let cancelAction = UIAlertAction(
			title: "Cancel",
			style: .cancel,
			handler: nil
		)
			
		multiplePhoneNumbersAlert.addAction(cancelAction)

		self.present(
			multiplePhoneNumbersAlert,
			animated: true,
			completion: nil
		)
	}
	
	private func sanitizedPhoneNumber(phone: String) -> String
	{
		return phone.replacingCharacters(
			from: Constants.phoneChars.inverted,
			with: ""
		)
	}
	
	private func getInitialsPerson(name: String?, surname: String?) -> String?
	{
		var initials: [String] = []
		
		if let surname = surname,
		   !surname.isEmpty
		{
			initials.append(surname)
		}
		
		if let name = name,
		   !name.isEmpty
		{
			initials.append(name)
		}
	
		return initials.isEmpty
			? nil
			: initials.joined(separator: " ")
	}
	
	private func setTextTextFields(initialsPerson: String?, phone: String?)
	{
		setNameTextField(initialsPerson: initialsPerson)
		setPhoneTextField(phone: phone)
		updateEnableSaveOrDoneButton()
	}
	
	private func setNameTextField(initialsPerson: String?)
	{
		nameTextField.textField.text = initialsPerson
	}
	
	private func setPhoneTextField(phone: String?)
	{
		phoneTextField.textField.text = phone
	}
	
	func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, transform item: UITextPasteItem)
	{
		_ = item.itemProvider.loadObject(
			ofClass: String.self,
			completionHandler: { object, _ in
				
				guard let string = object
				else { return }
				
				DispatchQueue.main.async { [weak self, weak item] in
					
					guard let self
					else { return }
					
					if let textField = textPasteConfigurationSupporting as? UITextField,
					   let selectedRange = textField.selectedRange
					{
						if textField === phoneTextField.textField
						{
							let sanitizedString = string.replacingCharacters(
								from: Constants.phoneChars.inverted,
								with: ""
							)
							
							item?.setResult(string: sanitizedString)
						}
					}
				}
			}
		)
	}
}

extension ConfidantViewController
{
	enum Constants
	{
		static let phoneChars = CharacterSet.decimalDigits.union(.init(charactersIn: "+#*"))
	}
}
