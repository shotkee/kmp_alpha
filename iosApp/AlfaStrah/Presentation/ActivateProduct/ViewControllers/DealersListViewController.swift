//
//  DealersListViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/19/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class DealersListViewController: ViewController,
								 UITableViewDataSource,
								 UITableViewDelegate {
    private enum Constants {
        static let cellHeight: CGFloat = 64
    }

    struct Input {
        let stepsCount: Int
        let currentStepIndex: Int
        let getDealers: (@escaping ([InsuranceDealer]) -> Void) -> Void
    }

    struct Output {
        let showDealerWithId: (String) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var productTitleLabel: UILabel!
    @IBOutlet private var stepInfoLabel: UILabel!
    private var insuranceDealers: [InsuranceDealer] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        input.getDealers { [weak self] dealers in
            self?.insuranceDealers = dealers
        }
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("activate_product_activation_title", comment: "")
        productTitleLabel <~ Style.Label.primaryText
        stepInfoLabel <~ Style.Label.primaryText
        productTitleLabel.text = NSLocalizedString("activate_product_product_type", comment: "")
        stepInfoLabel.text = String(
            format: NSLocalizedString("activate_product_step", comment: ""),
            input.currentStepIndex, input.stepsCount
        )
		
		tableView.backgroundColor = .clear
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.showDealerWithId(insuranceDealers[indexPath.row].id)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        insuranceDealers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(InsuranceDealerCell.id)
        cell.configure(title: insuranceDealers[indexPath.row].title)
        return cell
    }
}
