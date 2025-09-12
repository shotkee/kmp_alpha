//
//  ClinicsCitiesListViewController.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 26/03/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

final class ClinicsCitiesListViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView(frame: .zero, style: .plain)

    struct Input {
        var cities: [CityWithMetro]
    }

    struct Output {
        var selectedCity: (CityWithMetro?) -> Void
    }

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        title = NSLocalizedString("clinics_cities_title", comment: "")
        view.addSubview(tableView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: tableView, in: view))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        input.cities.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let title = indexPath.row == 0
            ? NSLocalizedString("clinics_show_all_clinics", comment: "")
            : input.cities[indexPath.row - 1].title
        cell.textLabel?.text = title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let city = indexPath.row == 0 ? nil : input.cities[indexPath.row - 1]
        output.selectedCity(city)
    }
}
