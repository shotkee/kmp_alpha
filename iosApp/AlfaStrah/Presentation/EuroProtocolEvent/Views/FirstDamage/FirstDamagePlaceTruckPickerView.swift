//
//  FirstDamagePlaceTruckPickerView.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 23.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class FirstDamagePlaceTruckPickerView: FirstDamagePlaceBasePickerView<EuroProtocolTruckScheme> {
    override var numberOfDirectionControls: Int { 12 }
    override var maxSimultaneouslySelectedDirections: Int { 2 }

	@IBOutlet private var truckIModelImageView: UIImageView!
	
	override func assignDirectionsToControls() {
        directionControls.forEach {
            switch $0.tag {
                case 1:
                    $0.direction = .downRight
                case 2:
                    $0.direction = .down
                case 3:
                    $0.direction = .downLeft
                case 4, 5, 6:
                    $0.direction = .left
                case 7:
                    $0.direction = .upLeft
                case 8:
                    $0.direction = .up
                case 9:
                    $0.direction = .upRight
                case 10, 11, 12:
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
		guard let image = UIImage(named: "truckShape")?
			.tintedImage(withColor: .Icons.iconSecondary)
		else { return }
		
		truckIModelImageView?.image = image
	}
}
