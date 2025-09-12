//
// AuthMethodViewController
// AlfaStrah
//
// Created by Eugene Egorov on 04 December 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit

class AuthMethodViewController: ViewController {
    struct Output {
        let grantAutoAuth: () -> Void
        let denyAutoAuth: () -> Void
    }

    var output: Output!

	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var descriptionLabel: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
		
		titleLabel <~ Style.Label.primaryHeadline1
		descriptionLabel <~ Style.Label.secondaryText
    }

    @IBAction private func negativeDecision() {
        output.denyAutoAuth()
    }

    @IBAction private func positiveDecision() {
        output.grantAutoAuth()
    }
}
