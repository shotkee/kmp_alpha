//
//  ZeroView.swift
//  AlfaStrah
//
//  Created by Vasyl Kotsiuba on 21.08.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ZeroView: UIView {
    private lazy  var operationStatusView: OperationStatusView = {
        let operationStatusView: OperationStatusView = .init()
        self.addSubview(operationStatusView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: self))
        return operationStatusView
    }()

    private lazy var permissionsView: CommonPermissionsView = {
        let permissionsView = CommonPermissionsView.fromNib()
        self.addSubview(permissionsView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: permissionsView, in: self))
        return permissionsView
    }()

    private(set) var viewModel: ZeroViewModel?

    var canCloseScreen: Bool {
        viewModel?.canCloseScreen ?? true
    }

    func update(viewModel: ZeroViewModel) {
        self.viewModel = viewModel

        switch viewModel.kind {
            case .loadingWithIndicator:
                let stateInfo = OperationStatusView.StateInfo(title: viewModel.title, description: nil, icon: nil)
                operationStatusView.notify.updateState(.loading(stateInfo))
            case .loading, .emptyList, .demoMode, .custom, .error:
                operationStatusView.isHidden = false
                permissionsView.isHidden = true

                let stateInfo = OperationStatusView.StateInfo(
                    title: viewModel.title,
                    description: viewModel.text,
                    icon: viewModel.iconName.flatMap { UIImage(named: $0) },
                    buttonsAlignment: viewModel.buttonsAlignment
                )
                operationStatusView.notify.updateState(.info(stateInfo))
                operationStatusView.notify.buttonConfiguration(viewModel.buttons)
                
            case .permissionsRequired(let cards):
                operationStatusView.isHidden = true
                permissionsView.isHidden = false

                permissionsView.set(cards: cards)
                permissionsView.openSettingsAction = { ApplicationFlow.shared.show(item: .settings) }
        }
    }
}
