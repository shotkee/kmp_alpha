//
//  InsuranceFlatOnOffErrorView.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 01.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class InsuranceFlatOnOffErrorView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var refreshButton: RoundEdgeButton!

    enum Mode {
        case basic
        case custom(_ title: String, _ subtitle: String)
    }

    private var refreshAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        titleLabel <~ Style.Label.primaryHeadline1
        subtitleLabel <~ Style.Label.secondaryText
        refreshButton <~ Style.RoundedButton.redBordered
        refreshButton.setTitle(NSLocalizedString("common_reload", comment: ""), for: .normal)
    }

    func configure(mode: Mode, refreshAction: @escaping () -> Void) {
        switch mode {
            case .basic:
                titleLabel.text = NSLocalizedString("flat_on_off_error_title", comment: "")
                subtitleLabel.text = NSLocalizedString("flat_on_off_error_subtitle", comment: "")
            case .custom(let title, let subtitle):
                titleLabel.text = title
                subtitleLabel.text = subtitle
        }
        self.refreshAction = refreshAction
    }

    @IBAction private func refresh() {
        refreshAction?()
    }
}
