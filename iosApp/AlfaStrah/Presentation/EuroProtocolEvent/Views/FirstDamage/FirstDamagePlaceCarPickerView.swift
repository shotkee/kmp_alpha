//
//  FirstDamagePlaceCarPickerView.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 23.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class FirstDamagePlaceCarPickerView: FirstDamagePlaceBasePickerView<EuroProtocolCarScheme> {
	@IBOutlet private var carModelImageView: UIImageView!
	
    override var numberOfDirectionControls: Int { 14 }
    override var maxSimultaneouslySelectedDirections: Int { 2 }

	override func assignDirectionsToControls() {
        directionControls.forEach {
            switch $0.tag {
                case 1:
                    $0.direction = .downRight
                case 2, 3:
                    $0.direction = .down
                case 4:
                    $0.direction = .downLeft
                case 5, 6, 7:
                    $0.direction = .left
                case 8:
                    $0.direction = .upLeft
                case 9, 10:
                    $0.direction = .up
                case 11:
                    $0.direction = .upRight
                case 12, 13, 14:
                    $0.direction = .right
                default:
                    break
            }
        }
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		updateTheme()
	}
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		guard let image = UIImage(named: "carShape")?
			.tintedImage(withColor: .Icons.iconSecondary)
		else { return }
		
		carModelImageView?.image = image
	}
}
