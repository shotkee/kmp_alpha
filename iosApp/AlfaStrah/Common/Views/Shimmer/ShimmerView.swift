//
// ShimmerView
// AlfaStrah
//
// Created by Vasiliy Kotsiuba on 13 December 2017.
// Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

protocol Shimmerable: AnyObject {
    var direction: ShimmerDirection { get set }
    /// Starts shimmer effect.
    func start()
    /// Stops shimmer effect.
    func stop()
}

/// View with shimmer effect.
class ShimmerView: UIView, Shimmerable {
    var direction: ShimmerDirection = .right
    private let gradientView = GradientView()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
		backgroundColor = .Background.backgroundAdditional
        clipsToBounds = true
        addSubview(gradientView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: gradientView, in: self))
        let lightGray = UIColor(white: 0.9, alpha: 1.0)
        let clear = UIColor(white: 1, alpha: 0.0)
        gradientView.colors = [ clear, lightGray, clear ]
        gradientView.locations = [ 0.35, 0.65, 1.0 ]
        gradientView.update()
    }

    /// Starts shimmer effect.
    func start() {
        stop()
        let startPointTransition = direction.transition(for: .startPoint)
        let endPointTransition = direction.transition(for: .endPoint)

        let startPointAnimation = CABasicAnimation(keyPath: "startPoint")
        startPointAnimation.fromValue = startPointTransition.from
        startPointAnimation.toValue = startPointTransition.to

        let endPointAnimation = CABasicAnimation(keyPath: "endPoint")
        endPointAnimation.fromValue = endPointTransition.from
        endPointAnimation.toValue = endPointTransition.to

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [startPointAnimation, endPointAnimation]
        animationGroup.duration = 2
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animationGroup.repeatCount = .infinity

        gradientView.layer.add(animationGroup, forKey: "animateLayer")
    }

    /// Stops shimmer effect.
    func stop() {
        gradientView.layer.removeAllAnimations()
    }
}

/// Helping view container for 'ShimmerViews'
class ShimmerContainerView: UIView, Shimmerable {
    var direction: ShimmerDirection = .right

    private var shimmerViews: [Shimmerable] {
        func getShimmerViews(from view: UIView) -> [Shimmerable] {
            var shimmerViews: [Shimmerable] = []

            for view in view.subviews {
                shimmerViews += getShimmerViews(from: view)

                if let view = view as? Shimmerable {
                    shimmerViews.append(view)
                }
            }

            return shimmerViews
        }
        return getShimmerViews(from: self)
    }

    /// Starts shimmer effect.
    func start() {
        shimmerViews.forEach {
            $0.direction = direction
            $0.start()
        }
    }

    /// Stops shimmer effect.
    func stop() {
        shimmerViews.forEach { $0.stop() }
    }
}
