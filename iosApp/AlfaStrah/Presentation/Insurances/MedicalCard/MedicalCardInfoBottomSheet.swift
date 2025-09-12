//
//  MedicalCardInfoBottomSheet.swift
//  AlfaStrah
//
//  Created by vit on 12.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

enum MedicalCardInfoBottomSheet {
    static func present(
        from viewController: ViewController,
        title: String,
        buttonTitle: String,
        additionalViews: [UIView] = [],
        fileEntry: MedicalCardFileEntry,
		action: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        let bottomSheetController = BaseBottomSheetViewController()
        
        bottomSheetController.set(title: title)
        bottomSheetController.set(
            style:
                .actions(
                    primaryButtonTitle: buttonTitle,
                    secondaryButtonTitle: nil
                )
        )
        bottomSheetController.set(views: additionalViews)
        
        bottomSheetController.closeTapHandler = { [weak bottomSheetController] in
            bottomSheetController?.dismiss(animated: true)
        }
        bottomSheetController.primaryTapHandler = { [weak bottomSheetController] in
			action?()
			
            bottomSheetController?.dismiss(animated: true) {
                if fileEntry.status == .error {
                    completion?()
                }
            }
        }
        
        viewController.showBottomSheet(contentViewController: bottomSheetController)
    }
}
