//
//  NetworkUnreachableBanner.swift
//  AlfaStrah
//
//  Created by Makson on 20.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

func showNetworkUnreachableBanner() {
	showStateInfoBanner(
		title: NSLocalizedString("snack_network_reachibility_error_title", comment: ""),
		description: NSLocalizedString("snack_network_reachibility_error_description", comment: ""),
		hasCloseButton: true,
		iconImage: .Icons.exclamation,
		titleFont: Style.Font.headline1,
		appearance: .standard
	)
}
