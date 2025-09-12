//
//  SosViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class SosViewController: ViewController, UITableViewDelegate, UITableViewDataSource
{
	enum Section
	{
		case sos
		case confidant
		case sosEmergencyCommunication
	}
	
    enum State {
        case loading
        case filled
    }
    struct Input {
        var isAuthorized: () -> Bool
		var isDemo: () -> Bool
        var anonymousSos: AnonymousSos?
		var data: (_ useCache: Bool, _ completion: @escaping (Result<InsuranceMain, AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        var select: (SosModel) -> Void
		var demo: () -> Void
		var addOrEditConfidant: (Confidant?) -> Void
        var callPhone: (String, String) -> Void
    }

    var input: Input!
    var output: Output!
    
    struct Notify {
        var updateViewUserInteractionEnabled: () -> Void
        var updateWithState: (_ state: State) -> Void
		var updateConfidant: () -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateViewUserInteractionEnabled: { [weak self] in
            self?.view.isUserInteractionEnabled = true
        },
        updateWithState: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(with: state)
        },
		updateConfidant: { [weak self] in
			guard let self = self,
				  self.isViewLoaded
			else { return }
			
			getInsuranceMain(usedCahced: false)
		}
    )
    
    private var tableView: UITableView = .init(
        frame: .zero,
        style: .grouped
    )
    private let operationStatusView = OperationStatusView()
    
    private var insuranceMain: InsuranceMain?
    private var firstWillAppear = true
    private var state: State?
	private var sections: [Section] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstWillAppear {
			getInsuranceMain(usedCahced: true)
            firstWillAppear = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addZeroView()
        setupUI()
    }

	private func getInsuranceMain(usedCahced: Bool) {
        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        input.data(usedCahced, { [weak self] result in
            guard let self = self
            else { return }
            
            switch result {
                case .success(let insuranceMain):
                    self.insuranceMain = insuranceMain
                    self.title = insuranceMain.sosEmergencyCommunication?.title ?? ""
                    self.hideZeroView()
                    self.tableView.isHidden = insuranceMain == nil
					self.getSections()
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    if let anonymousSos = self.input.anonymousSos {
                        self.title = anonymousSos.sosEmergencyCommunication?.title
                        self.hideZeroView()
                        self.tableView.isHidden = false
						self.getSections()
                        self.tableView.reloadData()
                    }
                    else {
                        let zeroViewModel = ZeroViewModel(
                            kind: .error(
                                error,
                                retry: .init(
                                    kind: .always,
                                    action: { [weak self] in
										self?.getInsuranceMain(usedCahced: usedCahced)
                                    }
                                )
                            )
                        )
                        self.zeroView?.update(viewModel: zeroViewModel)
                        self.showZeroView()
                        self.processError(error)
                    }
            }
        }
		)
    }
	
	func getSections()
	{
		sections = []
		
		if let insuranceMain = insuranceMain
		{
			if !insuranceMain.sosList.isEmpty
			{
				sections.append(.sos)
			}
			
			if input.isAuthorized() && (insuranceMain.sosEmergencyCommunication?.confidant != nil || insuranceMain.sosEmergencyCommunication?.confidantBanner != nil )
			{
				sections.append(.confidant)
			}
			
			if insuranceMain.sosEmergencyCommunication != nil
			{
				sections.append(.sosEmergencyCommunication)
			}
		}
	}
    
    private func update(with state: State) {
        self.state = state
        switch state {
            case .loading:
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("common_load", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
            case .filled:
                operationStatusView.isHidden = true
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .Background.backgroundContent
        
        setupTableView()
        setupOperationStatusView()
    }
    
    private func setupTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(SosTableViewCell.id)
        tableView.registerReusableCell(EmergencyСommunicationTableViewCell.id)
		tableView.registerReusableCell(ConfidantTableCell.id)
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        operationStatusView.isHidden = true
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: operationStatusView, in: view)
        )
    }
    
    private func createEmergencyСommunicationHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let label = UILabel()
        label <~ Style.Label.primaryTitle1
        label.numberOfLines = 1
        label.textAlignment = .left
        label.text = NSLocalizedString("sos_emergency_communication_title", comment: "")
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 9),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -9)
        ])
        
        return view
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int 
	{
		sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		guard let section = sections[safe: section]
		else { return CGFloat.leastNormalMagnitude }
		
		switch section
		{
			case .sos,
				 .confidant:
				return CGFloat.leastNormalMagnitude
			
			case .sosEmergencyCommunication:
				return 48
		}
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let section = sections[safe: section]
		else { return nil }
		
		switch section
		{
			case .sos,
				 .confidant:
				return nil
			
			case .sosEmergencyCommunication:
				return createEmergencyСommunicationHeaderView()
		}
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = sections[safe: section]
		else { return 0 }
		
		switch section
		{
			case .sos,
				 .confidant:
				return 1
			
			case .sosEmergencyCommunication:
				return getSosEmergencyCommunicationCount()
		}
    }
    
    func getSosEmergencyCommunicationCount() -> Int {
        if input.isAuthorized() {
            return insuranceMain?.sosEmergencyCommunication?.communicationBlock?.itemList.count ?? 0
        }
        else {
            return input.anonymousSos?.sosEmergencyCommunication?.communicationBlock?.itemList.count ?? 0
        }
    }
    
    func getSosList() -> [SosModel]? {
        if input.isAuthorized() {
            return insuranceMain?.sosList
        }
        else {
            return input.anonymousSos?.sosList
        }
    }
    
    func getSosEmergencyCommunicationItems() -> [SosEmergencyCommunicationItem]? {
        if input.isAuthorized() {
            return insuranceMain?.sosEmergencyCommunication?.communicationBlock?.itemList
        }
        else {
            return input.anonymousSos?.sosEmergencyCommunication?.communicationBlock?.itemList
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		guard let section = sections[safe: indexPath.section]
		else { return UITableViewCell() }
		
		switch section
		{
			case .sos:
				return getSosTableViewCell()
			
			case .confidant:
				return getConfidantTableCell()
			
			case .sosEmergencyCommunication:
				return getEmergencyСommunicationTableViewCell(indexPath: indexPath)
		}
    }
	
	private func getSosTableViewCell() -> UITableViewCell
	{
		guard let sosList = getSosList()
		else { return UITableViewCell() }
		
		let cell = tableView.dequeueReusableCell(SosTableViewCell.id)
		cell.selectionStyle = .none

		var iconURL: URL?
		if let information = insuranceMain?.sosEmergencyCommunication?.information {
			iconURL = information.iconThemed?.url(for: traitCollection.userInterfaceStyle)
				?? URL(string: information.icon)
		}
		
		cell.configure(
			sosListAndColors: sosList.flatMap {
				SosModelAndIconURL(
					sosModel: $0,
					iconURL: $0.insuranceCategory?.iconThemed?.url(for: traitCollection.userInterfaceStyle)
						?? URL(string: $0.insuranceCategory?.icon ?? "")
				)
			},
			iconURL: iconURL,
			information: insuranceMain?.sosEmergencyCommunication?.information
		)
		
		cell.tapCallback = { [weak self] in
			guard let self = self
			else { return }
			self.view.isUserInteractionEnabled = false
			self.output.select($0)
		}
		
		return cell
	}
	
	private func getConfidantTableCell() -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(ConfidantTableCell.id)
		cell.selectionStyle = .none
		cell.configure(
			confidant: insuranceMain?.sosEmergencyCommunication?.confidant,
			confidantBanner: insuranceMain?.sosEmergencyCommunication?.confidantBanner,
			tapEditCallback: output.addOrEditConfidant,
			tapCallCallback: {
				[weak self] phone in
				
				self?.output.callPhone(phone, phone)
			},
			tapAddCallback: {
				[weak self] in
				
				self?.output.addOrEditConfidant(nil)
			}
		)
		
		return cell
	}
	
	private func getEmergencyСommunicationTableViewCell(indexPath: IndexPath) -> UITableViewCell
	{
		guard let itemList = getSosEmergencyCommunicationItems(),
			  let item = itemList[safe: indexPath.row]
		else { return UITableViewCell() }
					
		let cell = tableView.dequeueReusableCell(EmergencyСommunicationTableViewCell.id)
		cell.selectionStyle = .none
		
		cell.configure(
			item: item,
			rightIconURL: item.rightIconThemed?.url(for: traitCollection.userInterfaceStyle)
				?? URL(string: item.rightIcon),
			iconURL: item.iconThemed?.url(for: traitCollection.userInterfaceStyle)
				?? URL(string: item.icon),
			isLastItem: indexPath.row == itemList.count - 1
		)
		
		return cell
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch sections[indexPath.section]
		{
			case .sos,
				 .confidant:
				break
			
			case .sosEmergencyCommunication:
				guard let item = getSosEmergencyCommunicationItems()?[safe: indexPath.row]
				else { return }
			
				output.callPhone(item.titlePopup, item.phone.phoneNumber)
		}
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
