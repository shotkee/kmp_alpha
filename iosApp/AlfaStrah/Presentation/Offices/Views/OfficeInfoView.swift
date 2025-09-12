//
//  OfficeInfoView.swift
//  AlfaStrah
//
//  Created by Darya Viter on 08.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

final class OfficeInfoView: UIView {
    // Constants
    private enum Constants {
        static let rootStackViewInsets: UIEdgeInsets = .init(top: 15, left: 15, bottom: 15, right: 15)
        static let cardViewMargins: UIEdgeInsets = .init(top: 10, left: 18, bottom: 5, right: 18)
        static let rootToAddressStackViewSpacing: CGFloat = 9
        static let rootToMetroStackViewSpacing: CGFloat = 12
        static let metroIcon: UIImage? = .Icons.metro.tintedImage(withColor: .Icons.iconSecondary)
        static let separatorColor: UIColor = .Stroke.divider
        static let separatorSize: CGSize = .init(width: 1, height: 12)
        static let addressStackViewSpacing: CGFloat = 8
        static let kmText = NSLocalizedString("common_distance_unit_km_to", comment: "")
        static let mText = NSLocalizedString("common_distance_unit_m_to", comment: "")
        static let metroStackViewSpacing: CGFloat = 3
        static let metroImageSize: CGSize = .init(width: 20, height: 20)
        static let timeStackViewSpacing: CGFloat = 9
    }

    private enum Styles {
        static let addressLabelStyle = Style.Label.primaryHeadline1
        static let distanceLabelStyle = Style.Label.secondaryText
        static let metroLabelStyle = Style.Label.secondaryText
        static let workTimeLabelStyle = Style.Label.accentSubhead
        static let lunchTimeLabelStyle = Style.Label.accentSubhead
    }

    private var cardViewMargins: UIEdgeInsets?
    
    var cornerSide: CardView.Side = .all {
        didSet {
            cardView.cornersSide = self.cornerSide
        }
    }
    
    var hideShadow: Bool = false {
        didSet {
            cardView.hideShadow = self.hideShadow
        }
    }
    
    var cardViewColor: Bool = false {
        didSet {
            cardView.hideShadow = self.hideShadow
        }
    }
    
    var color: UIColor = .Background.backgroundSecondary {
        didSet {
            rootStackView.backgroundColor = self.color
        }
    }

    // Views
    
    private lazy var cardView = CardView()
    
    private lazy var timeSeparatorView: UIView = {
        let separator: UIView = .init(frame: .zero)
        separator.backgroundColor = Constants.separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalToConstant: Constants.separatorSize.width),
            separator.heightAnchor.constraint(equalToConstant: Constants.separatorSize.height),
        ])
        return separator
    }()

    private lazy var metroImageView: UIImageView = {
        let imageView: UIImageView = .init(frame: .zero)
        imageView.accessibilityIdentifier = #function
        imageView.image = Constants.metroIcon
        imageView.contentMode = .center
        imageView.backgroundColor = .clear
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()

    // Stacks

    private lazy var rootStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.backgroundColor = .Background.backgroundSecondary
        stack.accessibilityIdentifier = #function
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Constants.rootToAddressStackViewSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = Constants.rootStackViewInsets
        return stack
    }()

    private lazy var addressStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = Constants.addressStackViewSpacing
        return stack
    }()

    private lazy var metroStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.alignment = .top
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = Constants.metroStackViewSpacing
        return stack
    }()

    private lazy var timeStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.axis = .horizontal
        // https://stackoverflow.com/a/43110590
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = Constants.timeStackViewSpacing
        return stack
    }()

    // Labels

    private lazy var addressLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var distanceLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var metroLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.numberOfLines = 0
        return label
    }()

    private lazy var workTimeLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var lunchTimeLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.numberOfLines = 1
        return label
    }()

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }
    
    init(frame: CGRect, margins: UIEdgeInsets? = nil) {
        cardViewMargins = margins

        super.init(frame: frame)
        
        setupUI()
    }

    // MARK: Builders

    private func setupUI() {
        // use isUserInteractionEnabled for fix bug: shadow show when tapped on view
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        addSubview(cardView)
        setupCardView()
        
        addressLabel <~ Styles.addressLabelStyle
        distanceLabel <~ Styles.distanceLabelStyle
        metroLabel <~ Styles.metroLabelStyle
        workTimeLabel <~ Styles.workTimeLabelStyle
        lunchTimeLabel <~ Styles.lunchTimeLabelStyle
    }
    
    private func setupCardView() {
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: cardView,
                in: self,
                margins: cardViewMargins ?? Constants.cardViewMargins
            )
        )
        cardView.set(content: rootStackView)
        
        setupRootStack()
    }
    
    private func setupRootStack() {
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: rootStackView,
                in: cardView
            )
        )

        rootStackView.addArrangedSubview(addressStackView)
        setupAddressView()
        rootStackView.addArrangedSubview(metroStackView)
        setupMetroStack()
        rootStackView.addArrangedSubview(timeStackView)
        setupTimeStack()
        rootStackView.setCustomSpacing(Constants.rootToMetroStackViewSpacing, after: metroStackView)
    }

    private func setupAddressView() {
        addressStackView.addArrangedSubview(addressLabel)
        addressStackView.addArrangedSubview(distanceLabel)
    }

    private func setupMetroStack() {
        metroStackView.addArrangedSubview(metroImageView)
        metroStackView.addArrangedSubview(metroLabel)

        metroImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            metroImageView.heightAnchor.constraint(equalToConstant: Constants.metroImageSize.height),
            metroImageView.widthAnchor.constraint(equalToConstant: Constants.metroImageSize.width),
            metroLabel.bottomAnchor.constraint(equalTo: metroStackView.bottomAnchor)
        ])
    }

    private func setupTimeStack() {
        timeStackView.addArrangedSubview(workTimeLabel)
        timeStackView.addArrangedSubview(timeSeparatorView)
        timeStackView.addArrangedSubview(lunchTimeLabel)
    }
    
    func setAddressLabelStyle(style: Style.Label.ColoredLabel) {
        addressLabel <~ style
    }
    
    func setInternalMargins(margins: UIEdgeInsets) {
        rootStackView.layoutMargins = margins
    }

    func set(
        address: String,
        distance: Double?,
        metros: [String] = [],
        marginForView: UIEdgeInsets? = nil
    ) {
        addressLabel.text = TextHelper.html(from: address).string
        let distanceText = makeDistanceText(from: distance)
        distanceLabel.text = distanceText
        distanceLabel.isHidden = distanceText.isEmpty

        metroStackView.isHidden = metros.isEmpty
        metroLabel.text = metros.joined(separator: ", ")

        timeStackView.isHidden = true
    }

    func set(office: Office, marginForView: UIEdgeInsets? = nil) {
        addressLabel.text = TextHelper.html(from: office.address).string
        distanceLabel.text = makeDistanceText(from: office.distance)

        if let metros = office.metro, !metros.isEmpty {
            metroStackView.isHidden = false
            metroLabel.text = metros.joined(separator: ", ")
        } else {
            metroStackView.isHidden = true
        }

        if !office.isWorkToday {
            workTimeLabel.isHidden = false
            workTimeLabel.text = NSLocalizedString("office_info_view_close_today_text", comment: "")
		} else if let workTimeLabelText = getWorkTimeText(for: office) {
			workTimeLabel.isHidden = false
			workTimeLabel.text = workTimeLabelText
		} else {
			workTimeLabel.isHidden = true
		}

        if let breakTimeText = getBreakTimeText(for: office), !workTimeLabel.isHidden {
            timeSeparatorView.isHidden = false
            lunchTimeLabel.isHidden = false
            lunchTimeLabel.text = breakTimeText
        } else {
            timeSeparatorView.isHidden = true
            lunchTimeLabel.isHidden = true
        }

        timeStackView.isHidden = workTimeLabel.isHidden
        layoutIfNeeded()
    }

    private func makeDistanceText(from distance: Double?) -> String {
        guard let officeDistance = distance else { return "" }

        return officeDistance / 1000 < 1
            ? String(format: Constants.mText, officeDistance.rounded())
            : String(format: Constants.kmText, (officeDistance / 1000).rounded())
    }

    private func getWorkTimeText(for office: Office) -> String? {
        guard let officeWorkHours = office.getWorkTimeDates() else { return nil }

        let startTimeDateHour = AppLocale.dateComponentsOfDay(officeWorkHours.todayStartTime).hour ?? 0
        let closeTimeDateHour = AppLocale.dateComponentsOfDay(officeWorkHours.todayCloseTime).hour ?? 0
        let currentHour = AppLocale.dateComponentsOfDay(Date()).hour ?? 0

        var workTimeLabelText = ""
        if startTimeDateHour > currentHour {
            workTimeLabelText = String(
                format: NSLocalizedString("office_info_view_will_open_text", comment: ""),
                "\(AppLocale.timeString(officeWorkHours.todayStartTime))")
        } else if startTimeDateHour <= currentHour, closeTimeDateHour > currentHour {
            workTimeLabelText = String(
                format: NSLocalizedString("office_info_view_open_until_text", comment: ""),
                "\(AppLocale.timeString(officeWorkHours.todayCloseTime))")
        } else if startTimeDateHour < currentHour, closeTimeDateHour <= currentHour {
            workTimeLabelText = String(
                format: NSLocalizedString("office_info_view_close_until_text", comment: ""),
				"\(AppLocale.timeString(officeWorkHours.nextDayStartTime))",
                "\(officeWorkHours.nextWorkWeekDay.declensionOfWeekdayRus)")
        }

        return workTimeLabelText
    }

    private func getBreakTimeText(for office: Office) -> String? {
        guard let breakTime = office.getBreakTime(),
              let officeWorkHours = office.getWorkTimeDates() else { return nil }

        let startTimeDateHour = AppLocale.dateComponentsOfDay(officeWorkHours.todayStartTime).hour ?? 0
        let closeTimeDateHour = AppLocale.dateComponentsOfDay(officeWorkHours.todayCloseTime).hour ?? 0
        let currentHour = AppLocale.dateComponentsOfDay(Date()).hour ?? 0

        if office.isWorkToday && startTimeDateHour < currentHour && closeTimeDateHour > currentHour {
            return String(
                format: NSLocalizedString("office_info_view_lunch_time_text", comment: ""),
                breakTime.breakStartTime, breakTime.breakEndTime
            )
        } else {
            return nil
        }
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
        guard let image = metroImageView.image
        else { return }
        
        metroImageView.image = image.tintedImage(withColor: .Icons.iconSecondary)
    }
}
