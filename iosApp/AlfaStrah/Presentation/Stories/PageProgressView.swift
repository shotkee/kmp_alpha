//
//  PageProgressView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 27.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class PageProgressView: UIView {
    private let trackingView = UIView()
    private var trackingViewWidthConstraint: NSLayoutConstraint?
    private var animator: UIViewPropertyAnimator?
    var fractionComplete: CGFloat = 0.0
    
    init() {
        super.init(frame: .zero)
        
		backgroundColor = .Background.backgroundTertiary
        
        layer.cornerRadius = 1.5
        clipsToBounds = true
        
        addSubview(trackingView)
        trackingView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = trackingView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            trackingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackingView.topAnchor.constraint(equalTo: topAnchor),
            trackingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint
        ])
        trackingViewWidthConstraint = widthConstraint
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    func setProgress(
        _ progress: CGFloat,
        duration: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        let animations = {
            self.trackingViewWidthConstraint?.constant = progress * self.bounds.width
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        animator?.stopAnimation(true)
        
        if duration == 0 {
            animator = nil
            animations()
            completion?()
        } else {
            animator = UIViewPropertyAnimator(
                duration: duration,
                curve: .linear,
                animations: {
                    animations()
                }
            )
            animator?.addCompletion { _ in
                completion?()
            }
            animator?.startAnimation()
            animator?.fractionComplete = fractionComplete
        }
    }
    
    func pauseAnimation()
    {
        fractionComplete = animator?.fractionComplete ?? 0.0
        animator?.pauseAnimation()
    }
    
    func continueAnimation()
    {
        animator?.startAnimation()
    }
    
    func cancelAnimation()
    {
        animator?.stopAnimation(true)
        animator = nil
    }
    
    var progressTintColor: UIColor = .red {
        didSet {
            trackingView.backgroundColor = progressTintColor
        }
    }
}
