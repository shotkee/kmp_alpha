//
//  OperationStatusViewController.swift
//  AlfaStrah
//
//  Created by vit on 18.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy
import UIKit

final class DmsCostRecoveryOperationStatusViewController: ViewController, RMRNavBarViewControllerDelegate {
    enum State {
        case upload(String, String)
        case success(String, String)
        case failure(String, String)
    }
    
    struct Input {
        let setInitialState: () -> Void
    }

    var input: Input!
    
    struct Output {
        var goToMainScreen: () -> Void
        var goToChat: () -> Void
        var flowCompleted: () -> Void
    }
    
    var output: Output!
    
    struct Notify {
        var updateWithState: (_ state: State) -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateWithState: { [weak self] state in
            self?.update(with: state)
        }
    )

    var showNavigationBar: Bool {
        false
    }
    
    private var operationStatusView: OperationStatusView = .init(frame: .zero)
    private var hide: ((_ completion: (() -> Void)?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.setInitialState()
    }
        
    // MARK: - Setup UI
    private func setup() {
        view.addSubview(operationStatusView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: view))
    }

    private func update(with state: State) {
        switch state {
            case .success(let title, let description):
                let operationStatusViewState: OperationStatusView.State = .info(.init(
                    title: title,
                    description: description,
                    icon: UIImage(named: "icon-check-success")
                ))

                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("common_to_main_screen", comment: ""),
                        isPrimary: false,
                        action: {
                            self.output.goToMainScreen()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("common_done_button", comment: ""),
                        isPrimary: true,
                        action: {
                            self.output.flowCompleted()
                        }
                    )
                ]
                
                operationStatusView.notify.updateState(operationStatusViewState)
                operationStatusView.notify.buttonConfiguration(buttons)
                
            case .failure(let title, let description):
                let operationStatusViewState: OperationStatusView.State = .info(.init(
                    title: title,
                    description: description,
                    icon: UIImage(named: "icon-common-failure")
                ))

                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("common_go_to_chat", comment: ""),
                        isPrimary: false,
                        action: {
                            self.output.goToChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("common_done_button", comment: ""),
                        isPrimary: true,
                        action: {
                            self.output.flowCompleted()
                        }
                    )
                ]
                operationStatusView.notify.updateState(operationStatusViewState)
                operationStatusView.notify.buttonConfiguration(buttons)
                
            case .upload(let status, let descritpion):
                let operationStatusViewState: OperationStatusView.State = .info(.init(
                    title: status ?? "",
                    description: descritpion ?? "",
                    icon: UIImage(named: "ico-upload-in-progress")
                ))
                
                operationStatusView.notify.updateState(operationStatusViewState)
        }
    }
}
