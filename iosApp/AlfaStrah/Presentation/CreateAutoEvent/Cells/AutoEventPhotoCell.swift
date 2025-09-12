//
//  AutoEventPhotoCell
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class AutoEventPhotoCell: UICollectionViewCell {
    static let id: Reusable<AutoEventPhotoCell> = .fromNib()

    // swiftlint:disable:next private_outlet
    @IBOutlet private(set) var photoView: UIImageView!
    @IBOutlet private var selectedImage: UIImageView!

    var isMarked: Bool {
        get {
            !selectedImage.isHidden
        }
        set {
            selectedImage.isHidden = !newValue
        }
    }

    var photo: UIImage? {
        get {
            photoView.image
        }
        set {
            photoView.image = newValue
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        photo = nil
        selectedImage.isHidden = true
    }
}
