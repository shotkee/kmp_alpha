//
//  RenewInfoTableViewCell.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 12.09.17.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

protocol RenewInfoTableViewCell {
    func set(infoTitle: String, infoValue: String)
}

class AlfaImportantInfoTableViewCell: UITableViewCell, RenewInfoTableViewCell {
    static let reusable: Reusable<AlfaImportantInfoTableViewCell> = .fromClass()

    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var infoTitleLabel: UILabel!
		
	private func setupUI() {
		clearStyle()
		
		infoTitleLabel <~ Style.Label.secondaryText
		infoLabel <~ Style.Label.primaryHeadline1
	}

    func set(infoTitle: String, infoValue: String) {
        infoLabel.text = infoValue
        infoTitleLabel.text = infoTitle
		
		setupUI()
    }
}

class AlfaCommonInfoTableViewCell: UITableViewCell, RenewInfoTableViewCell {
    static let reusable: Reusable<AlfaCommonInfoTableViewCell> = .fromClass()

    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var infoTitleLabel: UILabel!
		
	private func setupUI() {
		clearStyle()
		
		infoTitleLabel <~ Style.Label.secondaryText
		infoLabel <~ Style.Label.primaryHeadline1
	}

    func set(infoTitle: String, infoValue: String) {
        infoLabel.text = infoValue
        infoTitleLabel.text = infoTitle
		
		setupUI()
    }
}

class AlfaPropertyListTableViewCell: UITableViewCell, RenewInfoTableViewCell {
    static let reusable: Reusable<AlfaPropertyListTableViewCell> = .fromClass()

    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var infoTitleLabel: UILabel!
		
	private func setupUI() {
		clearStyle()
		
		infoTitleLabel <~ Style.Label.secondaryText
		infoLabel <~ Style.Label.primaryHeadline1
	}

    func set(infoTitle: String, infoValue: String) {
        infoLabel.text = infoValue
        infoTitleLabel.text = infoTitle
		
		setupUI()
    }
}
