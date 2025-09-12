//
//  InsuranceFlatOnOffCell.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 01.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsuranceFlatOnOffCell: UITableViewCell {
    enum State {
        case loading
        case active(_ start: Date, _ finish: Date, _ balance: Int)
        case inactive(_ balance: Int)
        case error(_ mode: InsuranceFlatOnOffErrorView.Mode, _ refreshAction: () -> Void)
    }

    struct Output {
        let openActivations: () -> Void
        let openPurchases: () -> Void
        let buyDays: () -> Void
        let activate: () -> Void
    }

    struct Notify {
        var stateUpdated: (State) -> Void
    }

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify: Notify = Notify(
        stateUpdated: { [weak self] state in
            guard let self = self else { return }

            self.state = state
            self.reload()
        }
    )

    var output: Output!
    private var state: State = .loading

    static let id: Reusable<InsuranceFlatOnOffCell> = Reusable<InsuranceFlatOnOffCell>.fromNib()

    @IBOutlet private var contentContainer: UIView!
    @IBOutlet private var bottomButtonsStackView: UIStackView!
    @IBOutlet private var activationsImageView: UIImageView!
	@IBOutlet private var activationsLabel: UILabel! {
		didSet {
			activationsLabel <~ Style.Label.primaryText
		}
	}
    @IBOutlet private var purchasesImageView: UIImageView!
	@IBOutlet private var purchasesLabel: UILabel! {
		didSet {
			purchasesLabel <~ Style.Label.primaryText
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()

        // [TODO]: Temporarily remove history buttons
        bottomButtonsStackView.isHidden = true
    }

    private func reload() {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }

        let contentView: UIView
        switch state {
            case .loading:
                let view = InsuranceFlatOnOffLoadingView.fromNib()
                contentView = view
                view.start()
            case .active(let start, let finish, let balance):
                let view = InsuranceFlatOnOffActiveView.fromNib()
                view.configure(
                    start: start,
                    finish: finish,
                    balance: balance,
                    purchaseAction: output.buyDays,
                    activateAction: output.activate
                )
                contentView = view
            case .inactive(let balance):
                let view = InsuranceFlatOnOffInactiveView.fromNib()
                view.configure(balance: balance, purchaseAction: output.buyDays, activateAction: output.activate)
                contentView = view
            case .error(let mode, let refreshAction):
                let view = InsuranceFlatOnOffErrorView.fromNib()
                view.configure(mode: mode, refreshAction: refreshAction)
                contentView = view
        }
        let cardView = CardView(contentView: contentView)
        contentContainer.addSubview(cardView)
        let constraints = NSLayoutConstraint.fill(view: cardView, in: contentContainer)
        NSLayoutConstraint.activate(constraints)
    }

    @IBAction private func openActivations() {
        output.openActivations()
    }

    @IBAction private func openPurchases() {
        output.openPurchases()
    }
}
