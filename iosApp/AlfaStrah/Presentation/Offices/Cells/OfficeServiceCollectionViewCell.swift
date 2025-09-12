//
//  OfficeServiceCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Darya Viter on 17.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class OfficeServiceCollectionViewCell: UICollectionViewCell {
    static let id: Reusable<OfficeServiceCollectionViewCell> = .fromClass()
    var currentModelIndex: Int?
    private var chipView = ChipView()
    private var chipViewSize: CGSize { chipView.frame.size }

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    // MARK: Builders

    private func commonSetup() {
        contentView.addSubview(chipView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: chipView, in: contentView))
    }

    func configure(
        with title: String,
        isSelected: Bool,
        tapHandler: @escaping () -> Void
    ) {
        chipView.setTitle(title, for: .normal)
        chipView.isSelected = isSelected
        chipView.tapHandler = tapHandler
        chipView.sizeToFit()
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        layoutAttributes.size = chipViewSize
        return layoutAttributes
    }
}
