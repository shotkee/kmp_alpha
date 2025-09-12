//
//  DemoAlertViewController.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class DemoAlertViewController: ViewController {
    @IBOutlet private var cardView: UIView!
    @IBOutlet private var signInButton: RoundEdgeButton!
    @IBOutlet private var cancelButton: RoundEdgeButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtextLabel: UILabel!

    var output: Output!

    struct Output {
        let tapCancel: () -> Void
        let tapSignIn: () -> Void
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStyle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        cardView.layer.cornerRadius = 18.0
    }

    @IBAction private func signInClick(_ sender: Any) {
        output.tapSignIn()
    }

    @IBAction private func cancelClick(_ sender: Any) {
        output.tapCancel()
    }

    private func setupStyle() {
        titleLabel <~ Style.Label.primaryHeadline1
        subtextLabel <~ Style.Label.secondaryText
        cancelButton <~ Style.Button.alertDefaultButton
        signInButton <~ Style.Button.alertActionButton
    }
}
