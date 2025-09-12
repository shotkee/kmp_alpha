//
//  ICPassengersStepOneViewController.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 29.08.17.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ICPassengersStepOneViewController: ViewController, EventReportServiceDependency, UITableViewDataSource, UITableViewDelegate {
    var eventReportService: EventReportService!

    struct Input {
        var insurance: Insurance
        var insurerName: String
        var riskId: String?
    }

    var input: Input!

    var output: Risk? {
        didSet {
            nextButton.isEnabled = output != nil
        }
    }
    var onSelection: ((ICPassengersStepOneViewController) -> Void)?
    var onStoryboardSegue: ((UIStoryboardSegue, Risk, [RiskCategory]) -> Void)?

    private var risks: [Risk] = []
    private var categories: [RiskCategory] = []

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var validThruLabel: UILabel!
    @IBOutlet private var insuranceTitleLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var nextButton: RMRRedSubtitleButton!

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = AppLocale.currentLocale
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadData()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(closeTap))
        }
    }

    private func setupUI() {
        nextButton <~ Style.Button.ActionRed(title: NSLocalizedString("common_next", comment: ""))

        title = "Шаг 1 из 4"

        tableView.registerReusableCell(RiskTypeCell.cellId)
        tableView.registerReusableHeaderFooter(RMRTableSectionHeader.id)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 20
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.tableFooterView = UIView()
		
		validThruLabel <~ Style.Label.secondaryText
		insuranceTitleLabel <~ Style.Label.primaryHeadline2
		nameLabel <~ Style.Label.primaryText
    }

    private func loadData() {
        guard let input = input else { return }

        eventReportService.risks(insuranceId: input.insurance.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case.success(let response):
                    self.risks = response.risks
                    self.categories = response.riskCategories
                    self.updateUI()
                case .failure(let error):
                    self.processError(error)
            }
        }
    }

    private func updateUI() {
        insuranceTitleLabel.text = input.insurance.title
        nameLabel.text = input.insurerName

        let validThrough = dateFormatter.string(from: input.insurance.endDate)
        validThruLabel.text = "Действует до \(validThrough) г."

        nextButton.isEnabled = false

        if let riskId = input.riskId {
            output = risks.first { $0.id == riskId }
        }

        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let output = output else { return }

        onStoryboardSegue?(segue, output, categories)
    }

    @IBAction private func nextButtonTap() {
        onSelection?(self)
    }

    @objc private func closeTap() {
        dismiss(animated: true)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        risks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(RiskTypeCell.cellId, indexPath: indexPath)
        let risk = risks[indexPath.row]
        cell.risk = risk
        cell.marked = output == risk
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        output = risks[indexPath.row]

        tableView.indexPathsForVisibleRows?.forEach {
            if let cell = tableView.cellForRow(at: $0) as? RiskTypeCell {
                cell.marked = (indexPath == $0)
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooter(RMRTableSectionHeader.id)
        header.title = "Укажите какой страховой случай у Вас произошел"
        return header
    }
}
