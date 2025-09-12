//
//  GradientTranslucentNavigationController.swift
//  AlfaStrah
//
//  Created by vit on 24.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class TranslucentNavigationController: RMRNavigationController {
    enum BackgroundType {
        case gradient
        case clear
    }
    
    @available(iOS 15, *)
    private static var previousStandardAppearance: UINavigationBarAppearance?
    
    @available(iOS 15, *)
    private static var previousScrollEdgeAppearancee: UINavigationBarAppearance?
    
    @available(iOS 15, *)
    private static var previousCompactAppearance: UINavigationBarAppearance?
    
    private var previousBackgroundImage: UIImage?
    
    private var previousBackgroundColor: UIColor?
    
    private var appearanceSaved = false
    
    func savePreviousAppearance(from navigationBar: UINavigationBar) {
        guard !appearanceSaved
        else { return }
        
        appearanceSaved = true
        
        previousBackgroundColor = navigationBar.backgroundColor
        
        if #available(iOS 15.0, *) {
            Self.previousStandardAppearance = navigationBar.standardAppearance.copy()
            Self.previousScrollEdgeAppearancee = navigationBar.scrollEdgeAppearance?.copy()
            Self.previousCompactAppearance = navigationBar.compactAppearance?.copy()
        } else {
            previousBackgroundImage = navigationBar.backgroundImage(for: .default)
        }
    }
    
    func restorePreviousAppearance() {
        appearanceSaved = false
        
        navigationBar.backgroundColor = previousBackgroundColor
        
        if #available(iOS 15.0, *) {
            if let previousStandardAppearance = Self.previousStandardAppearance{
                navigationBar.standardAppearance = previousStandardAppearance
            }
            
            if let previousScrollEdgeAppearancee = Self.previousScrollEdgeAppearancee {
                navigationBar.scrollEdgeAppearance = previousScrollEdgeAppearancee
            }
            
            if let previousCompactAppearance = Self.previousCompactAppearance {
                navigationBar.compactAppearance = previousCompactAppearance
            }
        } else {
            if let previousBackgroundImage = self.previousBackgroundImage {
                navigationBar.setBackgroundImage(previousBackgroundImage, for: .default)
            }
        }
    }
	
	func configureAppearence(
		navigationBarBackgroundImage: UIImage
	) {
		// fix black flashing during color transition
		navigationBar.isTranslucent = true
		navigationBar.backgroundColor = .clear // replace navigation bar color from rmr_configureAppearance
		
		if #available(iOS 15.0, *) {
			let appearance = navigationBar.standardAppearance.copy()
			
			appearance.backgroundImage = navigationBarBackgroundImage
			appearance.shadowImage = nil
			appearance.backgroundColor = .clear
			appearance.backgroundEffect = nil
			appearance.shadowColor = .clear
			
			navigationBar.standardAppearance = appearance
			navigationBar.scrollEdgeAppearance = appearance
			navigationBar.compactAppearance = appearance
		} else {
			navigationBar.setBackgroundImage(navigationBarBackgroundImage, for: .default)
		}
	}
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		if let backgroundType = (topViewController as? TranslucentNavigationViewControllerDelegate)?.backgroundType() {
			applyBackground(for: backgroundType)
		}
	}
	
	func applyBackground(for type: BackgroundType) {
		switch type {
			case .gradient:
				let navigationBarFrame = navigationBar.frame
				let navigationBarBackgroundImage = UIImage.gradientImage(
					from: .Other.imageGradient,
					to: .Other.imageGradient.withAlphaComponent(0.15),
					with: navigationBarFrame
				)

				configureAppearence(
					navigationBarBackgroundImage: navigationBarBackgroundImage
				)
			case .clear:
				configureAppearence(
					navigationBarBackgroundImage: UIImage()
				)
		}
	}
}

protocol TranslucentNavigationViewControllerDelegate {
    func backgroundType() -> TranslucentNavigationController.BackgroundType
}

class TranslucentNavigationControllerDelegate: RMRNavigationControllerDelegate {
    override func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        if let translucentNavigationController = navigationController as? TranslucentNavigationController {
            if let backgroundType = (viewController as? TranslucentNavigationViewControllerDelegate)?.backgroundType() {
				translucentNavigationController.savePreviousAppearance(from: translucentNavigationController.navigationBar)
                
				translucentNavigationController.applyBackground(for: backgroundType)
            } else {
				translucentNavigationController.navigationBar.isTranslucent = false
				translucentNavigationController.restorePreviousAppearance()
            }
        }
    }
}
