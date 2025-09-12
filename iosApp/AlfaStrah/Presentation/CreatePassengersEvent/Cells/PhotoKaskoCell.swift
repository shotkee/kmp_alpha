//
//  PhotoKaskoCell.swift
//  AlfaStrah
//
//  Created by Olga Vorona on 22/01/16.
//  Copyright © 2016 RedMadRobot. All rights reserved.
//

import UIKit

class PhotoKaskoCell: PhotoCollectionViewCell {
    @IBOutlet private var selectedImage: UIImageView!

    @objc var isMarked: Bool {
        get {
            !selectedImage.isHidden
        }
        set {
            selectedImage.isHidden = !newValue
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        selectedImage.isHidden = true
    }
}
