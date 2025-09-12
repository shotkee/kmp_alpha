//
//  ScrollHorizontalCollectionCell.swift
//  AlfaStrah
//
//  Created by mac on 27.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy


class ScrollHorizontalCollectionCell: UICollectionViewCell {
    static let id: Reusable<ScrollHorizontalCollectionCell> = .fromClass()
    private var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundView?.isOpaque = true
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonSetup() {
        contentView.clipsToBounds = false
        contentView.layer.cornerRadius = 15
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = Style.Color.Palette.lightGray.cgColor
        
        titleLabel <~ Style.Label.body
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: titleLabel,
                in: contentView,
                margins: .init(top: 6, left: 15, bottom: 6, right: 15)
            )
        )
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderColor = isSelected
                ? UIColor.clear.cgColor
                : Style.Color.Palette.lightGray.cgColor
            contentView.backgroundColor = isSelected
                ? Style.Color.Palette.red
                : .white
            titleLabel.textColor = isSelected
                ? .white
                : Style.Color.Palette.black
        }
    }

    func set(
        title: String
    ) {
        titleLabel.text = title
    }
}
