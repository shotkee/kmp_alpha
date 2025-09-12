//
//  TimeInputBottomViewController
//  AlfaStrah
//
//  Created by Amir Nuriev on 7/25/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class TimeInputBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
    }

    struct Output {
        let close: () -> Void
        let selectTime: (Date) -> Void
    }

    var input: Input!
    var output: Output!

    private lazy var timePicker: UIDatePicker = {
        let value: UIDatePicker = .init(frame: .zero)
        value.datePickerMode = .countDownTimer
        value.locale = AppLocale.currentLocale
        value.minuteInterval = 15

        return value
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            self.output.selectTime(self.timePicker.date)
        }
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
        set(doneButtonEnabled: true)
        set(views: [ timePicker ])

        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        timePicker.maximumDate = Date(timeIntervalSinceNow: 30 * 60)
    }
}
