//
//  AccidentEventSuccessScreen
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class AccidentEventSuccessScreen: ViewController {
    struct Output {
        var close: () -> Void
    }

    var output: Output!

    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var actionButton: RoundEdgeButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        navigationItem.hidesBackButton = true

        textLabel <~ Style.Label.primaryHeadline1
        textLabel.text = NSLocalizedString("accident_succes_screen_text", comment: "")
        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        actionButton.setTitle(NSLocalizedString("common_done_button", comment: ""), for: .normal)
    }

    @IBAction private func doneTap() {
        output.close()
    }
}
