//
//  NotificationToHistoryView.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class NotificationToHistoryView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var mainTextLabel: UILabel!
    private var tapView: (() -> Void)?

    @IBAction private func onViewClick(_ sender: Any) {
        tapView?()
    }

    func set(title: String, subtitle: String, action: @escaping () -> Void) {
        tapView = action
        titleLabel.text = title
        mainTextLabel.text = subtitle
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        titleLabel <~ Style.Label.primaryHeadline2
        mainTextLabel <~ Style.Label.secondaryText
    }
}
