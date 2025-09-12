//
//  CalendarDayButton.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.09.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class CalendarDayButton: UIButton {
    enum SelectionStyle {
        case straight
        case left
        case right
        case circle
        case weekend
        case available
        case none
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        update()
    }

    var selectionStyle: SelectionStyle = .none {
        didSet {
            update()
        }
    }

    var date: Date = Date()
    
    override var intrinsicContentSize: CGSize {
        let side: CGFloat = 42
        return .init(
            width: side,
            height: side
        )
    }

    private func update() {
        switch selectionStyle {
            case .straight:
                isSelected = true
                backgroundColor = .Background.backgroundAccent
                layer.mask = nil
            case .left:
                isSelected = true
                backgroundColor = .Background.backgroundAccent
                roundCorners([ .topLeft, .bottomLeft ], radius: bounds.height / 2)
            case .right:
                isSelected = true
                backgroundColor = .Background.backgroundAccent
                roundCorners([ .topRight, .bottomRight ], radius: bounds.height / 2)
            case .circle:
                isSelected = true
                backgroundColor = .Background.backgroundAccent
                roundCorners([ .topLeft, .bottomLeft, .topRight, .bottomRight ], radius: bounds.height / 2)
            case .weekend:
                isSelected = false
                backgroundColor = .Background.backgroundNegativeTint
                roundCorners([ .topLeft, .bottomLeft, .topRight, .bottomRight ], radius: bounds.height / 2)
            case .available:
                isSelected = false
                backgroundColor = .Background.backgroundTertiary
                roundCorners([ .topLeft, .bottomLeft, .topRight, .bottomRight ], radius: bounds.height / 2)
            case .none:
                isSelected = false
                backgroundColor = nil
        }
    }
    
    private func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.masksToBounds = false
    }
}
