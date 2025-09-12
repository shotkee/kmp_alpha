//
//  VzrOnOffHistoryHeaderView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/18/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffHistoryHeaderView: UIView {
    @IBOutlet private var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        label <~ Style.Label.primaryHeadline1
    }

    func set(year: Int) {
        let format = NSLocalizedString("vzr_purchase_list_section_title", comment: "")
        label.text = String(format: format, "\(year)")
    }
}
