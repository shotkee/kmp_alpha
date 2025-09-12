//
//  DateInputWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 22.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DateInputWidgetView: WidgetView<DateInputWidgetDTO> {
		private var userInputView: UserSingleLineInputView?
		
		private lazy var datePicker: UIDatePicker = .init(frame: .zero)
		
		required init(
			block: DateInputWidgetDTO,
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
				inputCompleted: { _ in
					self.replaceFormData(with: self.dateFormatterForFormData.string(from: self.datePicker.date))
				}
			)
			
			self.userInputView?.textField.keyboardType = .numberPad
			
			setupUI()
			setupDatePicker()
			
			if let defaultPickerDate = block.dateDefault {
				datePicker.date = defaultPickerDate
			}
			
			if let maximumPickerDate = block.dateTo {
				datePicker.maximumDate = maximumPickerDate
			}
			
			if let minimumPickerDate = block.dateFrom {
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
			datePicker.timeZone = TimeZone(abbreviation: "UTC")
			datePicker.datePickerMode = .date
			datePicker.addTarget(self, action: #selector(pickDate), for: .valueChanged)
			
			if #available(iOS 13.4, *) {
				datePicker.preferredDatePickerStyle = .wheels
			}
			
			userInputView?.textField.inputView = datePicker
		}
		
		@objc func pickDate() {
			if let datePicker = userInputView?.textField.inputView as? UIDatePicker {
				let pickedDate = datePicker.date
				let dateString = dateFormatterForUI.string(from: pickedDate)
				userInputView?.textField.text = dateString
			}
		}
		
		private var dateFormatterForUI: DateFormatter = {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "dd.MM.yyyy"
			dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
			return dateFormatter
		}()
		
		private var dateFormatterForFormData: DateFormatter = {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd"
			dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
			return dateFormatter
		}()
	}
}
