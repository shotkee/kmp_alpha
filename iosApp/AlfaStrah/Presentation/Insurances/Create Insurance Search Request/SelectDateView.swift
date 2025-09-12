//
//  InsuranceDataIssueDateView.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 30.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class SelectDateView: UIView {
    var targetView: UIView?

    @IBOutlet private var datePicker: UIDatePicker!

	@IBOutlet private var chooseButton: UIButton! {
		didSet {
			chooseButton.titleLabel?.font = Style.Font.buttonLarge
		}
	}
	
	func set(timeZone: TimeZone?) {
        datePicker.timeZone = timeZone
    }

    var onDateSelected: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
    }

    func toggleTimeMode() {
        datePicker.datePickerMode = .time
        datePicker.minimumDate = Date(timeIntervalSince1970: 0)
        datePicker.maximumDate = Date()
    }

    func toggleDateMode() {
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date(timeIntervalSince1970: 0)
        datePicker.maximumDate = Date()
    }

    func set(date: Date) {
        datePicker.date = date
    }

    @IBAction private func dateChanged() {
        onDateSelected?(datePicker.date)
    }
}
