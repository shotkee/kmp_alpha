//
//  QuestionnaireViewController.swift
//  AlfaStrah
//
//  Created by Makson on 20.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class QuestionnaireViewController: ViewController,
								   UITableViewDelegate,
								   UITableViewDataSource {
    enum TableSection {
        case needDoctor([SectionsCardView.Item])
        case yourAddress([SectionsCardView.Item])
        case callInformation([SectionsCardView.Item])
    }
    
    var input: Input!
    var output: Output!
    
    struct Input {
        let insuranceId: String
        var doctorCall: BackendDoctorCall
    }
    
    struct Output {
        let showNotificationChildrenQuestionnaire: (BackendBannerData) -> Void
        let close: () -> Void
        let selectedDate: (Int, [String], _ completion: @escaping (Int) -> Void) -> Void
        let updatePhone: (String?, _ completion: @escaping (String) -> Void) -> Void
        let updateSymptoms: (String?, _ completion: @escaping (String) -> Void) -> Void
        let updateAddress: (String?, _ completion: @escaping (String) -> Void) -> Void
        let sendQuestionnaire: (DoctorAppointmentRequest) -> Void
    }
    
    // MARK: - Outlets
    private var tableView: UITableView = .init(
        frame: .zero,
        style: .grouped
    )
    
    private lazy var sendButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("questionnaire_send_request_button", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()
    
    // MARK: - Variables
    private var tableSections: [TableSection] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var firstWillAppear = true
    private var address: String = ""
    private var selectedIndexDate = 0
    private var symptoms = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstWillAppear && input.doctorCall.forChild {
            guard let childDoctorBanner = input.doctorCall.childDoctorBanner
            else { return }
            
            output.showNotificationChildrenQuestionnaire(childDoctorBanner)
            firstWillAppear = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("questionnaire_title", comment: "")
        addRightButton(
			image: .Icons.cross,
            action: output.close
        )
        setupTableView()
        createSectionArray()
        setupSendButton()
        setEnabledSendButton()
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
        tableView.registerReusableCell(QuestionnaireTableViewCell.id)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        view.addSubview(tableView)
        tableView.edgesToSuperview()
    }
    
    private func setupSendButton() {
        view.addSubview(sendButton)
        sendButton.leadingToSuperview(offset: 18)
        sendButton.trailingToSuperview(offset: 18)
        sendButton.bottomToSuperview(offset: -15, usingSafeArea: true)
        sendButton.height(48)
    }
    
    private func setEnabledSendButton() {
        sendButton.isEnabled = !input.doctorCall.userPhoneNumber.isEmpty && !address.isEmpty && !symptoms.isEmpty
    }
    
    private func createSectionArray() {
        tableSections = [
            .needDoctor(
                [
                    .init(
                        title: NSLocalizedString("questionnaire_initials_title", comment: ""),
                        placeholder: NSLocalizedString("questionnaire_initials_title", comment: ""),
                        value: input.doctorCall.userFullname,
                        icon: .empty,
                        stateAppearance: .noPossibilityEdit,
                        isEnabled: false,
                        tapHandler: nil
                    ),
                    .init(
                        title: NSLocalizedString("questionnaire_phone_title", comment: ""),
                        placeholder: NSLocalizedString("questionnaire_phone_title", comment: ""),
                        value: input.doctorCall.userPhoneNumber,
                        icon: .rightArrow,
                        isEnabled: true,
                        tapHandler: { [weak self] in
                            guard let self = self
                            else { return }
                            
                            self.output.updatePhone(
                                self.input.doctorCall.userPhoneNumber
                            )
                            { [weak self] phone in
                                self?.input.doctorCall.userPhoneNumber = phone
                                self?.updateTableView()
                            }
                        }
                    )
                ]
            ),
            .yourAddress(
                getAddressArray()
            ),
            .callInformation(
                [
                    .init(
                        title: NSLocalizedString("questionnaire_speciality_title", comment: ""),
                        placeholder: NSLocalizedString("questionnaire_speciality_title", comment: ""),
                        value: input.doctorCall.doctorSpeciality,
                        icon: .empty,
                        stateAppearance: .noPossibilityEdit,
                        isEnabled: false,
                        tapHandler: nil
                    ),
                    .init(
                        title: NSLocalizedString("questionnaire_date_visit_title", comment: ""),
                        placeholder: NSLocalizedString("questionnaire_date_visit_title", comment: ""),
                        value: getVisitDateString(),
                        icon: input.doctorCall.visitDates.count > 1
                            ? .rightArrow
                            : .empty
                        ,
                        stateAppearance: input.doctorCall.visitDates.count > 1
                            ? .regular
                            : .noPossibilityEdit
                        ,
                        isEnabled: input.doctorCall.visitDates.count > 1,
                        tapHandler: { [weak self] in
                            guard let self = self
                            else { return }
                            
                            self.output.selectedDate(
                                self.selectedIndexDate,
                                self.input.doctorCall.visitDates.map { $0.dateString }
                            )
                            { [weak self] indexDate in
                                self?.selectedIndexDate = indexDate
                                self?.updateTableView()
                            }
                        }
                    ),
                    .init(
                        title: NSLocalizedString("questionnaire_sick_list_title", comment: ""),
                        placeholder: NSLocalizedString("questionnaire_sick_list_title", comment: ""),
                        value: input.doctorCall.medicalLeaveIsRequiredTitle,
                        icon: .empty,
                        stateAppearance: .noPossibilityEdit,
                        isEnabled: false,
                        tapHandler: nil
                    ),
                    .init(
                        title: NSLocalizedString("questionnaire_symptoms_title", comment: ""),
                        placeholder: NSLocalizedString("questionnaire_symptoms_title", comment: ""),
                        value: symptoms,
                        icon: .rightArrow,
                        isEnabled: true,
                        tapHandler: { [weak self] in
                            guard let self = self
                            else { return }
                            
                            self.output.updateSymptoms(
                                self.symptoms
                            )
                            { [weak self] symptoms in
                                self?.symptoms = symptoms
                                self?.updateTableView()
                            }
                        }
                    )
                ]
            )
        ]
    }
    
    private func getAddressArray() -> [SectionsCardView.Item] {
        var array: [SectionsCardView.Item] = []
        
        if let distanceTitle = input.doctorCall.distanceTitle {
            array.append(
                .init(
                    title: NSLocalizedString("questionnaire_location_title", comment: ""),
                    placeholder: NSLocalizedString("questionnaire_location_title", comment: ""),
                    value: distanceTitle,
                    icon: .empty,
                    stateAppearance: .noPossibilityEdit,
                    isEnabled: false,
                    tapHandler: nil
                )
            )
        }
        
        array.append(
            .init(
                title: NSLocalizedString("questionnaire_address_title", comment: ""),
                placeholder: NSLocalizedString("questionnaire_address_title", comment: ""),
                value: address,
                icon: .rightArrow,
                isEnabled: true,
                tapHandler: { [weak self] in
                    guard let self = self
                    else { return }
                
                    self.output.updateAddress(
                        self.address
                    )
                    { [weak self] address in
                        self?.address = address
                        self?.updateTableView()
                    }
                }
            )
        )
        
        return array
    }
    
    private func updateTableView() {
        createSectionArray()
        tableView.reloadData()
        setEnabledSendButton()
    }
    
    private func getVisitDateString() -> String {
        return input.doctorCall.visitDates[safe: selectedIndexDate]?.dateString ?? ""
    }
    
    @objc func sendButtonAction() {
        guard let visitDate = input.doctorCall.visitDates[safe: selectedIndexDate]?.date
        else { return }
    
        self.output.sendQuestionnaire(
            .init(
                insuranceId: input.insuranceId,
                userFullame: input.doctorCall.userFullname,
                symptoms: symptoms,
                userPhone: input.doctorCall.userPhoneNumber,
                userAddress: address,
                doctorSpeciality: input.doctorCall.doctorSpeciality,
                distanceType: input.doctorCall.distanceType,
                medicalLeaveIsRequiredTitle: input.doctorCall.medicalLeaveIsRequiredTitle,
                visitDate: visitDate
            )
        )
    }
	
	// MARK: - UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        tableSections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = tableSections[safe: section]
        else { return nil }
        
        switch section {
            case .needDoctor:
                return createHeaderView(
                    title: NSLocalizedString("questionnaire_who_needs_doctor", comment: "")
                )
            
            case .yourAddress:
                return createHeaderView(
                    title: NSLocalizedString("questionnaire_your_address", comment: "")
                )
            
            case .callInformation:
                return createHeaderView(
                    title: NSLocalizedString("questionnaire_call_information", comment: "")
                )
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        36
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableSections[safe: section] != nil
        else { return 0 }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = tableSections[safe: indexPath.section]
        else { return UITableViewCell() }
        
        switch section {
            case .needDoctor(let items):
                let cell = tableView.dequeueReusableCell(QuestionnaireTableViewCell.id)
                cell.configure(
                    items: items,
                    description: input.doctorCall.forChild
                        ? NSLocalizedString("questionnaire_children_info", comment: "")
                        : nil,
                    typeCell: .needDoctor
                )
            
                return cell
            
            case .yourAddress(let items):
                let cell = tableView.dequeueReusableCell(QuestionnaireTableViewCell.id)
                cell.configure(
                    items: items,
                    typeCell: .yourAddress
                )
        
                return cell
            
            case .callInformation(let items):
                let cell = tableView.dequeueReusableCell(QuestionnaireTableViewCell.id)
                cell.configure(
                    items: items,
                    warningText: input.doctorCall.additionalInfo,
                    typeCell: .callInformation
                )
        
                return cell
        }
    }
    
    private func createHeaderView(title: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let label = UILabel()
        label <~ Style.Label.primaryHeadline1
        label.numberOfLines = 1
        label.text = title
        
        view.addSubview(label)
        label.bottomToSuperview()
        label.leadingToSuperview(offset: 18)
        label.trailingToSuperview(offset: -18)
        label.topToSuperview(offset: 15)
        
        return view
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
