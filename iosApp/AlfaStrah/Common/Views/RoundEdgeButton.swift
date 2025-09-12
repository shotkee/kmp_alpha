//
//  RoundEdgeButton.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 12/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

@IBDesignable
class RoundEdgeButton: UIButton {
    private var normalBorderColor: UIColor?
    private var highlightedBorderColor: UIColor?
    private var disabledBorderColor: UIColor?

    var buttonConfiguration: Style.RoundedButton.ButtonConfiguration?
	var action: (() -> Void)?
    
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
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            layer.borderColor.map(UIColor.init)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var roundCoefficient: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
        updateUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        updateUI()
    }

    private func setupUI() {
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
		setupAction()
    }
	
	private func setupAction()
	{
		addTarget(
			self,
			action: #selector(onTap),
			for: .touchUpInside
		)
	}
	
	@objc private func onTap()
	{
		action?()
	}

    private func updateUI() {
        switch (isEnabled, isHighlighted) {
            case (true, false):
                normalBorderColor.map { layer.borderColor = $0.cgColor }
            case (true, true):
                highlightedBorderColor.map { layer.borderColor = $0.cgColor }
            case (false, _):
                disabledBorderColor.map { layer.borderColor = $0.cgColor }
        }
    }

    override var bounds: CGRect{
        didSet {
            let newSize = bounds.size
            
            guard let buttonConfiguration = buttonConfiguration
            else { return }
           
            let cornerRadius = bounds.height * roundCoefficient
            
            self.setBackgroundImage(
                .from(
                    color: buttonConfiguration.normal.background,
                    size: newSize,
                    cornerRadius: cornerRadius
                ),
                for: .normal
            )
            
            self.setBackgroundImage(
                .from(
                    color: buttonConfiguration.disabled.background,
                    size: newSize,
                    cornerRadius: cornerRadius
                ),
                for: .disabled
            )
            
            self.setBackgroundImage(
                .from(
                    color: buttonConfiguration.highlighted.background,
                    size: newSize,
                    cornerRadius: cornerRadius
                ),
                for: .highlighted
            )
            
            if buttonConfiguration.canSelect {
                self.setBackgroundImage(
                    .from(
                        color: buttonConfiguration.normal.title,
                        size: newSize,
                        cornerRadius: cornerRadius
                    ),
                    for: .selected
                )
            }
       }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height * roundCoefficient
        
        updateUI()
                
        if let shadow = buttonConfiguration?.shadow {
            layer.shadowColor = shadow.color.cgColor
            layer.shadowOffset = shadow.offset
            layer.shadowOpacity = shadow.opacity
            layer.shadowRadius = shadow.radius
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        }
    }

    func setBorderColor(normal: UIColor?, highlighted: UIColor?, disabled: UIColor?) {
        normalBorderColor = normal
        highlightedBorderColor = highlighted
        disabledBorderColor = disabled
    }
}
