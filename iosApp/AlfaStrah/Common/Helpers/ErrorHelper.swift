//
// ErrorHelper
// AlfaStrah
//
// Created by Eugene Egorov on 17 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

class ErrorHelper: NSObject {
    @objc static func show(error: Error?, text: String? = nil, alertPresenter: AlertPresenter) {
        let errorText: String
        switch environment {
            case .appStore:
                errorText = (error as? Displayable)?.displayValue ?? NSLocalizedString("common_error_unknown_error", comment: "")
            case .testAdHoc, .stageAdHoc, .prodAdHoc, .test, .stage, .prod:
                errorText = (error as? Displayable)?.debugDisplayValue ?? NSLocalizedString("common_error_unknown_error", comment: "")
        }

        let noInternetError = NoInternetNotificationAlert(text: errorText)
        switch error {
            case let error as AlfastrahError where error.isCanceled:
                return
            case let error as NSError where error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue:
                showSettingsError(text: NSLocalizedString("location_denied", comment: ""))
            case let error as AlfastrahError where error.apiErrorKind == .notAvailableInDemoMode:
                alertPresenter.show(alert: DemoModeNotificationAlert())
            case AlfastrahError.network(NetworkError.error(.unreachable?, _, _))?:
                alertPresenter.show(alert: noInternetError)
            case is ChatNotFatalError:
                alertPresenter.show(alert: noInternetError)
            default:
                alertPresenter.show(alert: ErrorNotificationAlert(error: error, text: text))
        }
    }

    static func showSettingsError(text: String) {
        guard let topModalVC = UIHelper.topViewController() else { return }

        let alert = UIAlertController(
            title: nil,
            message: text,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_close_button", comment: ""), style: .cancel)
        alert.addAction(cancelAction)
        let proceedAction = UIAlertAction(title: NSLocalizedString("common_proceed", comment: ""), style: .default) { _ in
            ApplicationFlow.shared.show(item: .settings)
        }
        alert.addAction(proceedAction)
        topModalVC.present(alert, animated: true)
    }
}
