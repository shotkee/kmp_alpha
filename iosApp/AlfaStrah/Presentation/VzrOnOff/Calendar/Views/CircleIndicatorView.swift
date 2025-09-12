//
//  CircleIndicatorView.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 23.10.2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

class CircleIndicatorView: UIView {
    enum CircleIndicatorState {
        case leftEnd
        case rightEnd
        case inMiddle
        case alone
    }

    var state: CircleIndicatorState = .alone {
        didSet {
            updateState()
        }
    }
    let leftBackView = UIView()
    let rightBackView = UIView()
    let circleView = UIView()
    private let rangeHeight: CGFloat = 36
    private let indicatorSize: CGFloat = 42

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(leftBackView)
        addSubview(rightBackView)
        addSubview(circleView)
        leftBackView.translatesAutoresizingMaskIntoConstraints = false
        rightBackView.translatesAutoresizingMaskIntoConstraints = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.isHidden = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        leftBackView.frame = CGRect(origin: CGPoint(x: 0, y: (frame.height - rangeHeight) / 2),
            size: CGSize(width: frame.width / 2, height: rangeHeight))
        rightBackView.frame = CGRect(origin: CGPoint(x: frame.width / 2, y: (frame.height - rangeHeight) / 2),
            size: CGSize(width: frame.width / 2, height: rangeHeight))
        circleView.frame = CGRect(origin: CGPoint(x: (frame.width - indicatorSize) / 2, y: (frame.height - indicatorSize) / 2),
            size: CGSize(width: indicatorSize, height: indicatorSize))
        circleView.roundCorners(radius: indicatorSize / 2)
    }

    private func updateState() {
        switch state {
            case .leftEnd:
                leftBackView.isHidden = true
                rightBackView.isHidden = false
            case .rightEnd:
                leftBackView.isHidden = false
                rightBackView.isHidden = true
            case .inMiddle:
                leftBackView.isHidden = false
                rightBackView.isHidden = false
            case .alone:
                leftBackView.isHidden = true
                rightBackView.isHidden = true
        }
    }
}
