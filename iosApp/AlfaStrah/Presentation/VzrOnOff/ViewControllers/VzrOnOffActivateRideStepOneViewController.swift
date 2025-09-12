//
//  VzrOnOffActivateRideStepOneViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19/10/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffStartTripStepOneViewController: ViewController {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tripTipLabel: UILabel!
    @IBOutlet private var dateTitleLabel: UILabel!
    @IBOutlet private var periodLabel: UILabel!
    @IBOutlet private var selectDateSectionImageView: UIImageView!
    @IBOutlet private var periodDaysCountLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var packageDaysCountLabel: UILabel!
    @IBOutlet private var packageDaysTipLabel: UILabel!
    @IBOutlet private var buyPackageLabel: UILabel!
    @IBOutlet private var aboutProgramLabel: UILabel!

    private var packageDaysCount = 0
    private var insurance: Insurance?

    struct Input {
        let dashboard: (@escaping (Result<VzrOnOffDashboardInfo, AlfastrahError>) -> Void) -> Void
        let insurance: (@escaping (Result<Insurance, AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let selectTripPeriod: (_ initialRange: DateRange?, _ completion: @escaping (DateRange) -> Void) -> Void
        let proceed: (TripPeriod) -> Void
        let buyDays: () -> Void
        let buyPolicy: () -> Void
        let about: () -> Void
    }

    var input: Input!
    var output: Output!

    struct TripPeriod {
        let startDate: Date
        let endDate: Date

        var duration: Int {
            AppLocale.daysCount(fromDate: startDate, toDate: endDate, absolute: true)
        }
    }

    private enum PeriodState {
        case period(TripPeriod)
        case empty
    }

    private var periodState: PeriodState = .empty

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("vzr_title", comment: "")
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        stackView.spacing = 15
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("vzr_is_on_activate_trip_title", comment: "")
        tripTipLabel <~ Style.Label.secondaryText
        tripTipLabel.text = NSLocalizedString("vzr_is_on_activate_trip_tip", comment: "")
        dateTitleLabel <~ Style.Label.secondaryText
        dateTitleLabel.text = NSLocalizedString("vzr_is_on_activate_trip_date_title", comment: "")
        periodLabel <~ Style.Label.primaryText
        periodDaysCountLabel <~ Style.Label.secondaryCaption1
        nextButton <~ Style.Button.ActionRedRounded(title: NSLocalizedString("common_next", comment: ""))
        packageDaysCountLabel <~ Style.Label.primaryHeadline2
        packageDaysCountLabel.text = ""
        packageDaysTipLabel <~ Style.Label.secondaryText
        packageDaysTipLabel.text = NSLocalizedString("vzr_days_amount_info", comment: "")
        buyPackageLabel <~ Style.Label.primaryText
        buyPackageLabel.text = NSLocalizedString("vzr_buy_day_packages_title", comment: "")
        aboutProgramLabel <~ Style.Label.primaryText
        aboutProgramLabel.text = NSLocalizedString("vzr_about_program_title", comment: "")
        addZeroView()
        refreshData()
    }

    private func updateUI() {
        packageDaysCountLabel.text = AppLocale.days(from: packageDaysCount)
        switch periodState {
            case .period(let tripPeriod):
                nextButton.isEnabled = true
                periodLabel.isHidden = false
                periodDaysCountLabel.isHidden = false
                selectDateSectionImageView.image = UIImage(named: "icon-checkmark")
                dateTitleLabel.font = Style.Font.caption2
                periodLabel.text = String(
                    format: NSLocalizedString("vzr_insured_period_format", comment: ""),
                    AppLocale.shortDateString(tripPeriod.startDate), AppLocale.shortDateString(tripPeriod.endDate)
                )

                let durationFormat = NSLocalizedString("vzr_selected_trip_duration_format", comment: "")
                let durationString = String.localizedStringWithFormat(durationFormat, AppLocale.days(from: tripPeriod.duration) ?? "")
                let durationAttributedString = (durationString <~ Style.TextAttributes.daysBalanceSmallText).mutable
                let rangeOfDate = NSString(string: durationAttributedString.string).range(of: "\(tripPeriod.duration)")
                durationAttributedString.addAttributes(Style.TextAttributes.daysBalanceSmallBoldText, range: rangeOfDate)
                periodDaysCountLabel.attributedText = durationAttributedString
            case .empty:
                nextButton.isEnabled = false
                periodLabel.isHidden = true
                periodDaysCountLabel.isHidden = true
                selectDateSectionImageView.image = UIImage(named: "icon-accessory-arrow-light_gray")
                dateTitleLabel.font = Style.Font.text
                periodLabel.text = nil
                periodDaysCountLabel.text = nil
        }
    }

    private func refreshData() {
        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        let dispatchGroup = DispatchGroup()
        var lastError: AlfastrahError?

        dispatchGroup.enter()
        input.dashboard { [weak self] result in
            dispatchGroup.leave()
            guard let self = self else { return }

            switch result {
                case .success(let dashboardInfo):
                    self.packageDaysCount = dashboardInfo.balance
                case .failure(let error):
                    lastError = error
            }
        }

        dispatchGroup.enter()
        input.insurance { [weak self] result in
            dispatchGroup.leave()
            guard let self = self else { return }

            switch result {
                case .success(let insurance):
                    self.insurance = insurance
                case .failure(let error):
                    lastError = error
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            if let error = lastError {
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .unreachableErrorOnly, action: { [weak self] in self?.refreshData() })),
                    buttons: OperationStatusView.ButtonConfiguration.mainScreenOtChat
                )
                self.zeroView?.update(viewModel: zeroViewModel)
            } else {
                self.hideZeroView()
            }
            self.updateUI()
        }
    }

    @IBAction private func selectDateButtonTap(_ sender: UIButton) {
        selectTripPeriod()
    }

    private func selectTripPeriod() {
        let initialDateRande: DateRange?
        switch periodState {
            case .empty:
                initialDateRande = nil
            case .period(let tripPeriod):
                initialDateRande = DateRange(startDate: tripPeriod.startDate, finishDate: tripPeriod.endDate)
        }
        output.selectTripPeriod(initialDateRande) { [weak self] pickedRange in
            guard let self = self, let endDate = pickedRange.finishDate?.date else { return }

            self.periodState = .period(TripPeriod(startDate: pickedRange.startDate.date, endDate: endDate))
            self.updateUI()
        }
    }

    @IBAction private func nextButtonTap(_ sender: UIButton) {
        guard case let .period(tripPeriod) = periodState else { return }

        if tripPeriod.duration > packageDaysCount {
            let alert = UIAlertController(
                title: NSLocalizedString("vzr_on_off_activate_trip_not_enough_days_title", comment: ""),
                message: NSLocalizedString("vzr_on_off_activate_trip_not_enough_days_message", comment: ""),
                preferredStyle: .alert
            )
            let changeAction = UIAlertAction(title: NSLocalizedString("common_change", comment: ""), style: .cancel) { _ in
                self.selectTripPeriod()
            }
            let buyAction = UIAlertAction(title: NSLocalizedString("vzr_on_off_buy_more_days", comment: ""), style: .destructive) { _ in
                self.output.buyDays()
            }
            alert.addAction(changeAction)
            alert.addAction(buyAction)
            present(alert, animated: true)
        } else if let insurance = insurance, tripPeriod.startDate > insurance.endDate || tripPeriod.endDate > insurance.endDate {
            let message = String(
                format: NSLocalizedString("vzr_on_off_activate_trip_period_exceeded_message_value", comment: ""),
                AppLocale.shortDateString(insurance.endDate)
            )
            let alert = UIAlertController(
                title: NSLocalizedString("vzr_on_off_activate_trip_period_exceeded_title", comment: ""),
                message: message,
                preferredStyle: .alert
            )
            let changeAction = UIAlertAction(title: NSLocalizedString("common_change", comment: ""), style: .cancel) { _ in
                self.selectTripPeriod()
            }
            let buyAction = UIAlertAction(title: NSLocalizedString("vzr_on_off_buy_new_policy", comment: ""), style: .destructive) { _ in
                self.output.buyPolicy()
            }
            alert.addAction(changeAction)
            alert.addAction(buyAction)
            present(alert, animated: true)
        } else {
            output.proceed(tripPeriod)
        }
    }

    @IBAction private func buyDaysTap(_ sender: UIButton) {
        output.buyDays()
    }

    @IBAction private func aboutTap(_ sender: UIButton) {
        output.about()
    }
}
