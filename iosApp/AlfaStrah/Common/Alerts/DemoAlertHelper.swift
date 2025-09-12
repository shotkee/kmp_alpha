//
//  DemoAlertHelper.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 14/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

struct DemoAlertHelper {
    func showDemoAlert(from: UIViewController) {
        let viewController: DemoAlertViewController = UIStoryboard(name: "Auth", bundle: nil).instantiate()
        viewController.output = DemoAlertViewController.Output(
            tapCancel: { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            },
            tapSignIn: { [weak viewController] in
                viewController?.dismiss(animated: true) {
                    ApplicationFlow.shared.show(item: .login)
                }
            }
        )
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle =  .custom
        from.present(viewController, animated: true, completion: nil)
    }
}
