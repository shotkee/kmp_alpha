//
//  VzrActiveTripView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/7/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class ActiveOnOffInsuranceView: UIView {
    enum Kind {
        case vzr
        case flat
    }

    struct Info {
        var insuredObjectTitle: String
        var startDate: Date
        var endDate: Date
        var insuranceId: String
    }

    enum State {
        case data(Info)
        case error
    }

    struct Output {
        var viewInsurance: () -> Void
        var reload: () -> Void
    }

    struct Notify {
        var stateUpdated: (State) -> Void
    }

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        stateUpdated: { [weak self] state in
            guard let self = self else { return }

            self.setState(state)
        }
    )

    var output: Output?

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var insuredPersonNameLabel: UILabel!
    @IBOutlet private var insuredPeriodLabel: UILabel!
    @IBOutlet private var viewInsuranceButton: RoundEdgeButton!
    private var errorView: ActiveInsuranceErrorView?
    private(set) var insuranceId: String?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter(dateFormat: "dd.MM.yyyy")
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        titleLabel <~ Style.Label.primaryHeadline1
        insuredPersonNameLabel <~ Style.Label.primaryText
        insuredPeriodLabel <~ Style.Label.primaryTitle1
        viewInsuranceButton <~ Style.RoundedButton.redBordered
        viewInsuranceButton.setTitle(NSLocalizedString("common_view_insurance", comment: ""), for: .normal)
        let errorView: ActiveInsuranceErrorView = .fromNib()
        self.errorView = errorView
        errorView.isHidden = true
        addSubview(errorView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: errorView, in: self))
    }

    func configure(for type: Kind) {
        let titleText: String
        switch type {
            case .flat:
                titleText = NSLocalizedString("flat_is_on_title", comment: "")
            case .vzr:
                titleText = NSLocalizedString("vzr_is_on_title", comment: "")
        }
        titleLabel.text = titleText
    }

    private func setState(_ state: State) {
        switch state {
            case .data(let info):
                insuranceId = info.insuranceId
                errorView?.isHidden = true
                viewInsuranceButton.isEnabled = true
                insuredPersonNameLabel.text = info.insuredObjectTitle
                insuredPeriodLabel.text = String(
                    format: NSLocalizedString("vzr_insured_period_format", comment: ""),
                    ActiveOnOffInsuranceView.dateFormatter.string(from: info.startDate),
                    ActiveOnOffInsuranceView.dateFormatter.string(from: info.endDate)
                )
            case .error:
                errorView?.isHidden = false
                errorView?.setReloadAction(output?.reload)
                viewInsuranceButton.isEnabled = false
        }
    }

    @IBAction private func viewInsuranceTap(_ sender: UIButton) {
        output?.viewInsurance()
    }
}
