//
//  BaseTabBarController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

/// Base tab bar controller.
class BaseTabBarController: UITabBarController,
                            UITabBarControllerDelegate,
                            AnalyticsServiceDependency,
							AccountServiceDependency {

	var accountService: AccountService!
    var analytics: AnalyticsService!
    
	private let topBorder = UIView()
		
    override func viewDidLoad() {
        super.viewDidLoad()
		
		topBorder.backgroundColor = .Stroke.divider
		tabBar.layer.shadowOffset = CGSize(width: 0, height: -5)
		tabBar.layer.shadowOpacity = 1
		tabBar.layer.shadowRadius = 9
		tabBar.addSubview(topBorder)
		
        delegate = self
        let button = SosButton.fromNib()
        button.translatesAutoresizingMaskIntoConstraints = false
        let indent = abs(tabBar.frame.height - button.bounds.size.height) + 3

        let constraints = [
            button.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            button.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -indent),
            button.heightAnchor.constraint(equalToConstant: 66),
            button.widthAnchor.constraint(equalToConstant: 66)
        ]
        button.addTarget(self, action: #selector(callSos), for: .touchUpInside)
        tabBar.addSubview(button)
        NSLayoutConstraint.activate(constraints)
        tabBar.isTranslucent = false
        tabBar.layer.borderWidth = 0.0
        
		updateLayoutForCurrentTraitCollectionStyle()
    }
	
	private func updateLayoutForCurrentTraitCollectionStyle() {
		switch traitCollection.userInterfaceStyle {
			case .dark:
				updateLayoutForDarkStyle()
			case .light, .unspecified:
				fallthrough
			@unknown default:
				updateLayoutForLightStyle()
		}
	}

    override func viewWillLayoutSubviews() {
		topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 1)
        tabBar.layer.shadowPath = UIBezierPath(rect: tabBar.bounds).cgPath
    }

    private func updateLayoutForLightStyle() {
		topBorder.isHidden = true
		addShadow()
    }
	
	private func updateLayoutForDarkStyle() {
		removeShadow()
		topBorder.isHidden = false
	}
	
	private func addShadow() {
		tabBar.shadowImage = UIImage()
		tabBar.backgroundImage = UIImage()
		tabBar.layer.shadowColor = UIColor.Shadow.tabbarShadow.cgColor
	}
	
	private func removeShadow() {
		tabBar.shadowImage = nil
		tabBar.backgroundImage = nil
		tabBar.layer.shadowColor = UIColor.clear.cgColor
	}

    @objc private func callSos() {
        ApplicationFlow.shared.show(item: .sos)
    }

    // MARK: - UITabbar Delegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is FakeSosController {
            ApplicationFlow.shared.show(item: .sos)
            return false
		} else if let navigationController = viewController as? UINavigationController,
				  let rootViewController = navigationController.viewControllers.first,
				  (rootViewController is ProfileViewController || rootViewController is HomeViewController || rootViewController is BuyListViewController)
		{
            return true
        } else {
			return true
		}
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
            case 0:
                analytics.track(event: AnalyticsEvent.App.openMain)
            case 1:
				break
            case 2:
                break
            case 3:
                analytics.track(event: AnalyticsEvent.App.openShowcase)
            case 4:
                analytics.track(event: AnalyticsEvent.App.openProfile)
            default:
                break
        }
		
		BDUI.ScreensHierarchyIndexing.setActiveTab(tabBarController.selectedIndex)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        // change iOS 13 default modal presentation style behaviour to .fullScreen
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
		
		tabBar.layer.shadowColor = UIColor.Shadow.tabbarShadow.cgColor
		
		updateLayoutForCurrentTraitCollectionStyle()
    }
}
