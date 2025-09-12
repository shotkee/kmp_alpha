//
//  ICPassengersStepFourViewController.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 21/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ICPassengersStepFourViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    struct Input {
        var risk: Risk
        var eventReportId: String
        var photoSteps: [AutoPhotoStep]
    }

    struct Output {
        var addPhoto: (AutoPhotoStep) -> Void
        var sendFiles: () -> Void
        var goBack: () -> Void
    }

    struct Notify {
        var photosUpdated: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        photosUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateUI()
    }

    private func setupUI() {
        nextButton <~ Style.Button.ActionRed(title: NSLocalizedString("common_next", comment: ""))
        self.title = "Шаг 4 из 4"

        tableView.registerReusableHeaderFooter(RMRTableSectionHeader.id)
        tableView.registerReusableCell(RiskDocumentCell.id)
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 20
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.tableFooterView = UIView()
    }

    private func updateUI() {
        nextButton.isEnabled = input.photoSteps.allSatisfy { $0.isReady }
        tableView.reloadData()
    }

    @IBAction private func proceedToNextStep() {
        output.sendFiles()
    }

    @IBAction private func backAction() {
        view.endEditing(false)
        output.goBack()
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return input.photoSteps.count
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooter(RMRTableSectionHeader.id)
        if section == 0 {
            header.title = "Список скан-копий документов или их фотографий в хорошем качестве, " +
                "которые необходимо прикрепить к уведомлению."
        } else {
            header.title = "Страховщик имеет право запросить дополнительные документы в зависимости от условий Вашего полиса, " +
                "имеющие отношения  к страховому случаю."
        }
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = "riskTypeCellId"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? {
                let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
                cell.textLabel?.text = input.risk.title
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                cell.selectionStyle = .none
                return cell
            }()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(RiskDocumentCell.id, indexPath: indexPath)
            let step = input.photoSteps[indexPath.row]
            cell.title = step.title
            cell.subtitle = step.hint
            switch step.status {
                case .ready:
                    cell.status = .ready
                case .required:
                    cell.status = .required
                case .optional:
                    cell.status = .optional
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        output.addPhoto(input.photoSteps[indexPath.row])
    }
}
