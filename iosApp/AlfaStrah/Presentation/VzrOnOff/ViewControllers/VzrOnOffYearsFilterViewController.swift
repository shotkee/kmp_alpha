//
//  VzrOnOffYearsFilterViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11/12/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffYearsFilterViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    struct Input {
        let years: [Int]
    }

    struct Output {
        let selectYear: (Int) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var gradientView: UIView!
    @IBOutlet private var showButton: RoundEdgeButton!
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = NSLocalizedString("vzr_on_off_filters_title", comment: "")
        tableView.registerReusableCell(VzrOnOffYearsFilterCell.id)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 102
        tableView.rowHeight = UITableView.automaticDimension
        showButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        showButton.setTitle(NSLocalizedString("common_show", comment: ""), for: .normal)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor ]
        gradientView.layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
        updateUI()
    }

    @IBAction private func showTap(_ sender: UIButton) {
        guard
            let selectedIndex = tableView.indexPathForSelectedRow?.row,
            let year = input.years[safe: selectedIndex]
        else { return }

        output.selectYear(year)
    }

    private func updateUI() {
        showButton.isEnabled = tableView.indexPathForSelectedRow != nil
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndexPath = tableView.indexPathForSelectedRow, selectedIndexPath == indexPath {
            tableView.deselectRow(at: indexPath, animated: true)
            updateUI()
            return nil
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateUI()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        input.years.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(VzrOnOffYearsFilterCell.id)
        cell.configure(year: input.years[indexPath.row])
        return cell
    }
}
