//
//  CalendarTheme.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 23.10.2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

struct CalendarStyle {
    let backgroundColor: UIColor
    let titleFont: UIFont
    let titleColor: UIColor
    let dateDayFont: UIFont
    let dateDayColor: UIColor
    let dateDayDisabledColor: UIColor
    let dateDaySelectedColor: UIColor
    let dateDayInRangeColor: UIColor
    let selectIndicatorColor: UIColor
    let rangeColor: UIColor
    let dateWeekFont: UIFont
    let dateWeekColor: UIColor
    let dateMonthFont: UIFont
    let dateMonthColor: UIColor
    let monthBackgroundColor: UIColor
    let currentDateColor: UIColor

    init(theme: CalendarTheme = .themeDefault) {
        switch theme {
            case .themeDefault:
				backgroundColor = .Background.backgroundSecondary
				titleFont = Style.Font.headline1
				titleColor = .Text.textPrimary
				dateDayFont = Style.Font.text
				dateDayColor = .Text.textPrimary
				dateDayDisabledColor = .Text.textSecondary
				dateDaySelectedColor = .Background.backgroundContent
				dateDayInRangeColor = .Text.textPrimary
				selectIndicatorColor = .Text.textAccent
				rangeColor = .Background.backgroundSecondary
				dateWeekFont = Style.Font.text
				dateWeekColor = .Text.textSecondary
				dateMonthFont = Style.Font.headline1
				dateMonthColor = .Text.textPrimary
				monthBackgroundColor = .Background.backgroundContent
				currentDateColor = .Text.textAccent
        }
    }
}
