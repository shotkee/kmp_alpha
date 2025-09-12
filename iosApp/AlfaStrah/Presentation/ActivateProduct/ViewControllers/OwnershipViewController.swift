//
//  OwnershipViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/19/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

final class OwnershipViewController: ViewController {
    struct Input {
        let stepsCount: Int
        let currentStepIndex: Int
    }

    struct Output {
        let dealers: (OwnershipType) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var productTitleLabel: UILabel!
    @IBOutlet private var stepInfoLabel: UILabel!
    @IBOutlet private var apartmentButton: UIButton!
    @IBOutlet private var houseButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("activate_product_activation_title", comment: "")
        productTitleLabel <~ Style.Label.primaryText
        stepInfoLabel <~ Style.Label.primaryText
        apartmentButton <~ Style.Button.labelButton
        houseButton <~ Style.Button.labelButton
        apartmentButton.setTitle(NSLocalizedString("activate_product_apartment", comment: ""), for: .normal)
        houseButton.setTitle(NSLocalizedString("activate_product_house", comment: ""), for: .normal)
        productTitleLabel.text = NSLocalizedString("activate_product_product_type", comment: "")
        stepInfoLabel.text = String(
            format: NSLocalizedString("activate_product_step", comment: ""),
            input.currentStepIndex, input.stepsCount
        )
    }

    @IBAction private func apartmentTap(_ sender: UIButton) {
        output.dealers(.apartment)
    }

    @IBAction private func houseTap(_ sender: UIButton) {
        output.dealers(.house)
    }
}
