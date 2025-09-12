//
//  TimeInputWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 22.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TimeInputWidgetView: WidgetView<TimeInputWidgetDTO> {
		private var userInputView: UserSingleLineInputView?
		
		private lazy var datePicker: UIDatePicker = .init(frame: .zero)
		
		required init(
			block: TimeInputWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			self.userInputView = UserSingleLineInputView(
				floatingTitle: block.floatingTitle,
				text: block.text,
				placeholder: block.placeholder,
				error: block.error,
				themedBackgroundColor: block.themedBackgroundColor,
				isEnabled: {
					switch block.state {
						case .normal:
							return true
						case .disabled:
							return false
					}
				}(),
				focusedBorderColor: block.focusedBorderColor,
				errorBorderColor: block.errorBorderColor,
				accessoryThemedColor: block.arrow?.themedColor,
				inputCompleted: { text in
					self.replaceFormData(with: text)
				}
			)
			
			setupUI()
			setupDatePicker()
			
			if let defaultPickerDate = block.timeDefault {
				datePicker.date = defaultPickerDate
			}
			
			if let maximumPickerDate = block.timeTo {
				datePicker.maximumDate = maximumPickerDate
			}
			
			if let minimumPickerDate = block.timeFrom {
				datePicker.minimumDate = minimumPickerDate
			}
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			if let userInputView {
				addSubview(userInputView)
				
				userInputView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			}
		}
		
		private func setupDatePicker() {
			datePicker.locale = AppLocale.currentLocale
			datePicker.datePickerMode = .time
			datePicker.addTarget(self, action: #selector(pickTime), for: .valueChanged)
			
			if #available(iOS 13.4, *) {
				datePicker.preferredDatePickerStyle = .wheels
			}
			
			userInputView?.textField.inputView = datePicker
		}
		
		@objc func pickTime() {
			if let datePicker = userInputView?.textField.inputView as? UIDatePicker {
				let pickedTime = datePicker.date
				let timeString = dateFormatter.string(from: pickedTime)
				userInputView?.textField.text = timeString
			}
		}
		
		private var dateFormatter: DateFormatter = {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "HH:mm"
			return dateFormatter
		}()
	}
}
