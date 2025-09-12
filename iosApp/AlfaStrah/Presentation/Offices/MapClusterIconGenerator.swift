//
//  MapClusterIconGenerator.swift
//  AlfaStrah
//
//  Created by Darya Viter on 15.10.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Foundation
import UIKit

class MapClusterIconGenerator {
    static func clusterImage(
        _ clusterSize: UInt,
        color: UIColor,
        textColor: UIColor
    ) -> UIImage? {
        let text = (clusterSize as NSNumber).stringValue
        let font = Style.Font.headline1
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font as Any])
        let radius: CGFloat = 22
        let iconSide = radius * 2
        
        let iconSize = CGSize(width: iconSide, height: iconSide)

        UIGraphicsBeginImageContextWithOptions(iconSize, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }

        guard let ctx = UIGraphicsGetCurrentContext()
        else { return nil }

        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: .zero,
            size: iconSize
        ))

        let textYAdjustment: CGFloat = 0
        (text as NSString).draw(
            in: CGRect(
                origin: CGPoint(x: radius - size.width / 2, y: radius - size.height / 2 + textYAdjustment),
                size: size
            ),
            withAttributes: [
                NSAttributedString.Key.font: font as Any,
                NSAttributedString.Key.foregroundColor: textColor
            ]
        )
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }

    func icon(forSize size: UInt) -> UIImage {
        Self.clusterImage(size, color: .Icons.iconAccent, textColor: .Icons.iconContrast) ?? UIImage()
    }
    
}
