//
//  UIView+shadow.swift
//  AlfaStrah
//
//  Created by vit on 10.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

extension UIView {
    func embedded(
        margins: UIEdgeInsets = .zero,
        hasShadow: Bool = false,
        cornerRadius: CGFloat = 12,
        cornerSide: Side = .all,
        isUserInteractionEnabled: Bool = true,
        shadowStyle: CardView.ShadowStyle = .shadow70pct
    ) -> UIView {
        let containerView = UIView()
		
		let view: UIView
		
		if hasShadow {
			view = CardView(
				contentView: self,
				cornerRadius: cornerRadius,
				cornersSide: cornerSide,
				shadowStyle: shadowStyle
			)
		} else {
			view = self
			
			if cornerRadius != 0 {
				view.roundCorners(side: cornerSide, radius: cornerRadius)
			}
		}
        
        view.isUserInteractionEnabled = isUserInteractionEnabled
        
        containerView.addSubview(view)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = hasShadow
            ? false
            : view.translatesAutoresizingMaskIntoConstraints
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: view,
                in: containerView, margins: margins
            )
        )
        
        return containerView
    }
}
