//
//  EuroProtocolBaseViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 02.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class EuroProtocolBaseViewController: ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        addZeroView()
    }

    @discardableResult
    func handleError(_ error: Error) -> Bool {
        switch error {
            case let error as EuroProtocolServiceError:
                switch error {
                    case .sdkAuthInfoMissing:
                        showAuthExpireError(error)
                        return true
                    case .sdkError(.noActiveSession), .successResponseParsingError:
                        showExitFlowError(error)
                        return true
                    default:
                        return false
                }
            default:
                return false
        }
    }

    private var loadingIndicatorHandler: (((() -> Void)?) -> Void)?

    func loadingIndicator(show: Bool, message: String? = nil) {
        if show, loadingIndicatorHandler == nil {
            loadingIndicatorHandler = showLoadingIndicator(
                message: message
            )
        } else if !show {
            loadingIndicatorHandler? {}
            loadingIndicatorHandler = nil
        }
    }

    func showExitFlowError(_ error: EuroProtocolServiceError) {
        let zeroViewModel = ZeroViewModel(
            kind: .custom(
                title: error.errorMessage.title,
                message: error.errorMessage.message,
                iconKind: .error
            ),
            canCloseScreen: false,
            buttons: [
                .init(
                    title: NSLocalizedString("common_open_home_sreen", comment: ""),
                    isPrimary: false,
                    action: { ApplicationFlow.shared.show(item: .tabBar(.home)) }
                ),
                .init(
                    title: NSLocalizedString("common_restart", comment: ""),
                    isPrimary: true,
                    action: {
                        NotificationCenter.default.post(
                            name: Notification.Name(EuroProtocolEventFlow.Constants.restartFlowNotification),
                            object: nil
                        )
                    }
                )
            ]
        )

        zeroView?.update(viewModel: zeroViewModel)
        showZeroView()
    }

    func showAuthExpireError(_ error: EuroProtocolServiceError) {
        let zeroViewModel = ZeroViewModel(
            kind: .custom(
                title: error.errorMessage.title,
                message: error.errorMessage.message,
                iconKind: .error
            ),
            canCloseScreen: false,
            buttons: [
                .init(
                    title: NSLocalizedString("insurance_euro_protocol_exit_flow_button_title", comment: ""),
                    isPrimary: false,
                    action: {
                        NotificationCenter.default.post(
                            name: Notification.Name(EuroProtocolEventFlow.Constants.exitFlowNotification),
                            object: nil
                        )
                    }
                ),
                .init(
                    title: NSLocalizedString("insurance_euro_protocol_auth_again_button_title", comment: ""),
                    isPrimary: true,
                    action: {
                        NotificationCenter.default.post(
                            name: Notification.Name(EuroProtocolEventFlow.Constants.authAgainNotification),
                            object: nil
                        )
                    }
                )
            ]
        )

        zeroView?.update(viewModel: zeroViewModel)
        showZeroView()
    }
}
