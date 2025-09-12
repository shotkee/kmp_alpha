//
//  EuroProtocolLoadDraftViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class EuroProtocolActiveSessionFoundViewController: EuroProtocolBaseViewController {
    struct Output {
        let continueFromDraft: () -> Void
        let newEuroProtocol: () -> Void
    }

    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = NSLocalizedString("euro_protocol_process_title", comment: "")

        showContinueEuroProtocolUI()
    }

    private func showContinueEuroProtocolUI() {
        let zeroViewModel = ZeroViewModel(
            kind: .custom(
                title: NSLocalizedString("euro_protocol_you_have_draft_text", comment: ""),
                message: NSLocalizedString("euro_protocol_you_have_active_session_text", comment: ""),
                iconKind: .error
            ),
            canCloseScreen: true,
            buttons: [
                .init(
                    title: NSLocalizedString("euro_protocol_restart_flow", comment: ""),
                    isPrimary: false,
                    action: { [weak self] in self?.output.newEuroProtocol() }
                ),
                .init(
                    title: NSLocalizedString("euro_protocol_continue_flow", comment: ""),
                    isPrimary: true,
                    action: { [weak self] in self?.output.continueFromDraft() }
                )
            ]
        )

        zeroView?.update(viewModel: zeroViewModel)
        showZeroView()
    }
}
