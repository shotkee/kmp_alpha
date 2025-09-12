//
//  InsuranceEventReportsListViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsuranceEventReportsListViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    typealias EventReportKind = InsuranceEventFlow.EventReportKind
    typealias DraftKind = InsuranceEventFlow.DraftKind

    struct Input {
        var data: (_ completion: @escaping (Result<[EventReportKind], AlfastrahError>) -> Void) -> Void
        var draft: () -> DraftKind?
    }

    struct Output {
        var selectEvent: (EventReportKind) -> Void
        var selectDraft: (DraftKind) -> Void
        var deleteDraft: (DraftKind) -> Void
    }

    struct Notify {
        var draftUpdated: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        draftUpdated: { [weak self] in
            guard let self = self, self.isViewLoaded else { return }

            self.refresh()
        }
    )

    @IBOutlet private var tableView: UITableView!
    private let refreshControl: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .Background.backgroundContent
	
        addZeroView()

		tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 102
        tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        refresh()

        // Harcoded table view inset for action button (66 = 16 bottom inset from safe areа + 48 button height + extra 2 points).
        // This is needed because there is a layout bug in iOS<14 with stack view and table view clip to bounds = false
        tableView.contentInset = .init(top: 9, left: 0, bottom: 66, right: 0)
    }

    @objc private func refresh() {
        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        input.data { [weak self] result in
            guard let self = self else { return }

            self.refreshControl.endRefreshing()
            self.updateData(result)
        }
    }

    private func updateData(_ data: Result<[EventReportKind], AlfastrahError>) {
        switch data {
            case .success(let events):
                hideZeroView()
                var cells: [TableCells] = []
                input.draft().map(TableCells.draft).map { cells.append($0) }
                cells.append(contentsOf: events.map(TableCells.event))
                self.cells = cells
                if cells.isEmpty {
                    showZeroView()
                    let zeroViewModel = ZeroViewModel(
                        kind: .custom(
                            title: NSLocalizedString("zero_no_events", comment: ""),
                            message: nil,
                            iconKind: .search
                        )
                    )
                    zeroView?.update(viewModel: zeroViewModel)
                } else {
                    hideZeroView()
            }
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

    private enum TableCells {
        case draft(DraftKind)
        case event(EventReportKind)

    }
    private var cells: [TableCells] = []

    // MARK: - TableView data source & delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(InsuranceEventReportCell.id)
        switch cells[indexPath.row] {
            case .draft(.passengerDraft(let draft)):
                cell.set(
                    title: NSLocalizedString("passengers_draft_title", comment: ""),
                    description: NSLocalizedString("draft_title", comment: ""),
                    date: AppLocale.shortDateString(draft.date),
                    eventNumber: ""
                )
            case .draft(.autoDraft(let draft)):
                cell.set(
                    title: NSLocalizedString("auto_draft_title", comment: ""),
                    description: NSLocalizedString("draft_title", comment: ""),
                    date: AppLocale.shortDateString(draft.lastModify),
                    eventNumber: ""
                )
            case .event(.passenger(let event)):
                cell.set(
                    title: event.eventType.title,
                    description: event.number,
                    date: AppLocale.shortDateString(event.createDate),
                    eventNumber: event.number
                )
            case .event(.auto(let event)):
                cell.set(
                    title: event.eventType.title,
                    description: event.currentStatus?.title ?? "",
                    date: AppLocale.shortDateString(event.displayDate),
                    eventNumber: event.number
                )
            case .event(.accident(let event)):
                cell.set(
                    title: event.event,
                    description: event.status,
                    date: AppLocale.shortDateString(event.createDate),
                    eventNumber: event.number
                )
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch cells[indexPath.row] {
            case .draft(let draftKind):
                output.selectDraft(draftKind)
            case .event(.passenger(let event)):
                output.selectEvent(.passenger(event))
            case .event(.auto(let event)):
                output.selectEvent(.auto(event))
            case .event(.accident(let event)):
                output.selectEvent(.accident(event))
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch cells[indexPath.row] {
            case .draft:
                return true
            case .event:
                return false
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = cells.remove(at: indexPath.row)
            switch cell {
                case .draft(let draftKind):
                    tableView.deleteRows(at: [ indexPath ], with: .automatic)
                    output.deleteDraft(draftKind)
                case .event:
                    break
            }
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		tableView.reloadData()
	}
}
