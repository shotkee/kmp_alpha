//
//  InsuranceEntryViewController.swift
//  AlfaStrah
//
//  Created by Makson on 13.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class InsuranceEntryViewController: ViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource {
    
    enum State {
        case loading
        case failure
        case filled([InsuranceReportVZR])
    }
    
    // MARK: - Outlets
    private var tableView: UITableView = .init()
    private let operationStatusView = OperationStatusView()
    
    var input: Input!
    var output: Output!
    
    
    struct Input {
        var insuranceReportsVZR: () -> Void
    }
    
    struct Output {
        var goToAboutEntry: (Int64) -> Void
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
    
    private var insuranceReportsVZR: [InsuranceReportVZR] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstWillAppear {
            input.insuranceReportsVZR()
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

extension InsuranceEntryViewController {
    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        setupTableView()
        addZeroView()
        setupOperationStatusView()
    }
    
    private func setupTableView() {
		tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 60,
            right: 0
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(InsuranceEntryTableViewCell.id)
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
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            operationStatusView.topAnchor.constraint(equalTo: view.topAnchor),
            operationStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            operationStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            operationStatusView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
                        title: NSLocalizedString("insurance_entry_retry", comment: ""),
                        widthButton: 234,
                        isPrimary: false,
                        action: { [weak self] in
                            self?.update(with: .loading)
                            self?.input.insuranceReportsVZR()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
                
            case .filled(let insuranceReportsVZR):
                operationStatusView.isHidden = true
                if insuranceReportsVZR.isEmpty {
                    let zeroViewModel = ZeroViewModel(
                        kind: .custom(
                            title: NSLocalizedString("insurance_entry_zero_entry", comment: ""),
                            message: nil,
                            iconKind: .search
                        )
                    )
                    zeroView?.update(viewModel: zeroViewModel)
                    showZeroView()
                }
                else {
                    self.insuranceReportsVZR = insuranceReportsVZR
                }
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        insuranceReportsVZR.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let insuranceReportVZR = insuranceReportsVZR[safe: indexPath.row]
        else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(InsuranceEntryTableViewCell.id)
		cell.selectionStyle = .none
		
		cell.configure(
			insuranceReportVZR: insuranceReportVZR,
			textColor: insuranceReportVZR.statusColorThemed?.color(for: traitCollection.userInterfaceStyle)
				?? .from(hex: insuranceReportVZR.statusColor ?? "", default: .Text.textPrimary)
		)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reportId = insuranceReportsVZR[safe: indexPath.row]?.id
        else { return }
        
        output.goToAboutEntry(reportId)
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		tableView.reloadData()
	}
}
