//
//  ChipView.swift
//  AlfaStrah
//
//  Created by Darya Viter on 16.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

/// В дизайн-системе – один из вариантов SystemLabel.
/// [Figma](https://www.figma.com/file/tKxXq2M8ztUCQdnAq8TguY/Alfastrahovanie-Design-System?node-id=3179%3A14988)
class ChipView: UIButton {
    // MARK: Parameters
    
    private let borderWidth: CGFloat = 1
    private let cornerRadius: CGFloat = 15
    private let defaultHeight: CGFloat = 30
    private let defaultContentEdgeInsets: UIEdgeInsets = .init(top: 6, left: 15, bottom: 6, right: 15)
    private var titleFont: UIFont = Style.Font.text
    
    var tapHandler: (() -> Void)?
    
    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateUI()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Lifecicle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonSetup()
    }
    
    open override var intrinsicContentSize: CGSize {
        CGSize(width: .zero, height: defaultHeight)
    }
    
    // MARK: Builders
    private func commonSetup() {
        titleLabel?.font = titleFont
        layer.borderWidth = borderWidth
        contentEdgeInsets = defaultContentEdgeInsets
        
        addTarget(self, action: #selector(viewTap), for: .touchUpInside)
        layer.cornerRadius = cornerRadius
        
        updateUI()
    }
    
    private func updateUI() {
        switch (isEnabled, isHighlighted) {
            case (_, true): // Pressed
				backgroundColor = isSelected ? .Background.backgroundAccent : .Background.backgroundContent
				layer.borderColor = isSelected ? UIColor.Background.backgroundAccent.cgColor : UIColor.Stroke.strokeBorder.cgColor
                setTitleColor(
					isSelected ? .Text.textContrast : .Text.textPrimary,
                    for: .highlighted
                )
            case (false, _): // Disabled
				backgroundColor = isSelected ? .States.backgroundAccentDisabled : .Background.backgroundContent
				layer.borderColor = isSelected ? UIColor.States.backgroundAccentDisabled.cgColor : UIColor.Background.backgroundContent.cgColor
				setTitleColor(.Text.textSecondary, for: .disabled)
            default: // Normal
                backgroundColor = isSelected ? .Background.backgroundAccent : .clear
                layer.borderColor = isSelected ? UIColor.clear.cgColor : UIColor.Stroke.strokeBorder.cgColor
                setTitleColor(
                    isSelected ? .Text.textContrast : .Text.textPrimary,
                    for: .normal
                )
        }
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateUI()
	}
    
    @objc private func viewTap() {
        isSelected.toggle()
        updateUI()
        tapHandler?()
    }
}
