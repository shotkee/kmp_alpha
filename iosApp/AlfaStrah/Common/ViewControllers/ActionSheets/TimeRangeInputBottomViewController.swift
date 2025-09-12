//
//  TimeRangeInputBottomViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 12.10.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class TimeRangeInputBottomViewController: BaseBottomSheetViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    struct Input {
        let title: String
        let minHour: Int
        let maxHour: Int
        let defaultStartHour: Int
        let defaultEndHour: Int
    }

    struct Output {
        let close: () -> Void
        let selectTime: ((Int, Int)) -> Void
    }

    var input: Input!
    var output: Output!

    var rangeLen: Int {
        input.maxHour - input.minHour + 1
    }

    private lazy var rangePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            let startRow = rangePicker.selectedRow(inComponent: 0)
            let endRow = rangePicker.selectedRow(inComponent: 2)
            let startHour = input.minHour + startRow
            let endHour = input.minHour + endRow
            self.output.selectTime((startHour, endHour))
        }
    }

    override func setupUI() {
        super.setupUI()

        guard input.defaultStartHour >= input.minHour, input.defaultEndHour <= input.maxHour,
              input.maxHour >= input.minHour
        else {
            return
        }

        rangePicker.selectRow(input.defaultStartHour - input.minHour, inComponent: 0, animated: false)
        rangePicker.selectRow(input.defaultEndHour - input.minHour, inComponent: 2, animated: false)
        set(title: input.title)
        set(doneButtonEnabled: input.defaultStartHour < input.defaultEndHour)
        set(views: [ rangePicker ])
    }

    // MARK: UIPicker delegate & data source

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumIntegerDigits = 2
        formatter.minimumIntegerDigits = 2
        return formatter
    }()

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
            case 0, 2:
                return rangeLen
            case 1:
                return 1
            default:
                return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel <~ Style.Label.primaryHeadline2
        guard let hours = formatter.string(from: NSNumber(value: input.minHour + row)) else { return UIView() }
        switch component {
            case 0:
                pickerLabel.text = "\(hours):00"
                pickerLabel.textAlignment = .right
            case 1:
                pickerLabel.text = "—"
                pickerLabel.textAlignment = .center
            case 2:
                pickerLabel.text = "\(hours):00"
                pickerLabel.textAlignment = .left
            default:
                break
        }

        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        32
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let centerWidth: CGFloat = 24
        switch component {
            case 0, 2:
                return pickerView.frame.width / 3
            case 1:
                return centerWidth
            default:
                return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let begin = pickerView.selectedRow(inComponent: 0)
        let end = pickerView.selectedRow(inComponent: 2)
        set(doneButtonEnabled: begin < end)
    }

}
