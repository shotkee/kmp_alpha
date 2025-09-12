//
//  SuccessfullQuennaireViewController.swift
//  AlfaStrah
//
//  Created by Makson on 23.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class SuccessfullQuennaireViewController: ViewController {
    enum State {
        case loading
        case failure
        case filled(DoctorAppointmentInfoMessage)
    }
    
    // MARK: - Outlets
    private var operationStatusView: OperationStatusView = .init()
    
    struct Input {
        let createAppointment: () -> Void
    }
    
    var input: Input!
    
    struct Output {
        let close: () -> Void
        let showToMain: () -> Void
        let goToChat: () -> Void
    }
    
    var output: Output!
    
    struct Notify {
        var updateWithState: (_ state: State) -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateWithState: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(with: state)
        }
    )
    
    private var state: State?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.createAppointment()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update must be placed here because the lottie-animation can only be started from didAppear method
        // https://github.com/airbnb/lottie-ios/issues/510#issuecomment-1092509674
        
        if state == nil {
            update(with: .loading)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        setupOperationStatusView()
    }
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        operationStatusView.edgesToSuperview()
    }
    
    private func update(with state: State) {
        self.state = state

        switch state {
            case .loading:
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("questionnaire_loading_text", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
            case .failure:
                addBackButton { [weak self] in
                    self?.output.close()
                }
            
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("questionnaire_loading_error_title", comment: ""),
                    description: NSLocalizedString("questionnaire_loading_error_description", comment: ""),
                    icon: UIImage(named: "icon-common-failure")
                ))
                
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("questionnaire_go_to_chat_button", comment: ""),
                        isPrimary: false,
                        action: { [weak self] in
                            self?.output.goToChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("questionnaire_loading_error_button_title", comment: ""),
                        isPrimary: true,
                        action: { [weak self] in
                            self?.update(with: .loading)
                            self?.input.createAppointment()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
            case .filled(let doctorAppointmentInfoMessage):
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                let state: OperationStatusView.State = .info(.init(
                    title: doctorAppointmentInfoMessage.title,
                    description: doctorAppointmentInfoMessage.text,
                    icon: .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
                ))
            
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("common_done_button", comment: ""),
                        isPrimary: true,
                        action: { [weak self] in
                            self?.output.showToMain()
                        }
                    )
                ]
            
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
        }
    }
}
