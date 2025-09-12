//
//  FlatOnOffActivateViewController.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 09.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class FlatOnOffActivateViewController: ViewController {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var periodTitleLabel: UILabel!
    @IBOutlet private var periodValueLabel: UILabel!
    @IBOutlet private var periodImageView: UIImageView!
    @IBOutlet private var periodSeparator: HairLineView!
    @IBOutlet private var continueButton: UIButton!
    @IBOutlet private var daysCountLabel: UILabel!
    @IBOutlet private var balanceValueLabel: UILabel!
    @IBOutlet private var balanceTitleLabel: UILabel!
    @IBOutlet private var buyDaysLabel: UILabel!
    @IBOutlet private var aboutProgramLabel: UILabel!

    struct Input {
        let balance: (@escaping (Result<Int, AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let openCalendar: (_ initialRange: DateRange?, _ completion: @escaping (DateRange) -> Void) -> Void
        let proceed: (_ from: Date, _ to: Date, _ completion: @escaping (Result<Void, AlfastrahError>) -> Void) -> Void
        let buyDays: () -> Void
        let about: () -> Void
        let buyPolicy: () -> Void
        let openChat: () -> Void
    }

    var input: Input!
    var output: Output!

    private enum State {
        case disabled
        case enabled(start: Date, finish: Date)
    }

    private var state: State = .disabled

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        addZeroView()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshBalance()
    }

    private func setup() {
        title = NSLocalizedString("flat_on_off_title", comment: "")
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("flat_on_off_activate_title", comment: "")
        subtitleLabel <~ Style.Label.secondaryText
        subtitleLabel.text = NSLocalizedString("flat_on_off_activate_subtitle", comment: "")
        periodTitleLabel.text = NSLocalizedString("flat_on_off_activate_period_title", comment: "")
        continueButton <~ Style.Button.ActionRedRounded(title: NSLocalizedString("common_next", comment: ""))
        balanceTitleLabel <~ Style.Label.secondaryText
        balanceTitleLabel.text = NSLocalizedString("flat_on_off_activate_balance_title", comment: "")
        balanceValueLabel <~ Style.Label.primaryHeadline2
        buyDaysLabel <~ Style.Label.primaryText
        buyDaysLabel.text = NSLocalizedString("flat_on_off_activate_buy_days", comment: "")
        aboutProgramLabel <~ Style.Label.primaryText
        aboutProgramLabel.text = NSLocalizedString("flat_on_off_activate_about_program", comment: "")
    }

    private func updateUI() {
        switch state {
            case .disabled:
                periodTitleLabel <~ Style.Label.secondaryText
                periodValueLabel.text = nil
                periodValueLabel.isHidden = true
                periodImageView.tintColor = Style.Color.Palette.whiteGray
                continueButton.isEnabled = false
                daysCountLabel.text = nil
                daysCountLabel.isHidden = true
            case .enabled(let start, let finish):
                periodTitleLabel <~ Style.Label.primaryCaption1
                let format = NSLocalizedString("flat_on_off_activate_period_value", comment: "")
                periodValueLabel.text = String(format: format, AppLocale.shortDateString(start), AppLocale.shortDateString(finish))
                periodValueLabel.isHidden = false
                periodImageView.tintColor = Style.Color.main
                continueButton.isEnabled = true

                let duration = AppLocale.daysCount(fromDate: start, toDate: finish, absolute: true)
                let daysString = String(format: NSLocalizedString("insurance_expiration_days", comment: ""), duration)
                let fullDaysString = (String.localizedStringWithFormat(
                    NSLocalizedString("flat_on_off_activate_days_count", comment: ""), daysString
                ) <~ Style.TextAttributes.grayInfoText).mutable

                let durationString = String(describing: duration) <~ Style.TextAttributes.daysBalanceBoldText
                fullDaysString.replace(String(describing: duration), with: durationString)

                daysCountLabel.attributedText = fullDaysString
                daysCountLabel.isHidden = false
        }
    }

    private func refreshBalance() {
        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        input.balance { result in
            switch result {
                case .success(let balance):
                    let format = NSLocalizedString("insurance_expiration_days", comment: "")
                    self.balanceValueLabel.text = String.localizedStringWithFormat(format, balance)
                case .failure:
                    self.balanceValueLabel.text = NSLocalizedString("flat_on_off_error_title", comment: "")
            }
            self.hideZeroView()
        }
    }

    @IBAction private func openCalendar() {
        let processSelection: (DateRange) -> Void = { range in
            guard let endDate = range.finishDate?.date else { return }

            self.state = .enabled(start: range.startDate.date, finish: endDate)
            self.updateUI()
        }

        switch state {
            case .disabled:
                output.openCalendar(nil, processSelection)
            case .enabled(let start, let finish):
                output.openCalendar(DateRange(startDate: start, finishDate: finish), processSelection)
        }
    }

    @IBAction private func continueActivation() {
        guard case .enabled(let fromDate, let toDate) = state else { return }

        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        output.proceed(fromDate, toDate) { result in
            self.hideZeroView()
            guard let error = result.error else { return }

            switch error.businessErrorKind {
                case .flatOnOffNoEnoughDays, .flatOnOffInsuranceExpire, .flatOnOffInsuranceNotActiveV1, .flatOnOffInsuranceNotActiveV2:
                    self.showErrorAlert(error)
                case .startChat:
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(
                            error,
                            retry: .init(kind: .unreachableErrorOnly, action: { [weak self] in self?.continueActivation() })
                        ),
                        buttons: OperationStatusView.ButtonConfiguration.mainScreenOtChat
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
                    self.showZeroView()
                default:
                    self.processError(error)
            }
        }
    }

    @IBAction private func openPurchaseScreen() {
        output.buyDays()
    }

    @IBAction private func openAboutProgramScreen() {
        output.about()
    }

    private func showErrorAlert(_ error: AlfastrahError) {
        let changeActionTitle = NSLocalizedString("common_change", comment: "")
        let changeAction = UIAlertAction(title: changeActionTitle, style: .default) { _ in self.openCalendar() }

        let buyDaysActionTitle = NSLocalizedString("flat_on_off_activate_error_buy_days", comment: "")
        let buyDaysAction = UIAlertAction(title: buyDaysActionTitle, style: .default) { _ in self.output.buyDays() }

        let chatActionTitle = NSLocalizedString("common_write_to_chat", comment: "")
        let chatAction = UIAlertAction(title: chatActionTitle, style: .default) { _ in self.output.openChat() }

        let buyPolicyActionTitle = NSLocalizedString("flat_on_off_activate_error_buy_policy", comment: "")
        let buyPolicyAction = UIAlertAction(title: buyPolicyActionTitle, style: .default) { _ in self.output.buyPolicy() }

        let actions: [UIAlertAction]
        switch error.businessErrorKind {
            case .flatOnOffNoEnoughDays:
                actions = [ changeAction, buyDaysAction ]
            case .flatOnOffInsuranceExpire:
                actions = [ chatAction, buyPolicyAction ]
            case .flatOnOffInsuranceNotActiveV1:
                actions = [ changeAction ]
            case .flatOnOffInsuranceNotActiveV2:
                actions = [ chatAction, changeAction ]
            default:
                return
        }

        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        actions.forEach(alert.addAction)
        present(alert, animated: true)
    }
}
