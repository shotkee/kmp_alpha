//
//  DebugMenu.swift
//  AlfaStrah
//
//  Created by vit on 04.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class DebugMenu: NSObject {
	var rootWindow: UIWindow?
	var debugMenuControlWindow: UIWindow?
	var debugBDUI: Bool = false
	var homeBDUI: Bool = false
	
	let overlayViewController = UIViewController()
	
	static let shared = DebugMenu()
	
	private var buttons: [(UIButton, ((UIButton) -> Void)?)] = [] {
		didSet {
			debugMenuControlWindow?.frame = CGRect(
				x: -Constants.iconHeight / 2,
				y: (rootWindow?.safeAreaInsets.top ?? 0) + 44,
				width: Constants.iconHeight,
				height: (Constants.iconHeight + Constants.space) * CGFloat(buttons.count)
			)
		}
	}
	
	@available(iOS 13.0, *)
	func addMenuButton(iconSystemName: String, action: ((UIButton) -> Void)? = nil) {
		if debugMenuControlWindow == nil {
			debugMenuControlWindow = UIWindow(frame: .zero)
			
			overlayViewController.view.backgroundColor = .clear
			debugMenuControlWindow?.rootViewController = overlayViewController
			
			if let style = rootWindow?.overrideUserInterfaceStyle {
				self.debugMenuControlWindow?.overrideUserInterfaceStyle = style
			}
			
			debugMenuControlWindow?.windowLevel = .alert
			debugMenuControlWindow?.isHidden = false
		}
		
		let buttonsCount = CGFloat(buttons.count)
		
		let button = UIButton(type: .system)
		button.frame = CGRect(
			x: 0,
			y: buttonsCount * Constants.iconHeight + Constants.space * buttonsCount,
			width: Constants.iconHeight,
			height: Constants.iconHeight
		)
		button.roundCorners(radius: button.frame.width * 0.5)
		let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: Constants.iconHeight, weight: .regular, scale: .large)
		let image = UIImage(systemName: iconSystemName, withConfiguration: symbolConfiguration)
		button.setImage(image, for: .normal)
		button.addTarget(self, action: #selector(clicked(_:)), for: .touchUpInside)
		button.tintColor = .Icons.iconPrimary
		overlayViewController.view.addSubview(button)
		
		buttons.append((button, action))
	}
	
	@objc func clicked(_ sender: UIButton) {
		if let buttonEntry = buttons.first(where: { $0.0 === sender }) {
			buttonEntry.1?(sender)
		}
	}
	
	struct Constants {
		static let iconHeight: CGFloat = 42
		static let space: CGFloat = iconHeight * 0.5
	}
}
