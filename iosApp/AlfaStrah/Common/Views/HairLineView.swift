//
//  HairLineView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

/// Hairline view.
class HairLineView: UIView
{
    open override var intrinsicContentSize: CGSize
    {
        CGSize(width: .zero, height: 1)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    @IBInspectable var lineColor: UIColor = .Stroke.divider
    @IBInspectable var bottomRight: Bool = false

    /// Sets up UI.
    private func setup() {
        isOpaque = false
        clearsContextBeforeDrawing = true
        contentMode = .redraw
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let scale = UIScreen.main.scale
        let hairline = 1 / scale
        var rect = bounds
        let horizontal = bounds.width >= bounds.height
        if horizontal {
            if bottomRight {
                rect.origin.y = rect.maxY - hairline
            }
            rect.size.height = hairline
        } else {
            if bottomRight {
                rect.origin.x = rect.maxX - hairline
            }
            rect.size.width = hairline
        }

        context.setFillColor(lineColor.cgColor)
        context.fill(rect)
    }
}
