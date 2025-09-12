//
//  VzrOnOffTripHistoryCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/21/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class VzrOnOffTripHistoryCell: UITableViewCell {
    enum CellType {
        case sectionTop(Int)
        case normal
    }

    @IBOutlet private var sectionTitleLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!
    private let titleLabel: UILabel = UILabel()

    static let id: Reusable<VzrOnOffTripHistoryCell> = .fromNib()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    private func setupUI() {
        backgroundColor = .clear
        layer.masksToBounds = false
        titleLabel <~ Style.Label.primaryText
        sectionTitleLabel <~ Style.Label.primaryHeadline1
    }

    func configure(title: String, trips: [VzrOnOffTrip], type: CellType) {
        switch type {
            case .normal:
                sectionTitleLabel.isHidden = true
            case .sectionTop(let year):
                sectionTitleLabel.isHidden = false
                sectionTitleLabel.text = String(format: NSLocalizedString("vzr_trip_list_section_title", comment: ""), "\(year)")
        }
        let titleLabelView = UIView()
        titleLabelView.addSubview(titleLabel)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: titleLabel,
                in: titleLabelView,
                margins: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            )
        )
        stackView.addArrangedSubview(titleLabelView)
        titleLabel.text = title
        for (index, trip) in trips.enumerated() {
            let tripView: VzrOnOffTripView = .fromNib()
            tripView.configure(startDate: trip.startDate, endDate: trip.endDate, tripStatus: trip.status)
            stackView.addArrangedSubview(tripView)
            if index < trips.count - 1 {
                let hairlineView = HairLineView()
                hairlineView.translatesAutoresizingMaskIntoConstraints = false
                hairlineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
                stackView.addArrangedSubview(hairlineView)
            }
        }
    }
}

class VzrOnOffTripView: UIView {
    @IBOutlet private var datesIntervalLabel: UILabel!
    @IBOutlet private var tripDurationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        datesIntervalLabel <~ Style.Label.primaryHeadline3
        tripDurationLabel <~ Style.Label.primaryCaption1
    }

    func configure(startDate: Date, endDate: Date, tripStatus: VzrOnOffTrip.TripStatus) {
        datesIntervalLabel.text = String(
            format: NSLocalizedString("vzr_date_interval_format", comment: ""),
            AppLocale.shortDateString(startDate),
            AppLocale.shortDateString(endDate)
        )
        let datesIntervalLabelColor: UIColor
        switch tripStatus {
            case .active:
                datesIntervalLabelColor = Style.Color.Palette.red
            case .planned:
                datesIntervalLabelColor = Style.Color.Palette.black
            case .passed:
                datesIntervalLabelColor = Style.Color.Palette.lightGray
        }
        datesIntervalLabel.textColor = datesIntervalLabelColor
        tripDurationLabel.text = String(
            format: NSLocalizedString("vzr_trip_duration_format", comment: ""),
            AppLocale.days(from: AppLocale.daysCount(fromDate: startDate, toDate: endDate, absolute: true)) ?? ""
        )
    }
}
