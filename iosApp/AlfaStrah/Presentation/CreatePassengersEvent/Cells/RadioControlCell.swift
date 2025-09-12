//
//  RadioControlCell.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 12/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class RadioControlCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    static let id: Reusable<RadioControlCell> = .fromNib()

    var titles: [String] = [] {
        didSet {
            tableView.reloadData()
            heightConstraint.constant = intrinsicContentSize.height
        }
    }
    var selectedIndex: Int?
    var selectionChanged: ((Int) -> Void)?

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var heightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        tableView.registerReusableCell(RadioControlElementCell.cellId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70.0
    }

    override var intrinsicContentSize: CGSize {
        let height: CGFloat = (0 ... tableView.numberOfRows(inSection: 0)).reduce(0) {
            $0 + tableView.rectForRow(at: IndexPath(row: $1, section: 0)).height
        }
        return CGSize(width: bounds.width, height: height)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(RadioControlElementCell.cellId, indexPath: indexPath)
        cell.title = titles[indexPath.row]
        cell.marked = selectedIndex.map { $0 == indexPath.row } ?? false
        cell.separatorInset.left = indexPath.row < (tableView.numberOfRows(inSection: indexPath.section) - 1)
            ? 16
            : 0
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        selectionChanged?(indexPath.row)
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
}
