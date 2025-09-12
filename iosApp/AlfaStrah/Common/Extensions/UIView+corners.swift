//
//  UIView+corners.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 23.10.2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIView {
    private func roundCorners(corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    enum Side {
        case right
        case left
        case top
        case bottom
        case all

        func corners() -> UIRectCorner {
            switch self {
                case .right:
                    return [.topRight, .bottomRight]
                case .left:
                    return [.topLeft, .bottomLeft]
                case .top:
                    return [.topLeft, .topRight]
                case .bottom:
                    return [.bottomLeft, .bottomRight]
                case .all:
                    return [.topLeft, .topRight, .bottomLeft, .bottomRight]
            }
        }
    }

    func roundCorners(side: Side = .all, radius: CGFloat) {
        roundCorners(corners: side.corners(), radius: radius)
    }
}
