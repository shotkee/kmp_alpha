//
//  FlatOnOffBuyDaysViewController.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 12.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class FlatOnOffBuyDaysViewController: ViewController {
    struct Input {
        let packages: (@escaping (Result<[FlatOnOffPurchaseItem], AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let selectPackage: (FlatOnOffPurchaseItem) -> Void
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
        title = NSLocalizedString("flat_on_off_packages_title", comment: "")
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel <~ Style.Label.primaryCaption1
        infoLabel.text = NSLocalizedString("flat_on_off_packages_info", comment: "")
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
                        for package in packages {
                            let packageView: DayPackageView = .fromNib()
                            packageView.configure(title: package.title, price: package.price, currency: "RUB") {
                                self.output.selectPackage(package)
                            }
                            self.stackView.addArrangedSubview(CardView(contentView: packageView))
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
