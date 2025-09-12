//
//  CheckRSABottomSheet.swift
//  AlfaStrah
//
//  Created by Makson on 23.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import TinyConstraints


enum CheckRSABottomSheet
{
	static func showCheckRSABottomSheet(
		from: ViewController,
		checkOsagoBlock: CheckOsagoBlock,
		openUrl: @escaping ((String) -> Void)
	)
	{
		let bottomSheetController = BaseBottomSheetViewController()
		
		bottomSheetController.set(
			title: checkOsagoBlock.innerTitle
		)
		
		bottomSheetController.add(
			view: createInfoView(checkOsagoBlock: checkOsagoBlock)
		)
		bottomSheetController.set(style: .empty)
		bottomSheetController.closeTapHandler = { [weak from] in
			from?.dismiss(animated: true)
		}
		
		bottomSheetController.set(
			style:
				.actions(
					primaryButtonTitle: checkOsagoBlock.innerButtonText,
					secondaryButtonTitle: nil
				)
		)
		
		bottomSheetController.primaryTapHandler = { [weak from]  in
			from?.dismiss(
				animated: true,
				completion: { openUrl(checkOsagoBlock.url) }
			)
		}
		
		from.showBottomSheet(contentViewController: bottomSheetController)
	}
	
	private static func createInfoView(checkOsagoBlock: CheckOsagoBlock) -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 16
		
		stackView.addArrangedSubview(
			createLabel(text: checkOsagoBlock.innerDescription)
		)
		
		stackView.addArrangedSubview(
			createRecommendationView(text: checkOsagoBlock.innerInformation)
		)
		
		return stackView
	}
	
	private static func createLabel(text: String) -> UILabel
	{
		let label = UILabel()
		label.text = text
		label.numberOfLines = 0
		label <~ Style.Label.primaryText
		
		return label
	}
	
	private static func createRecommendationView(text: String) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .Background.backgroundTertiary
		view.clipsToBounds = true
		view.layer.cornerRadius = 10
		
		let icon = UIImageView()
		icon.image = UIImage.Icons.info
			.resized(newWidth: 18)?
			.tintedImage(withColor: .Icons.iconAccent)
		icon.height(18)
		icon.widthToHeight(of: icon)
		view.addSubview(icon)
		icon.topToSuperview(offset: 12)
		icon.leadingToSuperview(offset: 12)
		
		let label = UILabel()
		label <~ Style.Label.primarySubhead
		label.text = text
		label.numberOfLines = 0
		view.addSubview(label)
		label.edgesToSuperview(
			insets: .init(
				top: 12,
				left: 38,
				bottom: 12,
				right: 12
			)
		)
		
		return view
	}
}
