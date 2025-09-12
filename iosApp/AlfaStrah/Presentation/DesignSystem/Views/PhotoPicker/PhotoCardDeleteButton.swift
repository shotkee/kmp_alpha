//
//  DeleteButton.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 21.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class PhotoCardDeleteButton: UIButton {
    private let expandedBoundsRect: CGSize = CGSize(width: 12, height: 12)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(
            dx: -expandedBoundsRect.width,
            dy: -expandedBoundsRect.height
        )
        return expandedBounds.contains(point)
    }
}
