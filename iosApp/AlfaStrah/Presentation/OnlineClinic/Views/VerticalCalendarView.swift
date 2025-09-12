//
//  VerticalCalendarView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17.09.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class VerticalCalendarView: UIView {
    private let calendar = AppLocale.calendar
    
    var onSelect: ((Date) -> Void)?
    
    private let calendarStackView = UIStackView()
 
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    private var dayButtons: [CalendarDayButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupCalendarStackView()
    }
    
    private func setupCalendarStackView() {
        addSubview(calendarStackView)
        calendarStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: calendarStackView, in: self))

        calendarStackView.isLayoutMarginsRelativeArrangement = true
        calendarStackView.layoutMargins = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 31)
        calendarStackView.axis = .vertical
        calendarStackView.distribution = .fill
        calendarStackView.alignment = .fill
        calendarStackView.spacing = 12
    }
    
    func set(with monthIndex: Int) {
        guard let monthDate = calendar.date(byAdding: .month, value: monthIndex, to: Date())
        else { return }
                
        update(with: monthDate)
    }

    private func update(with monthDate: Date) {
        let now = Date()
        let activeDaysCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 1
        let weekdaysCount = dateFormatter.weekdaySymbols.count
        let firstWeekDay = calendar.firstWeekday
        let startActiveDate = calendar.date(
            from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: monthDate))
        ) ?? now
        
        let endActiveDate = calendar.date(byAdding: .day, value: activeDaysCount - 1, to: startActiveDate) ?? now
        
        let startDateDayOfWeek =
            (calendar.component(.weekday, from: startActiveDate) + weekdaysCount - firstWeekDay) % weekdaysCount + 1
        
        let endDateDayOfWeek =
            (calendar.component(.weekday, from: endActiveDate) + weekdaysCount - firstWeekDay) % weekdaysCount + 1
        
        let daysCount = activeDaysCount + (startDateDayOfWeek - 1) + (7 - endDateDayOfWeek)
        
        guard daysCount != 0
        else { return }
        
        let currentMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: now))
        ) ?? now
            
        let isCurrentMonth = startActiveDate == currentMonth
        
        let rows = Int(daysCount / 7)
        
        calendarStackView.subviews.forEach { $0.removeFromSuperview() }
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: calendarStackView, in: self))
        
        var dates: [Date] = []
        dayButtons = []
        for day in 1...daysCount {
            var dateComponents = DateComponents()
            dateComponents.day = day - startDateDayOfWeek
            calendar.date(byAdding: dateComponents, to: startActiveDate).map { dates.append($0) }
        }

        let chunckedDates = stride(from: 0, to: daysCount, by: weekdaysCount).map {
            Array(dates[$0 ..< min($0 + weekdaysCount, daysCount)])
        }
        
        chunckedDates.forEach {
            addDates(
                $0,
                startDateDayOfWeek: startDateDayOfWeek,
                activeDaysCount: activeDaysCount,
                isCurrentMonth: isCurrentMonth
            )
        }
    }
    
    private func addDates(
        _ dates: [Date],
        startDateDayOfWeek: Int,
        activeDaysCount: Int,
        isCurrentMonth: Bool
    ) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center

        let now = Date()
        
        let today = calendar.date(
            from: calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: now))
        ) ?? now
        
        for date in dates {
            let dayButton = CalendarDayButton(type: .custom)
            dayButton.date = date
            dayButton.tag = dayButtons.count
            dayButtons.append(dayButton)
            
            let activeDay = dayButtons.count >= startDateDayOfWeek && dayButtons.count < startDateDayOfWeek + activeDaysCount
            
            dayButton.isEnabled = activeDay
            dayButton.alpha = activeDay ? 1 : 0

			dayButton <~ Style.Button.CalendarDayButton(title: dateFormatter.string(from: date))
            
            if isCurrentMonth,
               dayButton.date < today {
                dayButton.setTitleColor(Style.Color.Palette.lightGray, for: .normal)
                dayButton.isEnabled = false
            }
            
            if dayButton.date == today {
                dayButton.setTitleColor(Style.Color.main, for: .normal)
            }
        
            dayButton.addTarget(
                self,
                action: #selector(dayButtonTap(sender:)),
                for: .touchUpInside
            )
            
            stackView.addArrangedSubview(dayButton)
        }
        calendarStackView.addArrangedSubview(stackView)
    }

    @objc private func dayButtonTap(sender: CalendarDayButton) {
        resetSelection()
        
        let selectedIndex = sender.tag
        
        if let dayButton = dayButtons[safe: selectedIndex] {
            dayButton.selectionStyle = .circle
            onSelect?(dayButton.date)
        }
    }
    
    func resetSelection() {
        for dayButton in dayButtons {
            dayButton.selectionStyle = .none
        }
    }
    
    func select(date: Date) {
        if let startOfDayForDate = calendar.date(
            from: calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: date))
        ) {
            if let dayButton = dayButtons.first(where: {
                $0.date == startOfDayForDate
            }) {
                dayButton.selectionStyle = .circle
            }
        }
    }
}
