//
//  AboutInsuranceEntryViewController.swift
//  AlfaStrah
//
//  Created by Makson on 13.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class AboutInsuranceEntryViewController: ViewController,
                                         UITableViewDataSource,
                                         UITableViewDelegate {
    enum State {
        case loading
        case failure
        case filled(InsuranceReportVZRDetailed)
    }
    
    // MARK: - Outlets
    private var tableView: UITableView = .init()
    private let operationStatusView = OperationStatusView()
    
    private lazy var continueButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_entry_continue_button", comment: ""), for: .normal)
        button <~ Style.RoundedButton.redBackground
        
        return button
    }()
    
    var input: Input!
    var output: Output!
    
    struct Input {
        var insuranceReportVZRDetailed: () -> Void
    }
    
    struct Output {
        let goToChat: () -> Void
        let goToWeb: (URL) -> Void
    }
    
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
    
    private var firstWillAppear = true
    private var firstDidAppear = true
    private var state: State?
    
    private var insuranceReportVZRDetailed: InsuranceReportVZRDetailed? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstWillAppear {
            input.insuranceReportVZRDetailed()
            firstWillAppear = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update must be placed here because the lottie-animation can only be started from didAppear method
        // https://github.com/airbnb/lottie-ios/issues/510#issuecomment-1092509674
        if firstDidAppear && state == nil {
            update(with: .loading)
            firstDidAppear = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

extension AboutInsuranceEntryViewController {
    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        setupTableView()
        setupContinueButton()
        setupOperationStatusView()
    }
    
    private func update(with state: State) {
        self.state = state
		
        switch state {
            case .loading:
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("insurance_entry_loading_title", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
				
            case .failure:
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("insurance_entry_error_title", comment: ""),
                    description: NSLocalizedString("insurance_entry_error_description", comment: ""),
                    icon: UIImage(named: "icon-common-failure")
                ))
                
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("common_go_to_chat", comment: ""),
                        isPrimary: false,
                        action: { [weak self] in
                            self?.output.goToChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("insurance_entry_retry", comment: ""),
                        isPrimary: true,
                        action: { [weak self] in
                            self?.update(with: .loading)
                            self?.input.insuranceReportVZRDetailed()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
				
            case .filled(let insuranceReportVZRDetailed):
                operationStatusView.isHidden = true
                title = insuranceReportVZRDetailed.title
                self.insuranceReportVZRDetailed = insuranceReportVZRDetailed
                setVisibleContinueButton()
				
        }
    }
    
    private func setupTableView() {
		tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 60,
            right: 0
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(AboutInsuranceEntryTableViewCell.id)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bounces = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContinueButton() {
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 18
            ),
            continueButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -18
            ),
            continueButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -9
            ),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: operationStatusView, in: view)
        )
    }
    
    private func setVisibleContinueButton() {
        continueButton.isHidden = insuranceReportVZRDetailed?.url == nil
    }
    
    @objc func continueButtonAction() {
        guard let url = insuranceReportVZRDetailed?.url
        else { return }
        
        output.goToWeb(url)
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let insuranceReportVZRDetailed = insuranceReportVZRDetailed
        else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(AboutInsuranceEntryTableViewCell.id)
		
		cell.configure(
			insuranceReportVZRDetailed: insuranceReportVZRDetailed,
			textColor: insuranceReportVZRDetailed.statusColorThemed?.color(for: traitCollection.userInterfaceStyle)
				?? .from(hex: insuranceReportVZRDetailed.statusColor ?? "", default: .Text.textPrimary)
		)

		cell.selectionStyle = .none
        
        return cell 
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
