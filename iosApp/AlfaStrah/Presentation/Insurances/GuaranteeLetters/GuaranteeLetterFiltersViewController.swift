//
//  GuaranteeLetterFiltersViewController.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 25.04.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

final class GuaranteeLetterFiltersViewController: ViewController, UITableViewDataSource, UITableViewDelegate
{
    struct Input {
        var activeFilters: [GuaranteeLetter.Status]
    }
    struct Output {
        var resetFilters: () -> Void
        var applyFilters: ([GuaranteeLetter.Status]) -> Void
    }
    var input: Input!
    var output: Output!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var resetFiltersButton: RoundEdgeButton!
    @IBOutlet private var applyFiltersButton: RoundEdgeButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        setup()
    }

    private func setup()
    {
		view.backgroundColor = .Background.backgroundContent
		title = NSLocalizedString("guarantee_letter_filters", comment: "")

        resetFiltersButton <~ Style.RoundedButton.redBordered
        resetFiltersButton.setTitle(
            NSLocalizedString("guarantee_letter_reset_filters", comment: ""),
            for: .normal
        )

        applyFiltersButton <~ Style.Button.ActionRedRounded(
            title: NSLocalizedString("guarantee_letter_apply_filters", comment: "")
        )

        input.activeFilters.forEach {
            tableView.selectRow(
                at: IndexPath(row: $0.rawValue, section: 0),
                animated: false,
                scrollPosition: .none
            )
        }
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        GuaranteeLetter.Status.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(GuaranteeLettersFilterCell.id, indexPath: indexPath)
        let filter = GuaranteeLetter.Status.allCases[safe: indexPath.row]
        if let filter = filter {
            cell.configure(title: Self.getFilterString(filter))
        }
        return cell
    }

    private static func getFilterString(_ filter: GuaranteeLetter.Status) -> String
    {
        switch filter {
            case .inactive:
                return NSLocalizedString("guarantee_letter_filters_show_expired", comment: "")
            case .active:
                return NSLocalizedString("guarantee_letter_filters_show_valid", comment: "")
        }
    }

    private var activeFilters: [GuaranteeLetter.Status]
    {
        tableView.indexPathsForSelectedRows?
            .compactMap({ GuaranteeLetter.Status.allCases[safe: $0.row] }) ?? []
    }

    @IBAction private func onResetFiltersButton()
    {
        output.resetFilters()
    }

    @IBAction private func onApplyFiltersButton()
    {
        output.applyFilters(activeFilters)
    }
}
