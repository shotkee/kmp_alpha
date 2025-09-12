//
//  DateOfBirthViewController.swift
//  AlfaStrah
//
//  Created by Илья Матвеев on 12.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import TinyConstraints

class DateOfBirthViewController: ViewController {
	private let birthDateInput = CommonTextInput()
	private let continueButton = RoundEdgeButton()
	private let errorLabel = UILabel()
	private var pickedDate: Date?
	
	struct Output {
		let verify: (_ birthday: Date) -> Void
		let openChat: () -> Void
	}
	
	var output: Output!

	private var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd.MM.yyyy"
		return dateFormatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
				
		title = NSLocalizedString("forgotten_password_title", comment: "")
		
		view.backgroundColor = .Background.backgroundContent
				
		setupInputViews()
		setupContinueButton()
		setupContinueErrorLabel()
	}
	
	private func setupContinueErrorLabel() {
		view.addSubview(errorLabel)
		errorLabel <~ Style.Label.negativeSubhead
		errorLabel.numberOfLines = 0

		errorLabel.horizontalToSuperview(insets: .horizontal(Constants.horizontalInsets))
		errorLabel.topToBottom(of: birthDateInput, offset: 5)
	}
		
	private func setupInputViews() {
		let descriptionLabel = UILabel()
		descriptionLabel <~ Style.Label.secondaryText
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = NSLocalizedString("date_of_birth_screen_description", comment: "")
		
		view.addSubview(descriptionLabel)
		descriptionLabel.topToSuperview(offset: 20)
		descriptionLabel.horizontalToSuperview(insets: .horizontal(Constants.horizontalInsets))
		
		birthDateInput.textField.placeholder = NSLocalizedString("date_of_birth_screen_placeholder", comment: "")
		let datePickerView: UIDatePicker = UIDatePicker()
		datePickerView.date = Date()
		datePickerView.datePickerMode = .date
		if #available(iOS 13.4, *) {
			datePickerView.preferredDatePickerStyle = .wheels
		}
		datePickerView.maximumDate = Date()
		datePickerView.locale = AppLocale.currentLocale
		birthDateInput.textField.inputView = datePickerView
		datePickerView.addTarget(self, action: #selector(birthDatePicked), for: .valueChanged)
		
		view.addSubview(birthDateInput)
		birthDateInput.topToBottom(of: descriptionLabel, offset: 24)
		birthDateInput.horizontalToSuperview(insets: .horizontal(Constants.horizontalInsets))
		
		addRightButton(title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""), action: output.openChat)
	}
	
	private func setupContinueButton() {
		view.addSubview(continueButton)
		
		continueButton <~ Style.RoundedButton.primaryButtonSmall
		
		continueButton.setTitle(
			NSLocalizedString("common_continue", comment: ""),
			for: .normal
		)
		continueButton.addTarget(self, action: #selector(continueButtonTap), for: .touchUpInside)
		continueButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			continueButton.heightAnchor.constraint(equalToConstant: 48),
		])
		
		continueButton.isEnabled = false
		
		continueButton.bottomToSuperview(offset: -9, usingSafeArea: true)
		continueButton.horizontalToSuperview(insets: .horizontal(Constants.horizontalInsets))
	}
	
	func showError(errorText: String) {
		errorLabel.text = errorText
		birthDateInput.showErrorState = true
		birthDateInput.error(show: true)
		continueButton.isEnabled = false
	}
	
	private func hideErrors() {
		errorLabel.text = ""
		birthDateInput.error(show: false)
	}
	
	@objc func birthDatePicked() {
		if let datePicker = birthDateInput.textField.inputView as? UIDatePicker {
			let pickedDate = datePicker.date
			let dateString = dateFormatter.string(from: pickedDate)

			if let dateDiff = Date.yearsDiff(recent: pickedDate, previous: Date()),
			   dateDiff < 18 {
				showError(errorText: NSLocalizedString("date_of_birth_screen_age_limit_error", comment: ""))
			} else {
				hideErrors()
				continueButton.isEnabled = true
			}
			
			birthDateInput.textField.text = dateString
			self.pickedDate = pickedDate
		}
	}
	
	@objc func continueButtonTap() {
		guard let pickedDate
		else { return }

		output.verify(pickedDate)
	}
	
	struct Constants {
		static let horizontalInsets: CGFloat = 18
	}
}

extension Date {
	
	static func yearsDiff(recent: Date, previous: Date) -> Int? {
		let years = Calendar.current.dateComponents([.year], from: previous, to: recent).year
		if let years {
			return years < 0 ? -(years) : years
		}
		return nil
	}

}
