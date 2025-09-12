//
// ViewController
// AlfaStrah
//
// Created by Eugene Egorov on 15 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit
import CoreLocation
import Legacy

class ViewController: RMRViewController,
					  DependencyContainerDependency,
					  AnalyticsServiceDependency,
					  AlertPresenterDependency,
					  LoggerDependency {
    var container: DependencyInjectionContainer?
    var analytics: AnalyticsService!
    var alertPresenter: AlertPresenter!
    var logger: TaggedLogger?

    let disposeBag: DisposeBag = DisposeBag()

    var active: Observable<Bool> = Observable(value: false, skipSameValue: true)
    var applicationActive: Observable<Bool> = Observable(value: true, skipSameValue: true)
    var zeroView: ZeroView?

    deinit {
        logger?.debug("")
    }

    override func viewDidLoad() {
        logger?.debug("")

        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
		setupDemoBarButtonItem()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification, object: nil)
    }
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        active.value = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        active.value = false
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        // change iOS 13 default modal presentation style behaviour to .fullScreen

        viewControllerToPresent.modalPresentationStyle = .fullScreen

        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		setupDemoBarButtonItem()
	}
    
    func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        with presentationStyle: UIModalPresentationStyle,
        completion: (() -> Void)? = nil
    ) {
        viewControllerToPresent.modalPresentationStyle = presentationStyle
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    // MARK: - Application activation

    @objc private func applicationDidBecomeActive() {
        applicationActive.value = true
    }

    @objc private func applicationWillResignActive() {
        applicationActive.value = false
    }

    private var closeButtonAction: (() -> Void)?

    enum BarItemPosition {
        case left
        case right
    }
    
    func addCloseButton(position: BarItemPosition = .left, action: @escaping () -> Void) {
        closeButtonAction = action

        func createBarCloseButtonItem() -> UIBarButtonItem {
            let button = UIBarButtonItem(
                image: UIImage.Icons.cross,
                style: .plain,
                target: self,
                action: #selector(leftButtonTap)
            )
            
            button.tintColor = .Icons.iconAccentThemed
            
            return button
        }
        
        switch position {
            case .left:
                navigationItem.leftBarButtonItem = createBarCloseButtonItem()
            case .right:
                navigationItem.rightBarButtonItem = createBarCloseButtonItem()
        }
    }
	
	func addNavigationButton(
		icon: UIImage? = nil,
		text: String? = nil,
		position: BarItemPosition,
		action: @escaping () -> Void
	) {
		switch position {
			case .left:
				closeButtonAction = action
			case .right:
				rightButtonAction = action
		}
		
		func createIconButtonItem() -> UIBarButtonItem {
			let button = UIBarButtonItem(
				image: icon?.resized(newWidth: 24)?.withRenderingMode(.alwaysTemplate),
				style: .plain,
				target: self,
				action: {
					switch position {
						case .left:
							#selector(leftButtonTap)
						case .right:
							#selector(rightButtonTap)
					}
				}()
			)
			
			return button
		}
		
		func createTextButtonItem() -> UIBarButtonItem {
			let button = UIBarButtonItem(
				title: text,
				style: .plain,
				target: self,
				action: {
					switch position {
						case .left:
							#selector(leftButtonTap)
						case .right:
							#selector(rightButtonTap)
					}
				}()
			)
			
			return button
		}
		
		switch position {
			case .left:
				navigationItem.leftBarButtonItem = icon == nil
					? createTextButtonItem()
					: createIconButtonItem()
				
			case .right:
				navigationItem.rightBarButtonItem = icon == nil
					? createTextButtonItem()
					: createIconButtonItem()
		}
	}
	
    @objc private func leftButtonTap() {
        closeButtonAction?()
    }

    private var backButtonAction: (() -> Void)?

    func addBackButton(action: @escaping () -> Void) {
        backButtonAction = action
        let backButton = UIBarButtonItem(
            image: .Icons.chevronLargeLeft,
            style: .plain,
            target: self,
            action: #selector(backButtonTap)
        )
        
        backButton.tintColor = .Icons.iconAccentThemed
        
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTap() {
        backButtonAction?()
    }

    private var rightButtonAction: (() -> Void)?

    enum NavigationItemAppearance {
        case red
        case gray
    }
    
    func addRightButton(title: String, appearance: NavigationItemAppearance = .red, action: @escaping () -> Void) {
		
		guard !isDemoMode
		else { return }
		
        rightButtonAction = action
        let rightBarButtonItem = UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: #selector(rightButtonTap)
        )
        
        switch appearance {
            case .red:
                rightBarButtonItem <~ Style.Button.NavigationItemRed(title: title)
            case .gray:
                rightBarButtonItem <~ Style.Button.NavigationItemDarkGray(title: title)
		}
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func addRightButton(image: UIImage, action: @escaping () -> Void) {
		guard !isDemoMode
		else { return }
		
        rightButtonAction = action
        let rightBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(rightButtonTap)
        )
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
	
	private func setupDemoBarButtonItem()
	{
		let demoButton = RoundEdgeButton()
		demoButton <~ Style.RoundedButton.primaryWhiteButtonLarge
		demoButton.setTitle(
			NSLocalizedString("demo_title", comment: ""),
			for: .normal
		)
		demoButton.setImage(
			.Icons.hint
				.resized(newWidth: 24)?
				.tintedImage(withColor: .Icons.iconBlack),
			for: .normal
		)
		demoButton.contentEdgeInsets = UIEdgeInsets(
			top: 3.5,
			left: 0,
			bottom: 3.5,
			right: 8
		)
		demoButton.addTarget(self, action: #selector(demoButtonTap), for: .touchUpInside)
		demoButton.height(33)
		demoButton.width(75)
		
		// add logic bacause semanticContentAttribute don't work in navigationItem
		demoButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
		demoButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
		demoButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
		let rightBarButtonItem = UIBarButtonItem(customView: demoButton)
		navigationItem.rightBarButtonItem = isDemoMode
			? rightBarButtonItem 
			: navigationItem.rightBarButtonItem
	}
	
	@objc private func demoButtonTap()
	{
		DemoBottomSheet.presentInfoDemoSheet(from: self)
	}

    @objc private func rightButtonTap() {
        rightButtonAction?()
    }

    func addZeroView() {
        let zeroView = ZeroView()
        view.addSubview(zeroView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: zeroView, in: view))
        self.zeroView = zeroView
        hideZeroView()
    }

    func showZeroView(bringToFront: Bool = true) {
        if !(zeroView?.canCloseScreen ?? true) {
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = nil
        }
        if bringToFront {
            zeroView.map(view.bringSubviewToFront)
        }
        zeroView?.isHidden = false
    }

    func hideZeroView() {
        zeroView?.isHidden = true
    }

    // MARK: - Errors

    func processError(_ error: Error?) {
        ErrorHelper.show(error: error, alertPresenter: alertPresenter)
    }
}

extension UIViewController {
    // MARK: - Loading indicator

    /// Show loading indicator
    /// - parameters:
    ///   - message: Optional title
    ///   - in: View controller where the loading indicator will be presented
    ///   - completion: Completion closure
    /// - returns: Closure with completion parameter, that hides the loading indicator
    func showLoadingIndicator(
        message: String?,
        in viewController: UIViewController? = nil,
        cancellable: CancellableNetworkTaskContainer? = nil,
        completion: (() -> Void)? = nil,
        clearBackground: Bool = true,
		withDelay: CGFloat? = nil
    ) -> (_ completion: (() -> Void)?) -> Void {
		
		let viewController = viewController ?? self
		let navigationController = (viewController as? UINavigationController) ?? viewController.navigationController
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		
		let containerView: UIView = viewController.view
		let indicatorView = ModalActivityIndicatorView.fromNib()
		
		indicatorView.cancellable = cancellable
		indicatorView.onShow = completion
		
		let task = DispatchWorkItem {			
			indicatorView.infoString = message
			indicatorView.frame = containerView.bounds
			containerView.addSubview(indicatorView)
			if clearBackground {
				indicatorView.clearIndicatorBackground()
			}
			indicatorView.animating = true
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ?? 0.0), execute: task)

        return { [weak navigationController] (completion: (() -> Void)?) in
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            indicatorView.onHide = { [weak indicatorView] in
                indicatorView?.removeFromSuperview()
                completion?()
            }

            indicatorView.animating = false
			
			task.cancel()
        }
    }
	
    /// Show loading indicator
    /// - parameters:
    ///   - message: Optional title
    ///   - in: View controller where the loading indicator will be presented
    ///   - completion: Completion closure with a parameter containing a closure that hides the loading indicator
    func showLoadingIndicator(
        message: String?,
        in viewController: UIViewController? = nil,
        cancellable: CancellableNetworkTaskContainer? = nil,
        completion: @escaping (_ hide: @escaping (_ completion: @escaping () -> Void) -> Void) -> Void,
        clearBackground: Bool = false
    ) {
        let viewController = viewController ?? self
        let navigationController = (viewController as? UINavigationController) ?? viewController.navigationController
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        let indicatorView = createLoadingIndicator(
            message: message, in: viewController, clearIndicatorBackground: clearBackground)
        indicatorView.cancellable = cancellable
        indicatorView.onShow = { [weak indicatorView] in
            let hide = { (hideCompletion: @escaping () -> Void) in
                navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                indicatorView?.onHide = {
                    indicatorView?.removeFromSuperview()
                    hideCompletion()
                }
                indicatorView?.animating = false
            }
            completion(hide)
        }
        indicatorView.animating = true
    }

    private func createLoadingIndicator(
        message: String?,
        in viewController: UIViewController,
        clearIndicatorBackground: Bool = true
    ) -> ModalActivityIndicatorView {
        let containerView: UIView = viewController.view
        let indicatorView = ModalActivityIndicatorView.fromNib()
        indicatorView.infoString = message
        indicatorView.frame = containerView.bounds
        containerView.addSubview(indicatorView)
        if clearIndicatorBackground {
            indicatorView.clearIndicatorBackground()
        }
        return indicatorView
    }
}
