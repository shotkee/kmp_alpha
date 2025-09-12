//
//  PhotoCardView.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 21.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class PhotoCardView: UIView {
    private let expandedTouchInsets = UIEdgeInsets(top: -12, left: 0, bottom: 0, right: -12)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let adjustedRect = bounds.inset(by: expandedTouchInsets)
        return adjustedRect.contains(point)
    }
}
