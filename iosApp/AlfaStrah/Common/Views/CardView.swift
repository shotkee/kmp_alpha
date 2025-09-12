//
//  CardView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 10/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    private var shadowView: UIView = UIView()
    @IBOutlet private var contentView: UIView?
    private var primaryShadowLayer: CALayer = CALayer()
    private var secondaryShadowLayer: CALayer = CALayer()
    
	var cornerRadius: CGFloat = 12.0 {
		didSet {
			updateStyle()
		}
	}
    
    private var shadowStyle: ShadowStyle = .shadow70pct {
        didSet {
            updateStyle()
        }
    }
    
    var cornersSide: Side = .all {
        didSet {
            updateStyle()
        }
    }

    var highlightedColor: UIColor? {
        didSet {
            setHighlighted(isHighlighted)
        }
    }
    private var isHighlighted = false

    @IBInspectable var contentColor: UIColor = .clear {
        didSet {
            setHighlighted(isHighlighted)
        }
    }

    var hideShadow: Bool = false {
        didSet {
            shadowView.isHidden = hideShadow
            contentView?.clipsToBounds = !hideShadow
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }
    
    init(contentView: UIView) {
        self.init()

        self.contentColor = contentView.backgroundColor ?? self.contentColor
        set(content: contentView)
    }
    
    init(
        contentView: UIView,
        cornerRadius: CGFloat,
        cornersSide: Side = .all,
        shadowStyle: ShadowStyle = .shadow70pct
    ) {
        self.init()

        self.cornerRadius = cornerRadius
        self.contentColor = contentView.backgroundColor ?? self.contentColor
        self.cornersSide = cornersSide
        self.shadowStyle = shadowStyle
        set(content: contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

		// if content view was assigned on storyboard
		if contentView == nil,
		   let view = subviews.first,
		   subviews.count == 1 {
			self.contentView = view
			self.contentColor = view.backgroundColor ?? .clear // fix highlighted color
		}
		
        setup()
    }
	
    override func layoutSubviews() {
        super.layoutSubviews()
		
		updateStyle()
    }
	
	private func updateStyle() {
		let path = UIBezierPath(
			roundedRect: bounds,
			byRoundingCorners: cornersSide.corners(),
			cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
		)
		
		updateShadow(with: path)
		updateShape(with: path)
	}
    
	private func updateShadow(with path: UIBezierPath) {
        self <~ self.shadowStyle
                        
        primaryShadowLayer.shadowPath = path.cgPath
        secondaryShadowLayer.shadowPath = path.cgPath
    }
	
	private func updateShape(with path: UIBezierPath) {
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		contentView?.layer.mask = mask
	}

    func set(content view: UIView) {
        insertSubview(view, at: 1)
        view.edgesToSuperview()
        view.clipsToBounds = true

        contentView = view
    }
    
    private func setup() {
        insertSubview(shadowView, at: 0)
        shadowView.edgesToSuperview()
        shadowView.clipsToBounds = false
        
        shadowView.layer.insertSublayer(primaryShadowLayer, at: 0)
        shadowView.layer.insertSublayer(secondaryShadowLayer, at: 0)
        
        updateStyle()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        setHighlighted(true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        setHighlighted(false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        setHighlighted(false)
    }

    private func setHighlighted(_ highlight: Bool) {
        isHighlighted = highlight
        contentView?.backgroundColor = highlight
            ? (highlightedColor ?? contentColor)
            : contentColor
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
		
		self.contentColor = contentView?.backgroundColor ?? self.contentColor // Backend Driven UI fix - update content color after p2r
		
        updateStyle()
    }
	
	struct ShadowStyle: Applicable {
		let primaryLayerShadowAppearance: ShadowAppearance
		let secondaryLayerShadowAppearance: ShadowAppearance?
		
		func apply(_ object: CardView) {
			object.primaryShadowLayer <~ primaryLayerShadowAppearance

			if let secondaryLayerShadowAppearance {
				object.secondaryShadowLayer <~ secondaryLayerShadowAppearance
				object.secondaryShadowLayer.isHidden = false
			} else {
				object.secondaryShadowLayer <~ ShadowAppearance.zero
				object.secondaryShadowLayer.isHidden = true
			}
		}
		
		static let shadow100pct = ShadowStyle(primaryLayerShadowAppearance: .shadow100pct, secondaryLayerShadowAppearance: nil)
		static let shadow70pct = ShadowStyle(primaryLayerShadowAppearance: .shadow70pct, secondaryLayerShadowAppearance: nil)
		static let elevation1 = ShadowStyle(
			primaryLayerShadowAppearance: .primaryElevation1,
			secondaryLayerShadowAppearance: .secondaryElevation1
		)
		static let elevation2 = ShadowStyle(
			primaryLayerShadowAppearance: .secondaryElevation1,
			secondaryLayerShadowAppearance: .secondaryElevation2
		)
	}
}
