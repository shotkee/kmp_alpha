//
//  FilterTableViewCell.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 02/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class FilterTableViewCell: UITableViewCell {
    static var id: Reusable<FilterTableViewCell> = .fromClass()
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var separator: UILabel!
    @IBOutlet private var checkmarkImageView: UIImageView!

    private var showSeparator: Bool = true {
        didSet {
            separator.isHidden = !showSeparator
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
        setupStyle()
    }

    func confugure(title: String, showSeporator: Bool) {
        self.showSeparator = showSeporator
        titleLabel.text = title
    }

    func toggleSelection(_ isSelected: Bool) {
        checkmarkImageView.isHidden = !isSelected
    }

    private func setupStyle() {
		separator.backgroundColor = .Stroke.divider
		
        titleLabel <~ Style.Label.primaryText
		checkmarkImageView.image = .Icons.tick.resized(newWidth: 16)?.tintedImage(withColor: .Icons.iconAccent)
    }
}
