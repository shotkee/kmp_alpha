//
//  ArchiveInsurancesListViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ArchiveInsurancesListViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    struct Input {
        var data: (_ completion: @escaping (Result<[GroupedInsurances], AlfastrahError>) -> Void) -> Void
        var timeLeftString: (Insurance, InsuranceCategory) -> String?
    }

    struct Output {
		var select: (Insurance, InsuranceCategory) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var tableView: UITableView!
    private let refreshControl: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .Background.backgroundContent

        title = NSLocalizedString("insurance_archive_list", comment: "")
        addZeroView()

		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 0
		}
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        refresh()
    }

    @objc private func refresh() {
        guard isViewLoaded else { return }

        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        input.data { [weak self] result in
            guard let self = self else { return }

            self.refreshControl.endRefreshing()
            self.updateData(result)
        }
    }

    private func updateData(_ data: Result<[GroupedInsurances], AlfastrahError>) {
        switch data {
            case .success(let insurances):
                sections = insurances
                let zeroViewModel = ZeroViewModel(
                    kind: .custom(
                        title: NSLocalizedString("zero_no_archived_policies", comment: ""),
                        message: NSLocalizedString("zero_no_archived_policies_descriptions", comment: ""),
                        iconKind: .search
                    )
                )
                zeroView?.update(viewModel: zeroViewModel)
                sections.isEmpty ? showZeroView() : hideZeroView()
            case .failure(let error):
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.refresh() }))
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
                processError(error)
        }
        tableView.reloadData()
    }

    private var sections: [GroupedInsurances] = []

    // MARK: - TableView data source & delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].insurances.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = sections[indexPath.section].category
        let insurance = sections[indexPath.section].insurances[indexPath.row]
        let cell = tableView.dequeueReusableCell(ActiveInsuranceCell.id)
        let expireString = input.timeLeftString(insurance, category)
        cell.set(title: insurance.title, hint: insurance.insuredObjectTitle, warning: expireString)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = sections[indexPath.section].category
        let insurance = sections[indexPath.section].insurances[indexPath.row]
        output.select(insurance, category)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].category.title
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { fatalError("Invalid header view") }

        if let titleLabel = header.textLabel {
            titleLabel <~ Style.Label.secondaryText
        }
        header.backgroundView?.backgroundColor = Style.Color.alternateBackground
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
}
