//
//  CityCell.swift
//  AlfaStrah
//
//  Created by Darya Viter on 13.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class CityCell: UITableViewCell {
    static let id: Reusable<CityCell> = .fromNib()

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var checkMarkImageView: UIImageView!
    @IBOutlet private var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel <~ Style.Label.primaryText
        separatorView.backgroundColor = Style.Color.Palette.whiteGray
        selectionStyle = .none
    }

    func set(city: City, isSelected: Bool) {
        titleLabel.text = city.title
        checkMarkImageView.isHidden = !isSelected
    }
}
