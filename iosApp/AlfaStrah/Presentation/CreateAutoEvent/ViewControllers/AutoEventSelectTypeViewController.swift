//
//  AutoEventSelectTypeViewController
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 22.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class AutoEventSelectTypeViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    struct Input {
		var isDemo: Bool
        var insurance: Insurance
    }

    struct Output {
        var select: (AutoEventCaseType) -> Void
        var selectOffices: (Insurance.Kind) -> Void
		var demo: () -> Void
    }

    var input: Input!
    var output: Output!

    private var model: [AutoEventCaseType] = [
        .competentAuthoritiesInvolved,
        .executedByTrafficAccidentParticipants,
        .other
    ]

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = input.insurance.title
		
		tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        let insuredObjectLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 48))
        insuredObjectLabel.textAlignment = .center
        insuredObjectLabel <~ Style.Label.primaryText
        insuredObjectLabel.text = input.insurance.description
        tableView.tableHeaderView = insuredObjectLabel
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = model[indexPath.row]
        let cell = tableView.dequeueReusableCell(OSAGOCaseTypeCell.reusable)
        cell.set(title: content.title(insuranceKind: input.insurance.type), hint: content.hint(insuranceKind: input.insurance.type))
		
		cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
		
        let selectedCase = model[indexPath.row]
        switch selectedCase {
			case .competentAuthoritiesInvolved:
				output.select(selectedCase)
			
			case .executedByTrafficAccidentParticipants:
				input.isDemo 
					? output.demo()
					: output.select(selectedCase)
            case .other:
                let insuranceKind: Insurance.Kind?
                switch input.insurance.type {
                    case .kasko, .osago:
                        insuranceKind = input.insurance.type
                    case .unknown, .dms, .vzr, .property, .passengers, .life, .accident, .vzrOnOff, .flatOnOff:
                        insuranceKind = nil
                }
                insuranceKind.map { self.output.selectOffices($0) }
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
