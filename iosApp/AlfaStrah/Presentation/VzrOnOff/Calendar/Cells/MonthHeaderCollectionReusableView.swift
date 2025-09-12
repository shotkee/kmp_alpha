//
//  MonthHeaderCollectionReusableView.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 23.10.2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

class MonthHeaderCollectionReusableView: UICollectionReusableView {
    struct Input {
        let date: CalendarDate
        let theme: CalendarTheme
    }

    var input: Input! {
        didSet {
            refreshState()
            applyStyle()
        }
    }

    private var style: CalendarStyle {
        CalendarStyle(theme: input.theme)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            monthLabel.rightAnchor.constraint(equalTo: rightAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func applyStyle() {
        backgroundColor = style.monthBackgroundColor
        monthLabel.backgroundColor = .clear
        monthLabel.font = style.dateMonthFont
        monthLabel.textColor = style.dateMonthColor
    }

    private func refreshState() {
        let monthString = MonthHeaderCollectionReusableView.dateFormatter.string(from: input.date.utcStartOfDay.date).capitalized
        monthLabel.text = String(format: NSLocalizedString("common_with_year_sign", comment: ""), "\(monthString)")
    }

    private static let dateFormatter: DateFormatter = {
        guard let timeZone = TimeZone(abbreviation: "UTC") else {
            fatalError("Incorrect TimeZone!")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.timeZone = timeZone
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        return label
    }()
}
