//
//  VzrOnOffDaysPackagesViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/16/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffDaysPackagesViewController: ViewController {
    struct Input {
        let packages: (@escaping (Result<[VzrOnOffPurchaseItem], AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let selectPackage: (VzrOnOffPurchaseItem) -> Void
    }

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var infoLabel: UILabel!

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("vzr_buy_day_packages_title", comment: "")
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel <~ Style.Label.primaryCaption1
        infoLabel.text = NSLocalizedString("vzr_on_off_days_packages_info_text", comment: "")
        addZeroView()
        showZeroView()
        refresh()
    }

    private func refresh() {
        zeroView?.update(viewModel: .init(kind: .loading))
        input.packages { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let packages):
                    if packages.isEmpty {
                        self.zeroView?.update(viewModel: .init(kind: .emptyList))
                    } else {
                        self.hideZeroView()
                        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                        for (index, package) in packages.enumerated() {
                            let packageView: DayPackageView = .fromNib()
                            packageView.configure(title: package.title, price: package.currencyPrice, currency: package.currency) {
                                self.output.selectPackage(package)
                            }
                            self.stackView.addArrangedSubview(packageView)
                            if index < packages.count - 1 {
                                let hairlineView = HairLineView()
                                hairlineView.translatesAutoresizingMaskIntoConstraints = false
                                hairlineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
                                self.stackView.addArrangedSubview(hairlineView)
                            }
                        }
                    }
                case .failure(let error):
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .unreachableErrorOnly, action: { [weak self] in self?.refresh() })),
                        buttons: OperationStatusView.ButtonConfiguration.mainScreenOtChat
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
            }
        }
    }
}
