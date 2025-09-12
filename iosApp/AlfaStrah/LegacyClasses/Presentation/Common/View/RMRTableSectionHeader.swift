//
//  RMRTableSectionHeader
//  AlfaStrah
//
// Created by Roman Churkin on 23/07/15.
// Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class RMRTableSectionHeader: UITableViewHeaderFooterView {
    static let id: Reusable<RMRTableSectionHeader> = .fromNib()

    @IBOutlet private var titleLabel: UILabel!

    @objc var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    // MARK: - Конструктор

    @objc class func tableSectionHeader(title: String?) -> RMRTableSectionHeader {
        let header = RMRTableSectionHeader.fromNib()
        header.title = title
        return header
    }
}
