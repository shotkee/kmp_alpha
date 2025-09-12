//
//  DayCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 23.10.2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

class DayCollectionViewCell: UICollectionViewCell {
    private enum InMonthPosition {
        case ownMonth
        case foreignMonth
    }

    private enum InRangeState {
        case notInRange
        case selectedAlone
        case selectedAsStart
        case selectedAsEnd
        case inRange
    }

    struct Input {
        let pickedRange: () -> DateRange?
        let monthComponents: DateComponents
        let date: CalendarDate
        let enabledInterval: DateInterval
        let calendarInterval: DateInterval
        let pickedRangeLengthMin: UInt
        let pickedRangeLengthMax: UInt
        let theme: CalendarTheme
    }

    var input: Input!

    private var style: CalendarStyle {
        CalendarStyle(theme: input.theme)
    }

    private var pickedRange: DateRange?
    private var inRangeState: InRangeState = .notInRange
    private var inMonthPosition: InMonthPosition = .ownMonth
    
    var leftRounded = false
    var rightRounded = false
    var isInRangeLimits = true
    private var roundLayoutDone = false
    private var isEnabled = true

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.isOpaque = true
        backgroundView?.isOpaque = true
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !roundLayoutDone {
            roundLayoutDone = true
            cornerLineIndicator()
        }
    }

    func update(isInitial: Bool) {
        pickedRange = input.pickedRange()
        if isInitial {
            refreshInRangeState()
            refreshInMonthState()
            refreshDate()
            applyStates()
        } else {
            refreshDate()
            refreshInRangeState()
            applyStates()
        }
    }

    private func cornerLineIndicator() {
        if leftRounded && rightRounded {
            lineIndicatorView.roundCorners(side: .all, radius: 18)
        } else if leftRounded {
            lineIndicatorView.roundCorners(side: .left, radius: 18)
        } else if rightRounded {
            lineIndicatorView.roundCorners(side: .right, radius: 18)
        }
    }

    private func setupViews() {
        addSubview(lineIndicatorView)
        lineIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineIndicatorView.leftAnchor.constraint(equalTo: leftAnchor),
            lineIndicatorView.rightAnchor.constraint(equalTo: rightAnchor),
            lineIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lineIndicatorView.heightAnchor.constraint(equalToConstant: 36)
        ])
        addSubview(circleIndicatorView)
        circleIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: circleIndicatorView,
                in: self
            )
        )
        addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: dateLabel,
                in: self
            )
        )
    }

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label
    }()

    private let circleIndicatorView = CircleIndicatorView()

    private let lineIndicatorView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.isOpaque = true
        return view
    }()

    private func refreshInRangeState() {
        if let pickedRange = pickedRange {
            if pickedRange.startDate == input.date {
                if pickedRange.finishDate == nil || pickedRange.startDate == pickedRange.finishDate {
                    inRangeState = .selectedAlone
                } else {
                    inRangeState = .selectedAsStart
                }
            } else if pickedRange.finishDate == input.date {
                inRangeState = .selectedAsEnd
            } else if let finishDate = pickedRange.finishDate {
                if (pickedRange.startDate ... finishDate).contains(input.date) {
                    inRangeState = .inRange
                } else {
                    inRangeState = .notInRange
                }
            } else {
                inRangeState = .notInRange
            }
        } else {
            inRangeState = .notInRange
        }
    }

    private func refreshInMonthState() {
        let calendar = AppLocale.utcCalendar
        let yearComponent = calendar.component(.year, from: input.date.date)
        let monthComponent = calendar.component(.month, from: input.date.date)
        if input.monthComponents.year == yearComponent && input.monthComponents.month == monthComponent {
            inMonthPosition = .ownMonth
        } else {
            inMonthPosition = .foreignMonth
        }
    }

    private func applyStates() {
        switch inRangeState {
            case .notInRange:
                lineIndicatorView.isHidden = true
                circleIndicatorView.isHidden = true
            case .inRange:
                lineIndicatorView.isHidden = false
                circleIndicatorView.isHidden = true
            case .selectedAsStart:
                lineIndicatorView.isHidden = true
                circleIndicatorView.isHidden = false
                if rightRounded {
                    circleIndicatorView.state = .alone
                } else {
                    circleIndicatorView.state = .leftEnd
                }
            case .selectedAsEnd:
                lineIndicatorView.isHidden = true
                circleIndicatorView.isHidden = false
                if leftRounded {
                    circleIndicatorView.state = .alone
                } else {
                    circleIndicatorView.state = .rightEnd
                }
            case .selectedAlone:
                lineIndicatorView.isHidden = true
                circleIndicatorView.isHidden = false
                circleIndicatorView.state = .alone
        }

        switch inMonthPosition {
            case .foreignMonth:
                isHidden = true
            case .ownMonth:
                isHidden = false
        }
        applyStyle()
    }

    private func refreshDate() {
        dateLabel.text = "\(AppLocale.utcCalendar.component(.day, from: input.date.date))"
        if let startDate = pickedRange?.startDate, pickedRange?.finishDate == nil, startDate != input.date,
            input.date.inRangeOf(days: input.pickedRangeLengthMin - 2, around: startDate.date) {
            isInRangeLimits = false
        } else {
            isInRangeLimits = true
        }
        isEnabled = input.enabledInterval.contains(input.date.utcEndOfDay.date)
                        && input.calendarInterval.contains(input.date.utcEndOfDay.date)
                        && isInRangeLimits
    }

    private func applyStyle() {
        if isEnabled {
            if inRangeState == .selectedAsStart || inRangeState == .selectedAsEnd || inRangeState == .selectedAlone {
                dateLabel.textColor = style.dateDaySelectedColor
            } else if inRangeState == .inRange {
                dateLabel.textColor = style.dateDayInRangeColor
            } else {
                dateLabel.textColor = style.dateDayColor
            }
        } else {
            dateLabel.textColor = style.dateDayDisabledColor
        }

        if AppLocale.calendar.isDateInToday(input.date.date) && (inRangeState == .inRange || inRangeState == .notInRange) {
            dateLabel.textColor = style.currentDateColor
        }
        circleIndicatorView.circleView.backgroundColor = style.selectIndicatorColor
        circleIndicatorView.leftBackView.backgroundColor = style.rangeColor
        circleIndicatorView.rightBackView.backgroundColor = style.rangeColor
        lineIndicatorView.backgroundColor = style.rangeColor
    }
}
