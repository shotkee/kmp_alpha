//
//  EmptyHintToTopBottomHintAnimator.swift
//  AlfaStrah
//
//  Created by Станислав Старжевский on 01.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import Foundation

protocol EmptyHintToTopHintBottomValueAnimator: AnyObject {
    var emptyHint: UIView { get }
    var emptySubHint: UIView? { get }
    var topHint: UIView { get }
    var bottomValue: UIView { get }
}

extension EmptyHintToTopHintBottomValueAnimator where Self: UIView {
    func animateToEmptyHint() {
        let emptyHintEndFrame = emptyHint.frame
        emptyHint.frame = topHint.frame
        emptyHint.alpha = 0.0
        emptyHint.isHidden = false
        emptySubHint?.alpha = 0.0
        emptySubHint?.isHidden = false

        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.emptyHint.frame = emptyHintEndFrame
                self.emptyHint.alpha = 1.0
                self.emptySubHint?.alpha = 1.0

                self.topHint.alpha = 0.0
                self.bottomValue.alpha = 0.0
            },
            completion: { _ in
                self.topHint.isHidden = true
                self.bottomValue.isHidden = true
            }
        )
    }

    func animateToTopHintBottomValue() {
        let emptyHintEndFrame = topHint.frame
        let initial = emptyHint.frame
        topHint.alpha = 0.0
        bottomValue.alpha = 0.0
        topHint.isHidden = false
        bottomValue.isHidden = false

        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.emptyHint.frame = emptyHintEndFrame
                self.emptyHint.alpha = 0.0
                self.emptySubHint?.alpha = 0.0
                self.topHint.alpha = 1.0
                self.bottomValue.alpha = 1.0
            },
            completion: { completed in
                if completed {
                    self.emptyHint.isHidden = true
                    self.emptyHint.frame = initial
                    self.emptySubHint?.isHidden = true
                }
            }
        )
    }
}
