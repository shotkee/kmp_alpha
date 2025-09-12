//
//  ActiveInsuranceErrorView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/9/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class ActiveInsuranceErrorView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var reloadButton: RoundEdgeButton!

    private var reloadAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("kasko_on_off_active_trip_error_view_title", comment: "")
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.text = NSLocalizedString("kasko_on_off_active_trip_error_view_description", comment: "")
        reloadButton <~ Style.RoundedButton.redBordered
        reloadButton.setTitle(NSLocalizedString("common_reload", comment: ""), for: .normal)
    }

    func setReloadAction(_ action: (() -> Void)?) {
        reloadAction = action
    }

    @IBAction private func reloadTap(_ sender: UIButton) {
        reloadAction?()
    }
}
