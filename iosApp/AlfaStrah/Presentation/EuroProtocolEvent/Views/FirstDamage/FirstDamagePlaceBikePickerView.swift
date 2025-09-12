//
//  FirstDamagePlaceBikePickerView.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 23.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class FirstDamagePlaceBikePickerView: FirstDamagePlaceBasePickerView<EuroProtocolBikeScheme> {
    override var numberOfDirectionControls: Int { 4 }
    override var maxSimultaneouslySelectedDirections: Int { 1 }

	@IBOutlet private var bikeModelImageView: UIImageView!
	
	override func assignDirectionsToControls() {
        directionControls.forEach {
            switch $0.tag {
                case 1:
                    $0.direction = .down
                case 2:
                    $0.direction = .left
                case 3:
                    $0.direction = .up
                case 4:
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
		guard let image = UIImage(named: "bikeShape")?
			.tintedImage(withColor: .Icons.iconSecondary)
		else { return }
		
		bikeModelImageView?.image = image
	}
}
