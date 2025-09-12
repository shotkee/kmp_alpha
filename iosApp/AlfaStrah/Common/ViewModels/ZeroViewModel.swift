//
//  ZeroViewModel.swift
//  AlfaStrah
//
//  Created by Vasyl Kotsiuba on 21.08.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ZeroViewModel {
    enum IconKind {
        case error
        case success
        case operationFailure
        case search
        case loading
        case chatDemoMode
        case custom(String)

        var name: String {
            switch self {
                case .error:
                    return "icon_common_data_error"
                case .success:
                    return "icon-common-success"
                case .operationFailure:
                    return "icon-common-failure"
                case .search, .loading:
                    return "search_empty"
                case .chatDemoMode:
                    return "chatting"
                case .custom(let name):
                    return name
            }
        }
    }
    
    enum DemoModeKind {
        case chat
        case common
    }

    struct ErrorRetryInfo {
        enum Kind {
            case always
            case unreachableErrorOnly
        }

        let kind: Kind
        let action: () -> Void
    }

    enum Kind {
        case loading
        case loadingWithIndicator(String?)
        case emptyList
        case demoMode(DemoModeKind)
        case custom(title: String, message: String?, iconKind: IconKind?)
        case error(Error, retry: ErrorRetryInfo?)
        case permissionsRequired([CommonPermissionsView.PermissionCardInfo])
    }

    let title: String
    let text: String?
    let iconName: String?
    let canCloseScreen: Bool
    var buttons: [OperationStatusView.ButtonConfiguration]
    var buttonsAlignment: OperationStatusView.ButtonsAlignment
    let kind: Kind

    init(
        kind: Kind,
        canCloseScreen: Bool = true,
        buttons: [OperationStatusView.ButtonConfiguration] = [],
        buttonsAlignment: OperationStatusView.ButtonsAlignment = .bottom
    ) {
        self.kind = kind
        self.canCloseScreen = canCloseScreen
        self.buttons = buttons
        self.buttonsAlignment = buttonsAlignment

        switch kind {
            case .custom(let title, let message, let iconKind):
                self.title = title
                self.text = message
                self.iconName = iconKind?.name
            case .loading:
                self.title = ""
                self.text = NSLocalizedString("preload_loading", comment: "")
                self.iconName = IconKind.loading.name
            case .loadingWithIndicator(let description):
                self.title = description ?? ""
                self.text = nil
                self.iconName = nil
            case .emptyList:
                self.title = ""
                self.text = NSLocalizedString("zero_empty_list", comment: "")
                self.iconName = IconKind.search.name
            case .demoMode(let kind):
                self.title = ""
                self.text = NSLocalizedString("common_demo_mode_alert", comment: "")
                switch kind {
                    case .chat:
                        self.iconName = IconKind.chatDemoMode.name
                    case .common:
                        self.iconName = IconKind.search.name
                }
            case .error(let error, let retryInfo):
                self.title = NSLocalizedString("common_loading_error", comment: "")
                self.text = (error as? Displayable)?.displayValue ?? NSLocalizedString("common_error_unknown_error", comment: "")
                self.iconName = IconKind.error.name
                if let retryInfo = retryInfo {
                    switch retryInfo.kind {
                        case .always:
                            self.buttons = [ .retry(action: retryInfo.action) ]
                        case .unreachableErrorOnly where (error as? Unreachable)?.isUnreachableError ?? false:
                            self.buttons = [ .retry(action: retryInfo.action) ]
                        default:
                            break
                    }
                }
            case .permissionsRequired:
                self.title = ""
                self.text = nil
                self.iconName = nil
        }
    }
}
