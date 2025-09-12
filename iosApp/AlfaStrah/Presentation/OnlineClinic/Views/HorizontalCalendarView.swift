//
//  HorizontalCalendarView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19.09.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class HorizontalCalendarView: UIView, UIScrollViewDelegate {
    private var activeDate = Date()
    private var availableDates: [Date] = []
    private var startDate = Date()
    private var daysCount = 14
    private let calendar = AppLocale.calendar
    private var selectedDayIndex = 0
    private var dayButtons: [CalendarDayButton] = []
        
    private let calendarButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private var showCalendarButton = true
    
    var openCalendar: (() -> Void)?
    var activeDateCallback: ((_ selectedDate: Date, _ startDate: Date) -> Void)?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func set(
        activeDate: Date,
        availableDates: [Date],
        showCalendarButton: Bool = true
    ) {
        self.activeDate = activeDate
        self.startDate = activeDate
        self.availableDates = availableDates

        self.showCalendarButton = showCalendarButton
        
        setupDates()
    }
        
    func set(
        activeDate: Date,
        showCalendarButton: Bool = true
    ) {
        self.activeDate = activeDate
        startDate = self.activeDate
        self.availableDates = []
        
        self.showCalendarButton = showCalendarButton
        
        setupDates()
    }
    
    func set(
        activeDate: Date,
        startDate: Date,
        showCalendarButton: Bool = true
    ) {
        self.activeDate = activeDate
        self.startDate = startDate
        self.availableDates = []

        self.showCalendarButton = showCalendarButton
        
        setupDates()
    }
    
    private func setupDates() {
        dayButtons = []
        selectedDayIndex = 0
        
        for index in 0...daysCount {
            availableDates.append(Calendar.current.date(byAdding: .day, value: index, to: startDate) ?? Date())
        }
        
        update()
        updateButtonsAppearance()
        
        scrollView.setContentOffset(.zero, animated: false)
        
        calendarButton.isHidden = !showCalendarButton
    }
    
    func updateInCurrentInterval(selectedDate: Date) {
        if let selectedDayInDayButton = dayButtons.first(where: {
            $0.date == selectedDate
        }) {
            selectedDayIndex = selectedDayInDayButton.tag
            updateSelectedDay()
        }
    }
    
    private func setup() {
        scrollView.backgroundColor = .clear
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: self))

        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
        ])

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 21, right: 18)
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = Constatns.dayButtonsSpacing

        update()
        updateButtonsAppearance()
        setupCalendarButton()
    }
    
    private func setupCalendarButton() {
        calendarButton.backgroundColor = .Background.backgroundSecondary
        calendarButton.tintColor = .Icons.iconPrimary
        calendarButton.layer.borderColor = UIColor.Stroke.strokeBorder.cgColor
        calendarButton.layer.borderWidth = 1
        calendarButton.layer.cornerRadius = 21
        calendarButton.setTitle("", for: .normal)
        calendarButton.addTarget(self, action: #selector(openCalendarTap), for: .touchUpInside)
        calendarButton.setImage(.Icons.arrow.tintedImage(withColor: .Icons.iconPrimary), for: .normal)
    }
    
    @objc func openCalendarTap() {
        openCalendar?()
    }

    private func scrollToActiveDate() {
        scrollView.layoutIfNeeded()

        if let button = dayButtons[safe: selectedDayIndex] { // fix crash index out off range
            let rect = button.convert(button.bounds, to: scrollView)
            let xCenter = min(scrollView.contentSize.width - scrollView.frame.width, max(0, (rect.midX - scrollView.frame.width / 2)))
            scrollView.setContentOffset(CGPoint(x: xCenter, y: scrollView.contentOffset.y), animated: true)
        }
    }

    private func update() {
        stackView.subviews.forEach { $0.removeFromSuperview() }

        var dates: [Date] = []
        for day in 0 ..< daysCount {
            calendar.date(byAdding: .day, value: day, to: startDate).map { dates.append($0) }
        }

        selectedDayIndex = dates.firstIndex { calendar.compare($0, to: activeDate, toGranularity: .day) == .orderedSame } ?? 0
        let activeDays: Set<Int> = Set(availableDates.map { calendar.component(.day, from: $0) })

        dayButtons = []
        for date in dates {
            let activeDay = activeDays.contains(calendar.component(.day, from: date))
            let weekday = calendar.component(.weekday, from: date)
            
            let weekDayLabel = UILabel()
            weekDayLabel.font = Style.Font.text
            weekDayLabel.textColor = .Text.textSecondary
            weekDayLabel.isUserInteractionEnabled = activeDay
            weekDayLabel.tag = dayButtons.count
            weekDayLabel.textAlignment = .center
            weekDayLabel.text = dateFormatter.shortWeekdaySymbols[weekday - 1].capitalizingFirstLetter()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(weekdayTap(sender:)))
            weekDayLabel.addGestureRecognizer(tapGesture)

            let dayButton = CalendarDayButton(type: .custom)
            dayButton.date = date
            dayButton.tag = dayButtons.count
            dayButtons.append(dayButton)
            dayButton.isEnabled = activeDay
            dayButton <~ Style.Button.CalendarDayButton(title: dateFormatter.string(from: date))
            dayButton.addTarget(self, action: #selector(dayButtonTap(sender:)), for: .touchUpInside)
            
            let subLabel = UILabel()
            subLabel <~ Style.Label.secondaryCaption1
            subLabel.textAlignment = .center
            subLabel.adjustsFontSizeToFitWidth = true
        
            if AppLocale.calendar.isDateInToday(date) {
                subLabel.text = NSLocalizedString("clinic_day_today", comment: "")
            } else if let dayPositionInMonth = AppLocale.calendar.dateComponents([.day], from: date).day,
                      dayPositionInMonth == 1 {
                subLabel.text = AppLocale.monthName(from: date).capitalizingFirstLetter()
            }
            
            let containerView = UIView()
            containerView.clipsToBounds = false
            containerView.layer.masksToBounds = false
            
            containerView.addSubview(weekDayLabel)
            containerView.addSubview(dayButton)
            containerView.addSubview(subLabel)
            
            weekDayLabel.translatesAutoresizingMaskIntoConstraints = false
            dayButton.translatesAutoresizingMaskIntoConstraints = false
            subLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                weekDayLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
                weekDayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                weekDayLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                weekDayLabel.heightAnchor.constraint(equalToConstant: 33),
                weekDayLabel.widthAnchor.constraint(equalTo: dayButton.heightAnchor),
                dayButton.topAnchor.constraint(equalTo: weekDayLabel.bottomAnchor, constant: 4),
                dayButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                dayButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                dayButton.heightAnchor.constraint(equalToConstant: 42),
                dayButton.widthAnchor.constraint(equalTo: dayButton.heightAnchor),
                subLabel.topAnchor.constraint(equalTo: dayButton.bottomAnchor, constant: 6),
                subLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                subLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                subLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            stackView.addArrangedSubview(containerView)
        }
        
        let containerView = UIView()
        containerView.addSubview(calendarButton)
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            calendarButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 37),
            calendarButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            calendarButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            calendarButton.heightAnchor.constraint(equalToConstant: 42),
            calendarButton.widthAnchor.constraint(equalTo: calendarButton.heightAnchor)
        ])
        
        stackView.addArrangedSubview(containerView)
    }
    
    @objc private func weekdayTap(sender: UITapGestureRecognizer) {
        guard let view = sender.view
        else { return }

        selectedDayIndex = view.tag
        
        handleTap()
    }

    @objc private func dayButtonTap(sender: CalendarDayButton) {
        selectedDayIndex = sender.tag
        
        handleTap()
    }
    
    private func handleTap() {
        updateButtonsAppearance()
        scrollToActiveDate()
        activeDateCallback?(dayButtons[selectedDayIndex].date, startDate)
    }
    
    private func updateSelectedDay() {
        updateButtonsAppearance()
        scrollToActiveDate()
    }

    private func updateButtonsAppearance() {
        for (index, dayButton) in dayButtons.enumerated() {
            if index == selectedDayIndex {
                dayButton.selectionStyle = .circle
            } else {
                dayButton.selectionStyle = dayButtons[index].date.in(region: .current).isInWeekend
                    ? .weekend
                    : .available
            }
        }
    }
    
    func selectNextDay() {
        if selectedDayIndex == dayButtons.count - 1 {
            selectedDayIndex = 1
        } else {
            selectedDayIndex += 1
        }
        
        updateSelectedDay()
    }
    
    struct Constatns {
        static let dayButtonsSpacing: CGFloat = 9
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        calendarButton.setImage(.Icons.arrow.tintedImage(withColor: .Icons.iconPrimary), for: .normal)
        calendarButton.layer.borderColor = UIColor.Stroke.strokeBorder.cgColor
    }
}
