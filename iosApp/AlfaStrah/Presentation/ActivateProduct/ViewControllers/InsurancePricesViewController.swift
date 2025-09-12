//
//  InsurancePricesViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/24/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsurancePricesViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    struct Input {
        let prices: (_ completion: @escaping ([Money]) -> Void) -> Void
    }

    struct Output {
        let selectPrice: (Money) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var tableView: UITableView!
    private var prices: [Money] = [] {
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

        input.prices { [weak self] prices in
            self?.prices = prices
        }
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
		tableView.backgroundColor = .clear
        tableView.registerReusableCell(PriceCell.id)
    }

    // MARK: - UITableViewDataSource, UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        prices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(PriceCell.id)
        cell.awakeFromNib()
        let priceString = AppLocale.price(from: NSNumber(value: prices[indexPath.row].amount / 100))
        cell.setPrice(priceString)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.selectPrice(prices[indexPath.row])
    }
}
