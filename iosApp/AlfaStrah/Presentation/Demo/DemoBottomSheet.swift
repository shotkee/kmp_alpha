//
//  DemoBottomSheet.swift
//  AlfaStrah
//
//  Created by Makson on 30.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import TinyConstraints

enum DemoBottomSheet
{
	static func presentLogInDemoSheet(
		from viewController: UIViewController,
		action: @escaping (() -> Void)
	) {
		let bottomSheetController = BaseBottomSheetViewController()
		
		bottomSheetController.set(title: NSLocalizedString("demo_log_in_header", comment: ""))
		bottomSheetController.set(
			style:
				.actions(
					primaryButtonTitle: NSLocalizedString("demo_log_in_continue_button", comment: ""),
					secondaryButtonTitle: NSLocalizedString("demo_log_in_button", comment: "")
				)
		)
		
		bottomSheetController.add(
			view: createInfoView(
				title: NSLocalizedString("demo_log_in_title", comment: ""),
				description: NSLocalizedString("demo_log_in_description", comment: "")
			)
		)
		
		bottomSheetController.closeTapHandler = { [weak viewController] in
			viewController?.dismiss(animated: true)
		}
		
		bottomSheetController.primaryTapHandler = action
		
		bottomSheetController.secondaryTapHandler = { [weak viewController] in
			viewController?.dismiss(
				animated: true,
				completion: {
					ApplicationFlow.shared.showLogInViewController()
				}
			)
		}
		
		viewController.showBottomSheet(contentViewController: bottomSheetController)
	}
	
	static func presentInfoDemoSheet(
		from viewController: UIViewController
	) {
		let bottomSheetController = BaseBottomSheetViewController()
		
		bottomSheetController.set(
			title: NSLocalizedString("demo_info_header", comment: "")
		)
		
		bottomSheetController.set(
			style:
				.actions(
					primaryButtonTitle: NSLocalizedString("demo_info_continue_button", comment: ""),
					secondaryButtonTitle: NSLocalizedString("demo_info_log_in_button", comment: "")
				)
		)
		
		bottomSheetController.add(
			view: createInfoView(
				title: NSLocalizedString("demo_info_title", comment: ""),
				description: NSLocalizedString("demo_info_description", comment: "")
			)
		)
		
		bottomSheetController.closeTapHandler = { [weak viewController] in
			viewController?.dismiss(animated: true)
		}
		
		bottomSheetController.secondaryTapHandler = { [weak viewController] in
			viewController?.dismiss(
				animated: true,
				completion: {
					isDemoMode = false
					ApplicationFlow.shared.show(
						item: .signIn
					)
					ApplicationFlow.shared.refreshAllTabs()
				}
			)
		}
		
		bottomSheetController.primaryTapHandler = { [weak viewController] in
			viewController?.dismiss(animated: true)
		}
		
		viewController.showBottomSheet(contentViewController: bottomSheetController)
	}
	
	static func presentLogOutDemoSheet(
		from viewController: UIViewController
	) {
		let bottomSheetController = BaseBottomSheetViewController()
		
		bottomSheetController.set(title: NSLocalizedString("demo_log_out_header", comment: ""))
		bottomSheetController.set(
			style:
				.actions(
					primaryButtonTitle: NSLocalizedString("demo_log_out_stay_button", comment: ""),
					secondaryButtonTitle: NSLocalizedString("demo_log_out_log_in_button", comment: "")
				)
		)
		
		bottomSheetController.add(
			view: createInfoView(
				title: NSLocalizedString("demo_log_out_title", comment: ""),
				description: NSLocalizedString("demo_log_out_description", comment: "")
			)
		)
		
		bottomSheetController.closeTapHandler = { [weak bottomSheetController] in
			bottomSheetController?.dismiss(animated: true)
		}
		
		bottomSheetController.primaryTapHandler = { [weak viewController] in
			viewController?.dismiss(animated: true)
		}
		
		bottomSheetController.secondaryTapHandler = { [weak viewController] in
			viewController?.dismiss(
				animated: true,
				completion: {
					isDemoMode = false
					ApplicationFlow.shared.show(
						item: .signIn
					)
					ApplicationFlow.shared.refreshAllTabs()
				}
			)
		}
		
		viewController.showBottomSheet(contentViewController: bottomSheetController)
	}
	
	private static func createInfoView(title: String, description: String) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		// stackView
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 5
		view.addSubview(stackView)
		stackView.edgesToSuperview()
		
		// titleLabel
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.primaryHeadline1
		titleLabel.numberOfLines = 0
		titleLabel.text = title
		titleLabel.textAlignment = .left
		
		// descriptionLabel
		let descriptionLabel = UILabel()
		descriptionLabel <~ Style.Label.primaryText
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = description
		descriptionLabel.textAlignment = .left
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(descriptionLabel)
		
		return view
	}
}
