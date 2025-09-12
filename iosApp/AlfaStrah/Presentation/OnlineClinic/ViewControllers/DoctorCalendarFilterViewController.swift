//
//  DoctorCalendarFilterViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17.09.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class DoctorCalendarFilterViewController: ViewController,
                                          UITableViewDelegate,
                                          UITableViewDataSource,
                                          UIScrollViewDelegate {
    private let chooseButton = RoundEdgeButton()
    private let weekdayStackView = UIStackView()
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    private let actionButtonsStackView = UIStackView()
    
    private var monthIndexes: [Int] = []
    private var previousSelectedMonthIndex = 0
    
    private lazy var selectedDate: Date = {
        let now = Date()
        
        let startOfDayForDate = AppLocale.calendar.date(
            from: AppLocale.calendar.dateComponents([.year, .month, .day], from: AppLocale.calendar.startOfDay(for: now))
        ) ?? now
        
        return startOfDayForDate
    }()

    struct Input {
        let selectedDate: Date
        let startDate: Date
        let endDate: Date
    }

    struct Output {
        let selectedDate: (_ date: Date) -> Void
    }

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToMonth(with: previousSelectedMonthIndex)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupBottomInsetIfNeeded()
    }

    private func setupBottomInsetIfNeeded() {
        let bottomInset = actionButtonsStackView.bounds.height
        
        if tableView.contentInset.bottom != bottomInset {
            tableView.contentInset.bottom = bottomInset
        }
    }

    private func setupUI() {
        title = NSLocalizedString("doctor_calendar_filter_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
        
        setupWeekDaysStackView()
        setupTableView()
        
        setupActionButtonsStackView()
        setupChooseButton()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.registerReusableCell(DoctorScheduleFilterCalendarTableViewCell.id)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.backgroundColor = .clear
        
        fillTableViewWithData()
    }
        
    private func setupActionButtonsStackView() {
        view.addSubview(actionButtonsStackView)

        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 18, right: 18)
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = 0
        actionButtonsStackView.backgroundColor = .clear

        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupWeekDaysStackView() {
        weekdayStackView.axis = .horizontal
        weekdayStackView.distribution = .fillEqually
        weekdayStackView.alignment = .center
        weekdayStackView.isLayoutMarginsRelativeArrangement = true
        weekdayStackView.layoutMargins = UIEdgeInsets(top: 18, left: 31, bottom: 18, right: 31)
        weekdayStackView.spacing = 30
		weekdayStackView.backgroundColor = .Background.backgroundContent
        
        let weekdaysCount = AppLocale.calendar.weekdaySymbols.count
        
        for index in 0..<weekdaysCount {
            var dayOfWeek = index + AppLocale.calendar.firstWeekday
            if dayOfWeek > weekdaysCount {
                dayOfWeek -= weekdaysCount
            }
            
            let weekDayLabel = UILabel()
            weekDayLabel <~ Style.Label.secondaryText
            weekDayLabel.textAlignment = .center
            weekDayLabel.text = AppLocale.calendar.shortWeekdaySymbols[dayOfWeek - 1].capitalizingFirstLetter()
            weekdayStackView.addArrangedSubview(weekDayLabel)
        }

        view.addSubview(weekdayStackView)
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomBorderView = UIView()
		bottomBorderView.backgroundColor = .Icons.iconTertiary
        
        weekdayStackView.addSubview(bottomBorderView)
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            weekdayStackView.topAnchor.constraint(equalTo: view.topAnchor),
            weekdayStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekdayStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBorderView.bottomAnchor.constraint(equalTo: weekdayStackView.bottomAnchor),
            bottomBorderView.leadingAnchor.constraint(equalTo: weekdayStackView.leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: weekdayStackView.trailingAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupChooseButton() {
        chooseButton <~ Style.RoundedButton.oldPrimaryButtonSmall

        chooseButton.setTitle(
            NSLocalizedString("common_choose_button", comment: ""),
            for: .normal
        )
        
        chooseButton.addTarget(self, action: #selector(chooseButtonTap), for: .touchUpInside)
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chooseButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        actionButtonsStackView.addArrangedSubview(chooseButton)
    }
    
    @objc func chooseButtonTap() {
        output.selectedDate(self.selectedDate)
    }
    
    private func fillTableViewWithData() {
        var monthsIndexes: [Int] = []
        
        for counter in 0...monthsCount(from: input.startDate, to: input.endDate) {
            monthsIndexes.append(counter)
            
            if !isDateBetween(
                input.selectedDate,
                from: input.startDate,
                to: AppLocale.calendar.date(byAdding: .month, value: counter, to: input.startDate) ?? input.startDate
            ) {
                self.previousSelectedMonthIndex = counter
            }
        }

        self.monthIndexes = monthsIndexes
        
        self.selectedDate = isDateBetween(input.selectedDate, from: input.startDate, to: input.endDate)
            ? input.selectedDate
            : input.startDate
        
        tableView.reloadData()
    }
    
    private func scrollToMonth(with index: Int) {
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
    }
    
    private func monthsCount(from: Date, to: Date) -> Int {
        return AppLocale.calendar.dateComponents([.month], from: from, to: to).month ?? 1
    }
    
    private func isDateBetween(_ date: Date, from: Date, to: Date) -> Bool {
        return (min(from, to) ... max(from, to)) ~= date
    }
        
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let monthIndex = monthIndexes[safe: indexPath.row]
        else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(DoctorScheduleFilterCalendarTableViewCell.id)
        
        cell.configure(with: monthIndex) { [weak self] selectedDate in
            guard let self = self
            else { return }

            self.selectedDate = selectedDate
            
            if self.previousSelectedMonthIndex != monthIndex {
                let previousSelectedIndexPath = IndexPath(row: self.previousSelectedMonthIndex, section: 0)

                if let previousSelectedCell = tableView.cellForRow(
                    at: previousSelectedIndexPath
                ) as? DoctorScheduleFilterCalendarTableViewCell {
                    previousSelectedCell.resetSelection()
                }
                self.previousSelectedMonthIndex = monthIndex
            }
        }
        
        cell.select(date: selectedDate)
                        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthIndexes.count
    }
}
