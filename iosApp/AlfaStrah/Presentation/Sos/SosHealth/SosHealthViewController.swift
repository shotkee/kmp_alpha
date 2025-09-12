//
//  SosHealthViewController.swift
//  AlfaStrah
//
//  Created by Makson on 27.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class SosHealthViewController: ViewController,
                               UITableViewDelegate,
                               UITableViewDataSource {
    enum Scenario {
        case insured([SosInsured])
        case typeInsurance([InsuranceType])
        case typeConnection([Phone], [VoipCall])
    }
    
    var input: Input!
    var output: Output!
   
    struct Input {
        let scenario: Scenario
    }
    
    struct Output {
        let showInsurancesType: (([InsuranceType]) -> Void)?
        let showTypeConnection: (([Phone], [VoipCall]) -> Void)?
        let showAlertCall: (([Phone]) -> Void)?
        let showAlerVoipCall: (([VoipCall]) -> Void)?
    }
    
    // MARK: - Outlets
    private var tableView = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("sos_health_title", comment: "")
        
        setupTableView()
    }
    
    private func setupTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(SosHealthInsuredTableViewCell.id)
        tableView.registerReusableCell(SosTypeInsuredTableViewCell.id)
        tableView.registerReusableCell(SosHealthTypeConnectionTableViewCell.id)
        view.addSubview(tableView)
        tableView.edgesToSuperview()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch input.scenario {
            case .insured:
                return 54
            case .typeInsurance,
                 .typeConnection:
                return 84
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch input.scenario {
            case .insured:
                return createHeaderView(
                    title: NSLocalizedString("sos_health_one_title", comment: "")
                )
            case .typeInsurance:
                return createHeaderView(
                    title: NSLocalizedString("sos_health_second_title", comment: "")
                )
            case .typeConnection:
                return createHeaderView(
                    title: NSLocalizedString("sos_health_third_title", comment: "")
                )
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch input.scenario {
            case .insured(let insured):
                return insured.count
            case .typeInsurance(let types):
                return types.count
            case .typeConnection(let phones, let voipCalls):
                let phonesIsEmpty = phones.isEmpty
                let voipCallsIsEmpty = voipCalls.isEmpty
                
                if !phonesIsEmpty && !voipCallsIsEmpty {
                    return 2
                } else {
                    return 1
                }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch input.scenario {
            case .insured(let insureds):
                guard let insured = insureds[safe: indexPath.row]
                else { return UITableViewCell() }
            
                return createSosHealthInsuredTableViewCell(
                    title: insured.title,
                    description: insured.fullName
                )
            case .typeInsurance(let types):
                guard let title = types[safe: indexPath.row]?.title
                else { return UITableViewCell() }
            
                return createSosTypeInsuredTableViewCell(
                    title: title
                )
            case .typeConnection(let phones, let voipCalls):
                if !phones.isEmpty, indexPath.row == 0 {
                    return createSosHealthTypeConnectionTableViewCell(
                        phones: phones
                    )
                }
                else if !voipCalls.isEmpty {
                    return createSosHealthTypeConnectionTableViewCell(
                        voipCalls: voipCalls
                    )
                }
                else {
                    return UITableViewCell()
                }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch input.scenario {
            case .insured(let insureds):
                guard let insuranceTypes = insureds[safe: indexPath.row]?.insuranceTypes
                else { return }
                
                if insuranceTypes.count > 1 {
                    output.showInsurancesType?(insuranceTypes)
                } else if let insuranceType = insuranceTypes.first, !insuranceType.phones.isEmpty {
                    output.showAlertCall?(insuranceType.phones)
                }
                
            case .typeInsurance(let types):
                guard let selectedType = types[safe: indexPath.row]
                else { return }
                
                let phonesIsEmpty = selectedType.phones.isEmpty
                let voipCallsIsEmpty = selectedType.voipCalls.isEmpty
            
                if !phonesIsEmpty && !voipCallsIsEmpty {
                    output.showTypeConnection?(selectedType.phones, selectedType.voipCalls)
                } else if !phonesIsEmpty {
                    output.showAlertCall?(selectedType.phones)
                }
                
            case .typeConnection(let phones, let voipCalls):
                if !phones.isEmpty, indexPath.row == 0 {
                    output.showAlertCall?(phones)
                } else if !voipCalls.isEmpty {
                    output.showAlerVoipCall?(voipCalls)
                }
        }
    }
    
    private func createSosHealthInsuredTableViewCell(
        title: String,
        description: String
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            SosHealthInsuredTableViewCell.id
        )
        cell.selectionStyle = .none
        cell.configure(
            title: title,
            description: description
        )
        
        return cell
    }
    
    private func createSosTypeInsuredTableViewCell(
        title: String
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            SosTypeInsuredTableViewCell.id
        )
        cell.selectionStyle = .none
        cell.configure(
            title: title
        )
        
        return cell
    }
    
    private func createSosHealthTypeConnectionTableViewCell(
        phones: [Phone]
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            SosHealthTypeConnectionTableViewCell.id
        )
        cell.selectionStyle = .none
        cell.configure(
            type: .call
        )
        
        return cell
    }
    
    private func createSosHealthTypeConnectionTableViewCell(
        voipCalls: [VoipCall]
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            SosHealthTypeConnectionTableViewCell.id
        )
        cell.selectionStyle = .none
        cell.configure(
            type: .onlineCall
        )
        
        return cell
    }
    
    private func createHeaderView(title: String ) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.text = title
        view.addSubview(titleLabel)
        titleLabel.topToSuperview(offset: 21)
        titleLabel.leadingToSuperview(offset: 18)
        titleLabel.trailingToSuperview(offset: 18)
        titleLabel.bottomToSuperview(offset: -3)
        
        return view
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
