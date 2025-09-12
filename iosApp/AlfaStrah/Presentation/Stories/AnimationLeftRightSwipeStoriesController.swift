//
//  AnimationLeftRightSwipeStoriesController.swift
//  AlfaStrah
//
//  Created by Makson on 27.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// swiftlint:disable line_length file_length
class AnimationLeftRightSwipeStoriesController: NSObject, UIViewControllerAnimatedTransitioning {
    enum TransitionType {
        case presenting
        case dismissing
    }
    
    let transitionType: TransitionType
    
    init(transitionType: TransitionType) {
        self.transitionType = transitionType
        super.init()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.viewController(forKey: .to)?.view,
              let fromView = transitionContext.viewController(forKey: .from)?.view
        else { return }
        
        var inView = transitionContext.containerView
        inView.backgroundColor = .black
        
        var frame = inView.bounds
        
        // very good information with custom transition between vc in navigation controller https://stackoverflow.com/questions/31969524/ios-custom-transitions-and-rotation
        switch transitionType {
            case .presenting:
                frame.origin.x = frame.size.width
                toView.frame = frame
                inView.addSubview(toView)
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    toView.frame = inView.bounds
                    fromView.transform = CGAffineTransformScale(
                        fromView.transform,
                        Constants.scaleValue,
                        Constants.scaleValue
                    )
                    fromView.alpha = 0
                }, completion: { _ in
                    fromView.transform = .identity
                    fromView.alpha = 1
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            case .dismissing:
                toView.frame = frame
                toView.transform = CGAffineTransformScale(
                    toView.transform,
                    Constants.scaleValue,
                    Constants.scaleValue
                )
                toView.alpha = 0
                inView.insertSubview(toView, belowSubview: fromView)
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    frame.origin.x = frame.size.width
                    fromView.frame = frame
                    toView.transform = .identity
                    toView.alpha = 1
                }, completion: { _ in
                    toView.transform = .identity
                    toView.alpha = 1
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}

// MARK: - Constants
extension AnimationLeftRightSwipeStoriesController {
    enum Constants {
        static let scaleValue: CGFloat = 0.90
    }
}
