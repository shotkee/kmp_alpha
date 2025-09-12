//
//  InsuranceVzrOnOffCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/14/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsuranceVzrOnOffCell: UITableViewCell {
    enum State {
        case error((() -> Void)?)
        case loading
        case balance(Int)
        case activeTrip(Int, VzrOnOffTrip)
    }

    struct Output {
        let buyDays: () -> Void
        let startTrip: () -> Void
        let tripList: () -> Void
        let purchaseList: () -> Void
    }

    struct Notify {
        var stateUpdated: (State) -> Void
    }

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        stateUpdated: { [weak self] state in
            guard let self = self else { return }

            self.updateState(state)
            self.state = state
        }
    )

    var output: Output!
    private var state: State = .loading

    static let id: Reusable<InsuranceVzrOnOffCell> = .fromNib()

    @IBOutlet private var topLabel: UILabel!
    @IBOutlet private var bottomLabel: UILabel!
    @IBOutlet private var topButton: UIButton!
    @IBOutlet private var bottomButton: RoundEdgeButton!
    @IBOutlet private var tripListImageView: UIImageView!
    @IBOutlet private var tripListLabel: UILabel!
    @IBOutlet private var purchaseListImageView: UIImageView!
    @IBOutlet private var purchaseListLabel: UILabel!
    @IBOutlet private var cardViewContentView: UIView!
    private var errorView: ActiveInsuranceErrorView?
    private var shimmerView: ActiveTripShimmerView?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter(dateFormat: "dd.MM.yyyy")
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        errorView?.layer.cornerRadius = cardViewContentView.layer.cornerRadius
        shimmerView?.layer.cornerRadius = cardViewContentView.layer.cornerRadius
    }

    private func setupUI() {
        topButton <~ Style.Button.redLabelButton
        bottomButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        topButton.setTitle(NSLocalizedString("vzr_purchase_days_package", comment: ""), for: .normal)
        tripListImageView.image = UIImage(named: "icon-vzr-on-off-trips")
        purchaseListImageView.image = UIImage(named: "icon-vzr-on-off-purchases")
        tripListLabel <~ Style.Label.secondaryText
        tripListLabel.text = NSLocalizedString("vzr_trips_list", comment: "")
        purchaseListLabel <~ Style.Label.secondaryText
        purchaseListLabel.text = NSLocalizedString("vzr_purchase_list", comment: "")
        let errorView: ActiveInsuranceErrorView = .fromNib()
        self.errorView = errorView
        errorView.isHidden = true
        addSubview(errorView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: errorView, in: cardViewContentView))
        let shimmerView: ActiveTripShimmerView = .fromNib()
        self.shimmerView = shimmerView
        shimmerView.isHidden = false
        addSubview(shimmerView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: shimmerView, in: cardViewContentView))
    }

    private func updateState(_ state: State) {
        switch state {
            case .loading:
                errorView?.isHidden = true
                shimmerView?.isHidden = false
                shimmerView?.start()
            case .error(let action):
                errorView?.isHidden = false
                errorView?.setReloadAction(action)
                shimmerView?.isHidden = true
                shimmerView?.stop()
            case .activeTrip(let daysBalance, let activeTrip):
                errorView?.isHidden = true
                shimmerView?.stop()
                shimmerView?.isHidden = true
                let durationString = (NSLocalizedString("vzr_is_on_info_header", comment: "") <~ Style.TextAttributes.normalText).mutable
                durationString.append(
                    String(
                        format: NSLocalizedString("vzr_date_trip_duration_interval_format", comment: ""),
                        InsuranceVzrOnOffCell.dateFormatter.string(from: activeTrip.startDate),
                        InsuranceVzrOnOffCell.dateFormatter.string(from: activeTrip.endDate)
                    ) <~ Style.TextAttributes.datesLabelText
                )
                topLabel.attributedText = durationString
                let daysLeftString = NSLocalizedString("vzr_is_on_days_left_title_format", comment: "")
                let daysLeftAttributedString = (daysLeftString <~ Style.TextAttributes.daysBalanceText).mutable
                let daysString = (AppLocale.days(from: daysBalance) ?? "") <~ Style.TextAttributes.daysBalanceBoldText
                daysLeftAttributedString.replace("{balance}", with: daysString)
                bottomLabel.attributedText = daysLeftAttributedString
                bottomButton.setTitle(NSLocalizedString("vzr_is_on_active_new_trip", comment: ""), for: .normal)
            case .balance(let daysBalance):
                errorView?.isHidden = true
                shimmerView?.stop()
                shimmerView?.isHidden = true
                topLabel <~ Style.Label.primaryHeadline1
                let daysFormat = NSLocalizedString("vzr_days_left_title", comment: "")
                topLabel.text = String(format: daysFormat, AppLocale.days(from: daysBalance) ?? "")
                bottomLabel <~ Style.Label.primaryText
                bottomLabel.text = NSLocalizedString("vzr_activate_trip_reminder", comment: "")
                bottomButton.setTitle(NSLocalizedString("vzr_activate_new_trip", comment: ""), for: .normal)
        }
    }

    @IBAction private func topButtonTap(_ sender: UIButton) {
        output.buyDays()
    }

    @IBAction private func bottomButtonTap(_ sender: UIButton) {
        output.startTrip()
    }

    @IBAction private func tripListTap(_ sender: UIButton) {
        output.tripList()
    }

    @IBAction private func purchaseListTap(_ sender: UIButton) {
        output.purchaseList()
    }
}
