//
//  InstructionCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/29/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InstructionCell: UITableViewCell {
    private lazy var instructionView: InstructionView = .fromNib()
    static let id: Reusable<InstructionCell> = .fromClass()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        instructionView.title = nil
        instructionView.details = nil
    }

    private func setupUI() {
        contentView.addSubview(instructionView)
		clearStyle()
        instructionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: instructionView, in: contentView))
        NSLayoutConstraint.fixHeight(view: instructionView, relation: .greaterThanOrEqual, constant: 64)
    }

    func configure(instruction: Instruction) {
        instructionView.title = instruction.title
        instructionView.details = instruction.shortDescription
    }
}
