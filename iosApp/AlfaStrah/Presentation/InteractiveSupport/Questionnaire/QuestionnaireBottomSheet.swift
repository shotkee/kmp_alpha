//
//  QuestionnaireBottomSheet.swift
//  AlfaStrah
//
//  Created by Makson on 23.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

enum QuestionnaireBottomSheet {
    static func present(
        from viewController: ViewController,
        title: String,
        buttonTitle: String,
        additionalViews: [UIView] = []
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
            bottomSheetController?.dismiss(animated: true)
        }
        
        viewController.showBottomSheet(contentViewController: bottomSheetController)
    }
}
