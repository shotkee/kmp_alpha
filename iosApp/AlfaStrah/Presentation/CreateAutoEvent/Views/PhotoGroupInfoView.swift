//
//  PhotoGroupInfoView.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 07.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class PhotoGroupInfoView: UIView {
    @IBOutlet private var photoCountLabel: UILabel!
    @IBOutlet private var cameraImageView: UIImageView!

    func set(photoCount: String, isReady: Bool) {
        photoCountLabel.text = photoCount
        cameraImageView.image = isReady ? UIImage(named: "ico-camera-ok") : UIImage(named: "red_camera")
        cameraImageView.tintColor = isReady
            ? Style.Color.Palette.green
            : Style.Color.Palette.gray
    }
}
