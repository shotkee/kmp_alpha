//
//  AddDocumentCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 05.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class AddDocumentCollectionViewCell: UICollectionViewCell {
    static let id: Reusable<AddDocumentCollectionViewCell> = .fromClass()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
 
    private func setupUI() {
        let containerView = UIView()
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
		containerView.backgroundColor = .Background.backgroundTertiary
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
		let imageView = UIImageView(image: .Icons.plus.tintedImage(withColor: .Icons.iconMedium))
        imageView.tintColor = .gray
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: containerView,
                in: contentView,
                margins: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 6)
            ) + [
                imageView.heightAnchor.constraint(equalToConstant: 16),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1),
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ]
        )
    }
}
