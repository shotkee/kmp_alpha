//
//  UIViewController+sheets.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

extension UIViewController {
    func showBottomSheet(
        contentViewController: ActionSheetContentViewController,
		backgroundColor: UIColor = .Background.backgroundModal,
        dragEnabled: Bool = true,
        dismissCompletion: (() -> Void)? = nil
    ) {
        let actionSheetViewController = ActionSheetViewController(
			with: contentViewController,
			backgroundColor: backgroundColor,
			dismissCompletion: dismissCompletion
		)
        if !dragEnabled {
            actionSheetViewController.enableDrag = false
            actionSheetViewController.enableTapDismiss = false
        }

        present(actionSheetViewController, animated: true)
    }
}
