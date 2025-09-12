//
//  TripPointsPopoverController.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 08/12/2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class TripPointsPopoverController: UITableViewController, UIPopoverPresentationControllerDelegate {
    private let cellId = "InsuranceFieldCell"
    private var viewModels: [InsuranceFieldViewModel] = []

    @objc convenience init(points: [String]) {
        self.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self

        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = false
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)

        configureModels(points: points)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        preferredContentSize.height = 10 + 64 * CGFloat(viewModels.count)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // We want to make it work on iphone
        .none
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? InsuranceFieldCell else {
            fatalError("Invalid cel")
        }
        cell.configureForModel(viewModels[indexPath.row])
        return cell
    }

    // Privates

    private func configureModels(points: [String]) {
        viewModels = points.enumerated().map { index, point in
            InsuranceFieldViewModel(
                insuranceField: InfoField(
                    type: .text,
                    title: String(format: "%d промежуточная точка", index + 1),
                    text: point,
                    coordinate: nil
                ),
                tapHandler: nil
            )
        }
    }
}
