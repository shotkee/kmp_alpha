//
//  ICPassengersPopoverController.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 17/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class ICPassengersPopoverController: UITableViewController, UIPopoverPresentationControllerDelegate {
    var selectedTitleIndex: ((Int) -> Void)?

    private var titles: [String] = []

    @objc convenience init(titles: [String]) {
        self.init(nibName: nil, bundle: nil)

        self.titles = titles

        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self

        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        preferredContentSize.height = 44 * CGFloat(titles.count)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // We want to make it work on iphone
        .none
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .default, reuseIdentifier: cellId)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        dismiss(animated: true) { [weak self] in
            self?.selectedTitleIndex?(indexPath.row)
        }
    }
}
