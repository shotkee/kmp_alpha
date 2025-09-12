//
//  ClinicsMetroStationsViewController.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 27/03/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

final class ClinicsMetroStationsViewController: UITableViewController {
    struct Input {
        var metroStations: () -> [MetroStation]
    }

    struct Output {
        var station: (MetroStation) -> Void
    }

    struct Notify {
        var changed: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let `self` = self, self.isViewLoaded else { return }

            self.update()
        }
    )

    private struct Section {
        var title: String
        var stations: [MetroStation]
    }

    private var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }

    private func update() {
        buildAlphabeticSections()
        tableView.reloadData()
    }

    private func buildAlphabeticSections() {
        var sections: [Section] = []

        for station in input.metroStations().sorted(by: { $0.title < $1.title }) {
            let firstLetter = String(station.title.prefix(1))
            if let index = sections.firstIndex(where: { $0.title == firstLetter }) {
                var section = sections[index]
                section.stations.append(station)
                sections[index] = section
            } else {
                let newSection = Section(title: firstLetter, stations: [ station ])
                sections.append(newSection)
            }
        }

        self.sections = sections
    }

    /// Segues for the controller.
    private enum Segue {
        static let showClinicsForMetroStation = "showClinicsForMetroStation"
    }

    // MARK: - Table view data source and delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].stations.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sections.map { $0.title }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(MetroStationCell.id, indexPath: indexPath)
        cell.station = sections[indexPath.section].stations[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        let station = section.stations[indexPath.row]
        output.station(station)
    }
}
