//
//  MetroStationCell.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 27/03/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class MetroStationCell: UITableViewCell {
	static let id: Reusable<MetroStationCell> = .fromClass()

    var station: MetroStation? {
        didSet {
            titleLabel.text = station?.title
            //numClinicsLabel.text = station.map { "\($0.clinics.count)" }
        }
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var numClinicsLabel: UILabel!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		titleLabel <~ Style.Label.primaryText
		numClinicsLabel <~ Style.Label.accentText
	}
}
