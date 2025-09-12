//
//  DesignSystemComponentsList
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class DesignSystemComponentsList: ViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView: UITableView = .init()
    private let cellIdentifier: String = "Identifier"

    struct Input {
        let componentsSections: [DesignSystemFlow.ComponentsSection]
        let version: String
    }

    struct Output {
        let componentTap: (DesignSystemComponent) -> Void
    }

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Design System v.\(input.version)"
        view.addSubview(tableView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: tableView, in: view))

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        input.componentsSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        input.componentsSections[section].components.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        input.componentsSections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let title = input.componentsSections[indexPath.section].components[indexPath.row].title

        if #available(iOS 14.0, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = title
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = title
        }

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.componentTap(input.componentsSections[indexPath.section].components[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
