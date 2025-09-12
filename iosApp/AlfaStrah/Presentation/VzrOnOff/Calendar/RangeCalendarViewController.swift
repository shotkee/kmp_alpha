//
//  RangeCalendar.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 23.10.2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

enum CalendarTheme {
    case themeDefault
}

class RangeCalendarViewController: ViewController {
    enum CalendarType {
        case common
        case appointment

        var title: String {
            switch self {
                case .common:
                    return NSLocalizedString("common_range_calendar_title", comment: "")
                case .appointment:
                    return NSLocalizedString("clinic_appointment_calendar_text", comment: "")
            }
        }
    }

    @IBOutlet private var saveButton: RoundEdgeButton!
    @IBOutlet private var buttonBackView: UIView!

    struct Input {
        let inputPickedRange: DateRange?
        let isSingleDatePickerMode: Bool
        let startingDate: Date
        let enabledInterval: DateInterval
        let calendarInterval: DateInterval
        let pickedRangeLengthMin: UInt
        let pickedRangeLengthMax: UInt
        let theme: CalendarTheme
        let calendarType: CalendarType?
        init(
            inputPickedRange: DateRange?,
            isSingleDatePickerMode: Bool = false,
            startingDate: Date,
            enabledInterval: DateInterval? = nil,
            calendarInterval: DateInterval?,
            pickedRangeLengthMin: UInt,
            pickedRangeLengthMax: UInt?,
            theme: CalendarTheme,
            calendarType: CalendarType? = nil
        ) {
            if let inputPickedRange = inputPickedRange {
                self.inputPickedRange = DateRange(startDate: inputPickedRange.startDate.utcStartOfDay,
                                                  finishDate: inputPickedRange.finishDate?.utcStartOfDay)
            } else {
                self.inputPickedRange = nil
            }
            self.startingDate = startingDate
            if let calendarInterval = calendarInterval {
                self.calendarInterval = calendarInterval
            } else {
                let calendarFinishDate = CalendarDate(startingDate).dateByAdding(years: 3, months: 0)
                self.calendarInterval = DateInterval(start: startingDate, end: calendarFinishDate?.date ?? startingDate)
            }
            if let enabledInterval = enabledInterval {
                self.enabledInterval = enabledInterval
            } else {
                self.enabledInterval = self.calendarInterval
            }
            self.pickedRangeLengthMin = max(pickedRangeLengthMin, 1)
            self.pickedRangeLengthMax = max(pickedRangeLengthMin, pickedRangeLengthMax ?? UInt.max)
            self.theme = theme
            self.calendarType = calendarType
            self.isSingleDatePickerMode = isSingleDatePickerMode
        }
    }

    struct Output {
        let selectedRange: (DateRange) -> Void
    }
    var input: Input!
    var output: Output!
    private var style: CalendarStyle {
        CalendarStyle(theme: input.theme)
    }
    private lazy var calendarView: RangeCalendarView = {
        let calendarInput = RangeCalendarView.Input(
            inputPickedRange: input.inputPickedRange,
            startingDate: CalendarDate(input.startingDate),
            enabledInterval: input.enabledInterval,
            calendarInterval: input.calendarInterval,
            pickedRangeLengthMin: input.pickedRangeLengthMin,
            pickedRangeLengthMax: input.pickedRangeLengthMax,
            theme: input.theme
        )
        let view = RangeCalendarView(
            input: calendarInput,
            output: RangeCalendarView.Output { [weak self] range in
                self?.rangeUpdated(range: range)
            }
        )
        return view
    }()
    private var pickedRange: DateRange?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = input.calendarType?.title
        ?? NSLocalizedString("common_range_calendar_title", comment: "")
        navigationController?.navigationBar.isTranslucent = false
		view.backgroundColor = .Background.backgroundContent
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: calendarView,
                in: view
            )
        )
        view.bringSubviewToFront(buttonBackView)
		saveButton <~ Style.RoundedButton.redBackground
		saveButton.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        rangeUpdated(range: pickedRange)
    }

    private func rangeUpdated(range: DateRange?) {
        if let range = range {
            pickedRange = range
        } else {
            pickedRange = nil
        }
        if range?.finishDate != nil {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }

        if input.isSingleDatePickerMode {
            let lengthMin = input.pickedRangeLengthMin == 1 ? 0 : Int(input.pickedRangeLengthMin)
            let lengthMax = input.pickedRangeLengthMax == UInt.max ? Int.max : Int(input.pickedRangeLengthMax)
            guard let range = range,
                  let dateByAddingLengthMin = range.startDate.dateByAdding(days: lengthMin),
                  let dateByAddingLengthMax = range.startDate.dateByAdding(days: lengthMax),
                  let finishDate = range.finishDate
            else { return }

            let isDateInRange = (dateByAddingLengthMin <= finishDate)
            && (dateByAddingLengthMax >= finishDate)

            saveButton.isEnabled = isDateInRange
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        calendarView.collectionView.collectionViewLayout.invalidateLayout()
    }

    @IBAction private func saveButtonTap(_ sender: UIButton) {
        if let pickedRange = pickedRange {
            output.selectedRange(pickedRange)
        }
    }
}
