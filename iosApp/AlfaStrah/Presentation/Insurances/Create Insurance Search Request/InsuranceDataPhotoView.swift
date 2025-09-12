//
//  InsuranceDataPhotoView.swift
//  AlfaStrah
//
//  Created by Станислав Старжевский on 04.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class InsuranceDataPhotoView: UIView {
    @IBOutlet private var cameraButton: UIButton!
	@IBOutlet private var titleLabel: UILabel! {
		didSet {
			titleLabel <~ Style.Label.primaryText
		}
	}
	@IBOutlet private var descriptionLabel: UILabel! {
		didSet {
			descriptionLabel <~ Style.Label.secondaryCaption1
		}
	}
	
	func set(hasPhoto: Bool) {
        if hasPhoto {
			cameraButton.tintColor = .Icons.iconAccent
        } else {
			cameraButton.tintColor = .Icons.iconSecondary
        }
    }
}
