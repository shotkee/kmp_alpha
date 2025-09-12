//
//  PullToRefreshView.swift
//  AlfaStrah
//
//  Created by vit on 06.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class PullToRefreshView: UIView {
	private let generator = UIImpactFeedbackGenerator(style: .light)
	private lazy var activityIndicatorView = ActivityIndicatorView()
	
	internal var scrollView: UIScrollView?
	internal var refreshDataCallback: ((_ completion: @escaping () -> Void) -> Void)?
	
	var animationCompletion: (() -> Void)?

	internal var title: String?
	
	var pullToRefreshInProgress: Bool = false
	private var activityIndicatorIsAdded: Bool = false
	private var pullToRefreshCanStart: Bool = true
	private var pullToRefreshIsPrepared: Bool = false
	
	private var defaultContentOffsetY: CGFloat = 0
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		addActivityIndicatorView()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if pullToRefreshCanStart { // contentOffset.y can be changed between operations
			self.defaultContentOffsetY = scrollView?.contentOffset.y ?? 0
		}
	}
	
	private func addActivityIndicatorView() {
		guard let delegateView = scrollView
		else { return }
		
		activityIndicatorIsAdded = true
		
		activityIndicatorView.clearBackgroundColor()
		
		if let title = title {
			activityIndicatorView.set(
				title: NSLocalizedString(
					title,
					comment: ""
				)
			)
		}
		
		insertSubview(activityIndicatorView, at: 0)
				
		activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			activityIndicatorView.topAnchor.constraint(
				equalTo: self.safeAreaLayoutGuide.topAnchor,
				constant: Constants.defaultScrollInset
			),
			activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			activityIndicatorView.widthAnchor.constraint(equalToConstant: Constants.activityIndicatorSpinnerHeight),
			activityIndicatorView.heightAnchor.constraint(equalToConstant: Constants.activityIndicatorSpinnerHeight),
			activityIndicatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
		
		activityIndicatorView.alpha = 0
	}
	
	private func startPullToRefresh() {
		guard !pullToRefreshInProgress
		else { return }
		
		pullToRefreshInProgress = true
		pullToRefreshCanStart = false
		
		activityIndicatorView.alpha = 1
		
		activityIndicatorView.animating = true
		
		refreshDataCallback?{ [weak self] in
			self?.stopPullToRefresh()
		}
	}
	
	private func stopPullToRefresh(animate: Bool = true) {
		activityIndicatorView.animating = false

        guard let scrollView = scrollView
        else { return }
        
        if animate {
            if !scrollView.isDragging {
                UIView.animate(
                    withDuration: 0.6,
                    animations: {
						scrollView.contentInset.top = 0
                    },
                    completion: { [weak self] _ in
                        self?.handlePullToRefreshCompletion()
                    }
                )
            }
        } else {
			scrollView.contentInset.top = 0
            // fix content offset after re-login & switch tab
            scrollView.setContentOffset(
				CGPoint(x: 0, y: self.defaultContentOffsetY),
                animated: false
            )
			
            handlePullToRefreshCompletion()
        }
    }
    
    private func handlePullToRefreshCompletion() {
        pullToRefreshInProgress = false
        if window != nil {
            generator.impactOccurred()
        }
		
		animationCompletion?()
    }
    
    private func resetPullToRefreshAtAnimationStartPoint() {
        guard let scrollView = scrollView
        else { return }
                
        // pullToRefresh op can start only after scroll returns to the initial position
		if scrollView.contentOffset.y == self.defaultContentOffsetY {
            pullToRefreshCanStart = true
            pullToRefreshIsPrepared = false
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func didScrollCallback(_ scrollView: UIScrollView) {
        resetPullToRefreshAtAnimationStartPoint()
        
        if scrollView.contentOffset.y < self.defaultContentOffsetY,
           !pullToRefreshInProgress,
           pullToRefreshCanStart {
			activityIndicatorView.alpha = min(
				abs(scrollView.contentOffset.y + Constants.defaultScrollInset - self.defaultContentOffsetY) / Constants.spacingForActivityIndicator, 1
			)
			
            if !pullToRefreshIsPrepared {
                pullToRefreshIsPrepared = true
                activityIndicatorView.setInitialState()
				activityIndicatorView.alpha = 0
            }
        }
        
        if scrollView.contentOffset.y >= -Constants.defaultScrollInset + self.defaultContentOffsetY && !pullToRefreshInProgress {
            activityIndicatorView.alpha = 0
        }
        
        if scrollView.contentOffset.y < self.defaultContentOffsetY
            && abs(scrollView.contentOffset.y) > abs(Constants.spacingForActivityIndicator - self.defaultContentOffsetY)
            && !pullToRefreshInProgress
            && pullToRefreshCanStart {
            generator.impactOccurred()
            startPullToRefresh()
        }
    }
    
    func didEndDraggingCallcback(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard pullToRefreshInProgress
        else { return }
        
        // if user released scroll before activity indicator animation ended
        if activityIndicatorView.animating {
            UIView.animate(
                withDuration: 0.6,
                animations: {
					self.scrollView?.contentInset.top = Constants.spacingForActivityIndicator
                }
            )
        } else {
            // if user released scroll after activity indicator animation ended
            UIView.animate(
                withDuration: 0.6,
                animations: {
					self.scrollView?.contentInset.top = 0
                },
                completion: { [weak self] _ in
                    self?.handlePullToRefreshCompletion()
                }
            )
        }
    }
        
    struct Constants {
        static let defaultScrollInset: CGFloat = 0
        static let spacingForActivityIndicator: CGFloat = 108
        static let activityIndicatorSpinnerHeight: CGFloat = 52
    }
}
