//
//  VzrOnOffYearsFilterCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11/12/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class VzrOnOffYearsFilterCell: UITableViewCell {
    static let id: Reusable<VzrOnOffYearsFilterCell> = .fromClass()

    private let yearLabel: UILabel = .init()
    private let checkmarkImageView: UIImageView = .init(image: UIImage(named: "icon-checkmark"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        yearLabel <~ Style.Label.primaryText
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(yearLabel)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkmarkImageView)
        let hairlineView = HairLineView()
        hairlineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hairlineView)
        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            yearLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 21),
            yearLabel.bottomAnchor.constraint(equalTo: hairlineView.topAnchor, constant: -21),
            hairlineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hairlineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hairlineView.heightAnchor.constraint(equalToConstant: 1),
            hairlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            checkmarkImageView.leadingAnchor.constraint(greaterThanOrEqualTo: yearLabel.trailingAnchor, constant: 18)
        ])
    }

    func configure(year: Int) {
        yearLabel.text = String(format: NSLocalizedString("common_with_full_year", comment: ""), "\(year)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        checkmarkImageView.alpha = selected ? 1 : 0
    }
}
