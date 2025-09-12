//
//  InsuranceActionCell.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 03.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsuranceActionCell: UITableViewCell {
    @IBOutlet private var redDotView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!

    static let id: Reusable<InsuranceActionCell> = .fromNib()

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .Background.backgroundContent
        
        titleLabel <~ Style.Label.primaryText
        redDotView.backgroundColor = .Icons.iconAccent
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        iconImageView.image = nil
    }

    func configure(title: String, icon: UIImage?, showRedDot: Bool) {
        titleLabel.text = title
        iconImageView.image = icon?.tintedImage(withColor: .Icons.iconAccent)
        redDotView.isHidden = !showRedDot
    }
}
