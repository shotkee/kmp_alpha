//
//  RootViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class RootViewController: ViewController {
    private(set) var currentViewController: UIViewController

    init(initialViewController viewController: UIViewController) {
        currentViewController = viewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        add(childViewController: currentViewController)
    }

    private func add(childViewController: UIViewController) {
        addChild(childViewController)
        childViewController.view.frame = view.bounds
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }

    private func remove(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()
    }

    private var transitionInProgress: Bool = false

    private struct Transition {
        let viewController: UIViewController
        let animated: Bool
        let completion: (() -> Void)?
    }

    private var nextTransitions: [Transition] = []

    private func transitToNext() {
        if let next = nextTransitions.first {
            nextTransitions.removeFirst()
            transit(to: next.viewController, animated: next.animated, completion: next.completion)
        }
    }

    func transit(to newViewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        guard !transitionInProgress else {
            let transition = Transition(viewController: newViewController, animated: animated, completion: completion)
            nextTransitions.append(transition)
            return
        }

        transitionInProgress = true
        if presentedViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        add(childViewController: newViewController)

        let oldViewController = currentViewController
        currentViewController = newViewController

        // swiftlint:disable:next unused_closure_parameter
        let finish = { (completed: Bool) in
            self.remove(viewController: oldViewController)
            self.transitionInProgress = false
            completion?()
            self.transitToNext()
        }

        if animated {
            transition(
                from: oldViewController,
                to: newViewController,
                duration: 0.4,
                options: [ .transitionCrossDissolve, .curveEaseOut ],
                animations: nil,
                completion: finish
            )
        } else {
            finish(true)
        }
    }
}
