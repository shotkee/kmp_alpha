//
//  CommonCheckboxButton.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 02.06.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class CommonCheckboxButton: UIButton {
    // MARK: - UIButton and Instantiation
	enum Appearance {
		case checkbox
		case radiobutton
	}
	
	private var appearance: Appearance = .checkbox
	
    init() {
        super.init(frame: .zero)
        
        setup()
		update(with: appearance)
    }
	
	init(appearance: Appearance) {
		super.init(frame: .zero)
		
		setup()
		self.appearance = appearance
		update(with: appearance)
	}
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
		update(with: appearance)
    }
    
    override var intrinsicContentSize: CGSize {
        let side: CGFloat = 24
        return .init(
            width: side,
            height: side
        )
    }
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
	   let touchFrame = bounds.insetBy(dx: -20, dy: -20)

	   return touchFrame.contains(point)
	}
    
    // MARK: - Setup
    
    private func setup() {
        backgroundColor = .clear
    }
	
	private func update(with appearance: Appearance) {
		let emptyStateImage: UIImage = appearance == .checkbox
			? .Icons.emptyCheckbox.tintedImage(withColor: .Stroke.strokeBorder)
			: .Icons.emptyRadiobutton.tintedImage(withColor: .Stroke.strokeBorder)
		
		let selectedStateImage: UIImage = appearance == .checkbox
			? .Icons.tickInFilledRoundedBox.tintedImage(withColor: .Icons.iconAccent)
				.overlay(with: .Icons.checkboxBackground.tintedImage(withColor: .Icons.iconContrast))
			: .Icons.radiobutton.tintedImage(withColor: .Icons.iconAccent)
		
		let selectedDisabledStateImage: UIImage = appearance == .checkbox
			? .Icons.tickInFilledRoundedBox.tintedImage(withColor: .States.backgroundAccentDisabled)
				.overlay(with: .Icons.checkboxBackground.tintedImage(withColor: .Icons.iconTertiary))
			: .Icons.radiobutton.tintedImage(withColor: .States.backgroundAccentDisabled)
		
		let emptyDisabledStateImage: UIImage = appearance == .checkbox
			? .Icons.emptyCheckbox.tintedImage(withColor: .States.strokeDisabled)
			: .Icons.emptyRadiobutton.tintedImage(withColor: .States.strokeDisabled)
		
		setImage(emptyStateImage, for: .normal)
		setImage(selectedStateImage, for: .selected)
		setImage(selectedDisabledStateImage, for: [.selected, .disabled])
		setImage(emptyDisabledStateImage, for: [.disabled])
	}
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
		update(with: appearance)
    }
}
