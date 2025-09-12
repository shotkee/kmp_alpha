//
//  DateInputBottomViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class DateInputBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
        let mode: UIDatePicker.Mode
        let date: Date
        let maximumDate: Date?
        let minimumDate: Date?
    }

    struct Output {
        let close: () -> Void
        let selectDate: (Date) -> Void
    }

    var input: Input!
    var output: Output!

    private lazy var datePicker: UIDatePicker = .init(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            self.output.selectDate(self.datePicker.date)
        }
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
        set(views: [ datePicker ])
        set(doneButtonEnabled: true)

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = input.mode
        datePicker.locale = AppLocale.currentLocale
        datePicker.date = input.date
        datePicker.maximumDate = input.maximumDate
        datePicker.minimumDate = input.minimumDate
    }
}
