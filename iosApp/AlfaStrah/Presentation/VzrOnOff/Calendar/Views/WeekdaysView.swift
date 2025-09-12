//
//  CalendarWeekdayView.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 23.10.2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

class WeekdaysView: UIView {
    private var style = CalendarStyle()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(style: CalendarStyle) {
        self.init()
        self.style = style
        setupViews()
    }

    private func setupViews() {
        addSubview(daysStackView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: daysStackView,
                in: self,
                margins: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
            )
        )
		backgroundColor = .Background.backgroundSecondary

        for day in 0 ..< 7 {
            let calendar = AppLocale.utcCalendar
            let label = UILabel()
            if calendar.shortStandaloneWeekdaySymbols.count == 7 {
                label.text = calendar.shortStandaloneWeekdaySymbols[(day + calendar.firstWeekday - 1) % 7].uppercased()
            }
            label.textAlignment = .center
            label.textColor = style.dateWeekColor
            label.font = style.dateWeekFont
            daysStackView.addArrangedSubview(label)
        }

        let separator = HairLineView()
        addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leftAnchor.constraint(equalTo: leftAnchor),
            separator.rightAnchor.constraint(equalTo: rightAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private let daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
