//
// ActionSheetTransition
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

class ActionSheetTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval = 0.25
	var dimColor: UIColor = .Other.overlayPrimary.withAlphaComponent(1)
	var dimAlpha: CGFloat = UIColor.Other.overlayPrimary.cgColor.alpha
	
    var forward: Bool = true

    var prepare: (() -> Void)?
    var animation: (() -> Void)?
    var completion: (() -> Void)?

    private let dimView: UIView = UIView()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }

        if forward {
            toVC.modalPresentationStyle = .overFullScreen
        }

        let containerView = transitionContext.containerView

        dimView.frame = containerView.bounds
        dimView.backgroundColor = dimColor

        if forward {
            fromVC.view.snapshotView(afterScreenUpdates: false).map { containerView.addSubview($0) }
            containerView.addSubview(dimView)
            containerView.addSubview(toVC.view)
            toVC.view.frame = containerView.bounds
        } else {
            containerView.addSubview(toVC.view)
            containerView.addSubview(dimView)
            containerView.addSubview(fromVC.view)
        }

        containerView.layoutIfNeeded()

        prepare?()

        let startTransform: CGAffineTransform
        let endTransform: CGAffineTransform
        if forward {
            let frame = toVC.view.frame
            startTransform = CGAffineTransform(translationX: 0, y: frame.height)
            endTransform = .identity
        } else {
            let frame = fromVC.view.frame
            startTransform = .identity
            endTransform = CGAffineTransform(translationX: 0, y: frame.height)
        }

        if forward {
            dimView.alpha = 0
            toVC.view.transform = startTransform
        } else {
            dimView.alpha = dimAlpha
        }

        UIView.animate(
            withDuration: transitionContext.isAnimated ? duration : 0,
            delay: 0,
            options: [ forward ? .curveEaseOut : .curveEaseIn ],
            animations: {
                self.dimView.alpha = self.forward ? self.dimAlpha : 0.0
                if self.forward {
                    toVC.view.transform = endTransform
                    self.animation?()
                } else {
                    fromVC.view.transform = endTransform
                }
            },
            completion: { _ in
                let cancelled = transitionContext.transitionWasCancelled

                if !cancelled && !self.forward {
                    self.dimView.removeFromSuperview()
                }

                if !cancelled && !self.forward {
                    // NOTE: - Fix iOS bug for dissapearing view heirarchy
                    // on dismissal http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.shared.keyWindow?.addSubview(toVC.view)
                }

                transitionContext.completeTransition(!cancelled)

                self.completion?()
            }
        )
    }
}
