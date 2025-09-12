//
//  RangeCalendarView.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 23.10.2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

class RangeCalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionViewCells: Set<UICollectionViewCell> = []
    var pickedRange: DateRange? {
        didSet {
            for cell in collectionViewCells {
                if let cell = cell as? DayCollectionViewCell {
                    cell.update(isInitial: false)
                }
            }
        }
    }

    struct Input {
        let inputPickedRange: DateRange?
        let startingDate: CalendarDate
        let enabledInterval: DateInterval
        let calendarInterval: DateInterval
        let pickedRangeLengthMin: UInt
        let pickedRangeLengthMax: UInt
        let theme: CalendarTheme
    }

    struct Output {
        let update: (DateRange?) -> Void
    }

    var input: Input!
    var output: Output!
    private var style: CalendarStyle {
        CalendarStyle(theme: input.theme)
    }
    var weekdaysView: WeekdaysView?
    let collectionInset: CGFloat = 18
    private var initialScrolled = false

    convenience init(input: Input, output: Output) {
        self.init()
        self.input = input
        self.output = output
        pickedRange = input.inputPickedRange
        weekdaysView = {
            let view = WeekdaysView(style: style)
            view.translatesAutoresizingMaskIntoConstraints = false
            weekdaysView?.backgroundColor = .white
            return view
        }()
        initializeView()
    }

    func pick(date: CalendarDate) {
        if let range = pickedRange {
            if range.finishDate == nil || range.startDate == range.finishDate {
                if range.startDate == date {
                    pickedRange = nil
                } else {
                    let startDate = input.pickedRangeLengthMax == 1 ? date : range.startDate
                    pickedRange = DateRange(startDate: startDate, finishDate: date)
                }
            } else {
                let finishDate = input.pickedRangeLengthMin == 1 ? date : nil
                pickedRange = DateRange(startDate: date, finishDate: finishDate)
            }
        } else {
            let finishDate = input.pickedRangeLengthMin == 1 ? date : nil
            pickedRange = DateRange(startDate: date, finishDate: finishDate)
        }
        output.update(pickedRange)
    }

    func initializeView() {
        setupViews()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Separating cells in different pools is needed for reuse corner radii of range views.
        collectionView.register(DayCollectionViewCell.self, forCellWithReuseIdentifier: "dayCell")
        collectionView.register(DayCollectionViewCell.self, forCellWithReuseIdentifier: "leftRoundedDayCell")
        collectionView.register(DayCollectionViewCell.self, forCellWithReuseIdentifier: "rightRoundedDayCell")
        collectionView.register(DayCollectionViewCell.self, forCellWithReuseIdentifier: "fullRoundedCell")
        collectionView.register(MonthHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "monthView")
        collectionView.contentInset = UIEdgeInsets(top: 54, left: 0, bottom: 95, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 54, left: 0, bottom: 95, right: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let startDate = input.inputPickedRange?.startDate, !initialScrolled {
            let calendar = AppLocale.utcCalendar
            let diffInMonthes = calendar.dateComponents([.month], from: CalendarDate(input.calendarInterval.start).utcStartOfMonth.date,
                to: startDate.utcEndOfMonth.date).month ?? 1
            collectionView.scrollToItem(at: IndexPath(item: 0, section: diffInMonthes), at: .top, animated: false)
            if let attributes = collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: diffInMonthes)) {
                let yOffset = attributes.frame.origin.y - collectionView.contentInset.top
                collectionView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
            }
        }
        initialScrolled = true
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let calendar = AppLocale.utcCalendar
        let diffInMonths = calendar.dateComponents([ .month ], from: CalendarDate(input.calendarInterval.start).utcStartOfMonth.date,
            to: CalendarDate(input.calendarInterval.end).utcEndOfMonth.date).month ?? 1
        return diffInMonths
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let calendar = AppLocale.utcCalendar
        let counterDate = calendar.utcStartOfDay(byAdding: DateComponents(month: section), to: input.calendarInterval.start)
        return CalendarDate(counterDate).calendarWeeksInMonth * 7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendar = AppLocale.utcCalendar
        let startDate = CalendarDate(input.calendarInterval.start).utcStartOfMonth
        let startMonthDate = CalendarDate(calendar.utcStartOfDay(byAdding: DateComponents(month: indexPath.section), to: startDate.date))
            .utcStartOfWeek
        let cellDate = CalendarDate(calendar.utcStartOfDay(byAdding: DateComponents(day: indexPath.item), to: startMonthDate.date))
        let counterDate = calendar.utcStartOfDay(byAdding: DateComponents(month: indexPath.section), to: input.calendarInterval.start)
        let monthComponents = calendar.dateComponents([.year, .month], from: counterDate)
        let startOfWeek = cellDate == cellDate.utcStartOfWeek
        let startOfMonth = cellDate == cellDate.utcStartOfMonth
        let endOfWeek = cellDate == cellDate.utcEndOfWeek
        let endOfMonth = cellDate == cellDate.utcEndOfMonth
        let leftRounded = startOfWeek || startOfMonth
        let rightRounded = endOfWeek || endOfMonth
        let reuseIdentifier: String
        if leftRounded && rightRounded {
            reuseIdentifier = "fullRoundedCell"
        } else if leftRounded {
            reuseIdentifier = "leftRoundedDayCell"
        } else if rightRounded {
            reuseIdentifier = "rightRoundedDayCell"
        } else {
            reuseIdentifier = "dayCell"
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
            for: indexPath) as? DayCollectionViewCell else {
            fatalError("Unexpected element kind")
        }
        collectionViewCells.insert(cell)
        cell.leftRounded = leftRounded
        cell.rightRounded = rightRounded
        cell.input = DayCollectionViewCell.Input(
            pickedRange: { [weak self] in
                self?.pickedRange
            },
            monthComponents: monthComponents,
            date: cellDate,
            enabledInterval: input.enabledInterval,
            calendarInterval: input.calendarInterval,
            pickedRangeLengthMin: input.pickedRangeLengthMin,
            pickedRangeLengthMax: input.pickedRangeLengthMax,
            theme: input.theme
        )
        cell.update(isInitial: true)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath)
            -> UICollectionReusableView {
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "monthView", for: indexPath) as? MonthHeaderCollectionReusableView else {
                    fatalError("Unexpected element kind")
                }
                let calendar = AppLocale.utcCalendar
                let startDate = CalendarDate(input.calendarInterval.start).utcStartOfMonth
                let headerDate = calendar.utcStartOfDay(byAdding: DateComponents(month: indexPath.section), to: startDate.date)
                reusableView.input = MonthHeaderCollectionReusableView.Input(date: CalendarDate(headerDate), theme: input.theme)
                return reusableView
            default:  fatalError("Unexpected element kind")
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell else {
            return
        }
        if input.enabledInterval.contains(cell.input.date.utcEndOfDay.date)
            && input.calendarInterval.contains(cell.input.date.utcEndOfDay.date)
            && cell.isInRangeLimits
            && !AppLocale.calendar.isDateInToday(cell.input.date.date) {
            pick(date: cell.input.date)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellIntersection: CGFloat
        let width = (collectionView.frame.width - collectionInset * 2) / 7
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        -2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
            insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: collectionInset,
            bottom: 15, right: collectionInset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 54)
    }

    func setupViews() {
        addSubview(collectionView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: collectionView,
                in: self
            )
        )
        if let weekdaysView = weekdaysView {
            addSubview(weekdaysView)
            weekdaysView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                weekdaysView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                weekdaysView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
                weekdaysView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
                weekdaysView.heightAnchor.constraint(equalToConstant: 54)
            ])
        }
    }

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
}

private extension Calendar {
    func utcStartOfDay(byAdding components: DateComponents, to date: Date, wrappingComponents: Bool = false) -> Date {
        guard let date = self.date(byAdding: components, to: date, wrappingComponents: wrappingComponents) else {
            fatalError("Incorrect calendar date!")
        }
        return AppLocale.utcCalendar.startOfDay(for: date)
    }
}
