//
//  ActionSheetViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 05.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

protocol ActionSheetContentViewController where Self: UIViewController {
    var animationWhileTransition: (() -> Void)? { get set }
}

class ActionSheetViewController: ViewController, UIViewControllerTransitioningDelegate {
    private var actionSheet = UIView()
    private var topSpaceView = UIView()
    private var contentView = UIView()
	private lazy var dragConstraint: NSLayoutConstraint = {
		return actionSheet.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
	}()
    private var heightConstraint: NSLayoutConstraint?
    private let contentViewController: ActionSheetContentViewController

	private var backgroundColor: UIColor = .Background.backgroundModal
    private let transition = ActionSheetTransition()
    private var dismissCompletion: (() -> Void)?

    var enableDrag = true
    var enableTapDismiss = true

    init(
		with content: ActionSheetContentViewController, 
		backgroundColor: UIColor = .Background.backgroundModal,
		dismissCompletion: (() -> Void)? = nil) 
	{
		self.backgroundColor = backgroundColor
		self.contentViewController = content
		self.dismissCompletion = dismissCompletion
		
        super.init(nibName: nil, bundle: nil)
		modalPresentationStyle = .overFullScreen
		transitioningDelegate = self
    }

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		actionSheet.backgroundColor = contentViewController.view.backgroundColor
		
        keyboardBehavior.subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(false)
        keyboardBehavior.unsubscribe()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        topSpaceView.backgroundColor = .clear
		
        let handlerView = UIView()
        actionSheet.addSubview(handlerView)
        actionSheet.addSubview(contentView)
        view.addSubview(actionSheet)
        view.addSubview(topSpaceView)
		
        actionSheet.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        handlerView.translatesAutoresizingMaskIntoConstraints = false
        topSpaceView.translatesAutoresizingMaskIntoConstraints = false
		
        NSLayoutConstraint.activate([
            actionSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            actionSheet.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            handlerView.widthAnchor.constraint(equalToConstant: 24),
            handlerView.heightAnchor.constraint(equalToConstant: 2),
            handlerView.topAnchor.constraint(equalTo: actionSheet.topAnchor, constant: 6),
            handlerView.centerXAnchor.constraint(equalTo: actionSheet.centerXAnchor),
            contentView.leadingAnchor.constraint(equalTo: actionSheet.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: actionSheet.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: actionSheet.topAnchor, constant: 24),
            dragConstraint,
            topSpaceView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSpaceView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSpaceView.topAnchor.constraint(equalTo: view.topAnchor),
            topSpaceView.bottomAnchor.constraint(equalTo: actionSheet.topAnchor)
        ])

        if enableTapDismiss {
            let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
            topSpaceView.addGestureRecognizer(closeTapGesture)
        }

        if enableDrag {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
            actionSheet.addGestureRecognizer(panGesture)
        }

        handlerView.isHidden = !enableDrag
		handlerView.backgroundColor = .Background.backgroundModal
        handlerView.layer.cornerRadius = 18

        addChild(contentViewController)
        contentView.addSubview(contentViewController.view)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: contentViewController.view, in: contentView))
		
		actionSheet.backgroundColor = contentViewController.view.backgroundColor

        keyboardBehaviorSetup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let path = UIBezierPath(
            roundedRect: actionSheet.layer.bounds,
            byRoundingCorners: [ .topLeft, .topRight ],
            cornerRadii: CGSize(width: 12, height: 12)
        )
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        actionSheet.layer.mask = layer
		
		actionSheet.backgroundColor = contentViewController.view.backgroundColor
    }

    @objc private func close() {
        dismiss(animated: true, completion: dismissCompletion)
    }

    private var initialHeight: CGFloat = 0
	private var defaultContentHeight: CGFloat = 0
    private var initialConstraintConstant: CGFloat = 0
    private var initialHeightConstant: CGFloat = 0
    private var originalTouchPoint: CGPoint = .zero

    @objc private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: view)
        let velocity = recognizer.velocity(in: view)
		
        switch recognizer.state {
            case .began:
                initialConstraintConstant = dragConstraint.constant
                initialHeight = actionSheet.frame.height
				
                initialHeightConstant = heightConstraint?.constant ?? 0
                originalTouchPoint = touchPoint
				
            case .changed:
                let offset = touchPoint.y - originalTouchPoint.y
								
                guard offset >= 0
				else { return }
					
                dragConstraint.constant = initialConstraintConstant - offset
                heightConstraint?.constant = initialHeightConstant - offset
				
            case .ended, .cancelled:
				if (actionSheet.frame.height < initialHeight * 0.5 && velocity.y > -100) || velocity.y > 1000 {
                    close()
                } else {
                    animateReversion()
                }
				
            default:
                break
				
        }
    }

    private func animateReversion() {
        let duration = abs(Double(dragConstraint.constant)) * 0.001
        // swiftlint:disable:next trailing_closure
        UIView.animate(
			withDuration: duration,
			delay: 0,
			options: [ .allowUserInteraction ],
			animations: {
				self.dragConstraint.constant = self.initialConstraintConstant
				self.heightConstraint?.constant = self.defaultContentHeight
				self.view.layoutIfNeeded()
			}
		)
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition.forward = true
        transition.animation = contentViewController.animationWhileTransition
        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ActionSheetTransition()
        transition.forward = false
        return transition
    }

    // MARK: - Keyboard

    private let keyboardBehavior: KeyboardBehavior = KeyboardBehavior()
    private var defaultInsets: UIEdgeInsets = .zero

    private func keyboardBehaviorSetup() {
        keyboardBehavior.animations = { [weak self] frame, options, duration in
            guard let `self` = self else { return }

            let frameInView = self.view.convert(frame, from: nil)
            let offset = max(self.view.bounds.maxY - frameInView.minY, 0)

            // swiftlint:disable:next trailing_closure
            UIView.animate(withDuration: duration, delay: 0, options: [ .allowUserInteraction ], animations: {
                self.dragConstraint.constant = offset
                self.view.layoutIfNeeded()
            })
        }
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		actionSheet.backgroundColor = backgroundColor
	}
}
