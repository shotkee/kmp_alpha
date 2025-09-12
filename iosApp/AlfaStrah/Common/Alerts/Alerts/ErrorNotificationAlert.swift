//
//  ErrorNotificationAlert.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class ErrorNotificationAlert: BasicNotificationAlert {
    override var textColor: UIColor {
        Style.Color.text
    }

    init(error: Error? = nil, text: String? = nil, combined: Bool = false, action: (() -> Void)? = nil) {
        var message: String
        let errorText = (error as? Displayable)?.displayValue
        if combined, let errorText = errorText {
            message = (text ?? NSLocalizedString("common_error_unknown_error", comment: "")) + "\n" + errorText
        } else {
            message = errorText ?? text ?? NSLocalizedString("common_error_unknown_error", comment: "")
        }
        switch environment {
            case .appStore:
                break
            case .testAdHoc, .stageAdHoc, .prodAdHoc, .test, .stage, .prod:
                message += error.map { "\n\(($0 as? Displayable)?.debugDisplayValue ?? String(describing: $0))" } ?? ""
        }

        super.init(text: message, action: action)
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = Style.Color.Palette.lightGray
    }
}
