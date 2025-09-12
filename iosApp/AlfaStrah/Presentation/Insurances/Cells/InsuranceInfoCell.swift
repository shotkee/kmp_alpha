//
//  InsuranceInfoCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 14/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsuranceInfoCell: UITableViewCell {
    static let id: Reusable<InsuranceInfoCell> = .fromNib()

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!

    enum Kind {
        case text
        case link
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel <~ Style.Label.secondaryText
        subtitleLabel <~ Style.Label.primaryHeadline1
        
        contentView.backgroundColor = .Background.backgroundContent
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        subtitleLabel.text = ""
        iconView.image = nil
    }

    func set(
        title: String,
        text: String,
        kind: Kind,
        icon: UIImage?,
        iconTintColor: UIColor?
    ) {
        titleLabel.text = title
        subtitleLabel.text = text
        
        iconView.isHidden = icon == nil
        
        switch kind {
            case .text:
                subtitleLabel <~ Style.Label.primaryHeadline1
            case .link:
                subtitleLabel <~ Style.Label.linkHeadline1
        }
        
        if let icon, let iconTintColor {
            iconView.image = icon.tintedImage(withColor: iconTintColor)
        }
    }
}
