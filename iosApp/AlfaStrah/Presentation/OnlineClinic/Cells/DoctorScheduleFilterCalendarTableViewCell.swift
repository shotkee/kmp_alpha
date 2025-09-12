//
//  DoctorScheduleFilterCalendarTableVIewCell.swift
//  AlfaStrah
//
//  Created by vit on 25.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DoctorScheduleFilterCalendarTableViewCell: UITableViewCell {
    static let id: Reusable<DoctorScheduleFilterCalendarTableViewCell> = .fromClass()
    
    private let calendarView = VerticalCalendarView()
    private let monthLabel = UILabel()
    private let containerView = UIView()
    
    private var onSelect: (() -> Void)?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
        
    private func setupUI() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        selectionStyle = .none
        
        setupContainerView()
        setupMonthLabel()
        setupCalendarView()
    }
    
    private func setupContainerView() {
		containerView.backgroundColor = .Background.backgroundContent
        
        contentView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: containerView,
                in: contentView,
                margins: UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
            )
        )
    }
    
    private func setupMonthLabel() {
        containerView.addSubview(monthLabel)
        monthLabel <~ Style.Label.primaryHeadline1
        monthLabel.numberOfLines = 0
                
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            monthLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            monthLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    private func setupCalendarView() {
        containerView.addSubview(calendarView)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 18),
            calendarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
        
    func configure(with monthIndex: Int, _ completion: @escaping (Date) -> Void) {
        if let date = AppLocale.calendar.date(byAdding: .month, value: monthIndex, to: Date()) {
            monthLabel.text = "\(dateFormatter.string(from: date).capitalized) \(NSLocalizedString("common_year_suffix", comment: ""))"
        }
        
        calendarView.set(with: monthIndex)
        
        calendarView.onSelect = completion
    }
    
    func resetSelection() {
        calendarView.resetSelection()
    }
    
    func select(date: Date) {
        calendarView.select(date: date)
    }
}
