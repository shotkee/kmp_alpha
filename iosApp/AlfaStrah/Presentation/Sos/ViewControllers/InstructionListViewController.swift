//
//  InstructionListViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/29/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InstructionListViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    struct Input {
        let instructions: [Instruction]
    }

    struct Output {
        let details: (Instruction) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var nothingFoundLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        tableView.registerReusableCell(InstructionCell.id)
        nothingFoundLabel <~ Style.Label.primaryText
        nothingFoundLabel.text = NSLocalizedString("common_nothing_found", comment: "")
        nothingFoundLabel.isHidden = !input.instructions.isEmpty
    }

    // MARK: - UITableViewDataSource, UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.details(input.instructions[indexPath.row])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        input.instructions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(InstructionCell.id)
        cell.configure(instruction: input.instructions[indexPath.row])
        return cell
    }
}
