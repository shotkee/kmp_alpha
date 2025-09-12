//
//  PhotoCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Roman Churkin on 15/10/15.
//  Copyright © 2015 RedMadRobot. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @objc var photo: UIImage? {
        get {
            photoView.image
        }
        set {
            photoView.image = newValue
        }
    }

    @objc var tint: UIColor? {
        didSet {
            photoIcon.tintColor = tintColor
            photoView.backgroundColor = tintColor?.withAlphaComponent(0.3)
        }
    }

    @IBOutlet private var photoView: UIImageView!
    @IBOutlet private var photoIcon: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        photo = nil
    }
}
