//
//  FlatOnOffProtectionsViewController.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 30.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class FlatOnOffProtectionsViewController: ViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var activateButton: RoundEdgeButton!

    struct Input {
        let protections: (@escaping (Result<[FlatOnOffProtection], AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let showPolicy: (URL) -> Void
        let activate: () -> Void
    }

    var input: Input!
    var output: Output!

    private struct Protections {
        let active: [FlatOnOffProtection]
        let upcoming: [FlatOnOffProtection]
        let completed: [FlatOnOffProtection]

        static let empty = Protections(active: [], upcoming: [], completed: [])
    }

    private var protections: Protections = .empty
    private let calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        reload()
    }

    private func setup() {
        title = NSLocalizedString("flat_on_off_activations_title", comment: "")
        addZeroView()
        activateButton <~ Style.RoundedButton.oldPrimaryButtonSmall
    }

    private func reload() {
        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        input.protections { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let protections):
                    if protections.isEmpty {
                        self.protections = .empty
                        self.zeroView?.update(viewModel: .init(kind: .emptyList))
                    } else {
                        let today = self.calendar.startOfDay(for: Date())

                        let active = protections.filter {
                            (self.calendar.startOfDay(for: $0.startDate) ... self.calendar.startOfDay(for: $0.endDate)).contains(today)
                        }
                        let upcoming = protections.filter { self.calendar.startOfDay(for: $0.startDate) > today }
                        let completed = protections.filter { self.calendar.startOfDay(for: $0.endDate) < today }
                        self.protections = Protections(active: active, upcoming: upcoming, completed: completed)
                        self.hideZeroView()
                    }
                case .failure(let error):
                    self.protections = .empty
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .unreachableErrorOnly, action: { [weak self] in self?.reload() })),
                        buttons: OperationStatusView.ButtonConfiguration.mainScreenOtChat
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
            }
            self.updateProtectionsList()
        }
    }

    private func updateProtectionsList() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if !protections.active.isEmpty {
            let view = FlatOnOffProtectionsSectionView()
            view.configure(mode: .active, protections: protections.active, showPolicyAction: output.showPolicy)
            contentStackView.addArrangedSubview(CardView(contentView: view))
        }
        if !protections.upcoming.isEmpty {
            let view = FlatOnOffProtectionsSectionView()
            view.configure(mode: .upcoming, protections: protections.upcoming, showPolicyAction: output.showPolicy)
            contentStackView.addArrangedSubview(CardView(contentView: view))
        }
        if !protections.completed.isEmpty {
            let view = FlatOnOffProtectionsSectionView()
            view.configure(mode: .completed, protections: protections.completed, showPolicyAction: output.showPolicy)
            contentStackView.addArrangedSubview(CardView(contentView: view))
        }
    }

    @IBAction private func activate() {
        output.activate()
    }
}
