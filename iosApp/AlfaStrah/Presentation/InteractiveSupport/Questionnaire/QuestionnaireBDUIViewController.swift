//
//  QuestionnaireBDUIViewController.swift
//  AlfaStrah
//
//  Created by vit on 29.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class QuestionnaireBDUIViewController: ViewController,
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
		var doctorCall: DoctorCallBDUI
	}
	
	struct Output {
		let showNotificationChildrenQuestionnaire: () -> Void
		let close: () -> Void
		let selectedDate: (Int, [String], _ completion: @escaping (Int) -> Void) -> Void
		let updatePhone: (String?, _ completion: @escaping (String) -> Void) -> Void
		let updateSymptoms: (String?, _ completion: @escaping (String) -> Void) -> Void
		let updateAddress: (String?, _ completion: @escaping (String) -> Void) -> Void
		let updateDistanceType: (Int, [String], _ completion: @escaping (Int) -> Void) -> Void
		let updateMedicalLeaveAnswer: (Int, [String], _ completion: @escaping (Int) -> Void) -> Void
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
	
	private struct DoctorAppointment {
		var insuranceId: String?
		var userFullname: String?
		var address: String?
		var distanceType: String?
		var visitDate: String?
		var symptoms: String?
		var medicalLeaveAnswer: String?
		var userPhoneNumber: String?
		var doctorSpeciality: String?
		
		var isFilled: Bool {
			let values: [Any?] = [
				insuranceId,
				userFullname,
				address,
				distanceType,
				visitDate,
				userPhoneNumber,
				medicalLeaveAnswer,
				symptoms,
				doctorSpeciality
			]
			return !values.contains { $0 == nil }
		}
	}

	private var doctorAppointment: DoctorAppointment = .init() {
		didSet {
			sendButton.isEnabled = doctorAppointment.isFilled
			
			self.updateTableView()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if firstWillAppear && input.doctorCall.forChild {
			output.showNotificationChildrenQuestionnaire()
			firstWillAppear = false
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		doctorAppointment.insuranceId = String(input.doctorCall.insuranceId)
		doctorAppointment.userFullname = input.doctorCall.userFullname
		doctorAppointment.userPhoneNumber = input.doctorCall.userPhoneNumber
		doctorAppointment.doctorSpeciality = input.doctorCall.doctorSpeciality
		
		doctorAppointment.visitDate = input.doctorCall.visitDates.first?.dateString
		
		doctorAppointment.medicalLeaveAnswer = input.doctorCall.medicalLeaveAnswers.count > 1
			? nil
			: input.doctorCall.medicalLeaveAnswers.first
		
		doctorAppointment.distanceType = input.doctorCall.distanceType.count > 1
			? nil
			: input.doctorCall.distanceType.first
		
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
		
	private func createSectionArray() {
		tableSections = [
			.needDoctor(
				[
					.init(
						title: NSLocalizedString("questionnaire_initials_title", comment: ""),
						placeholder: NSLocalizedString("questionnaire_initials_title", comment: ""),
						value: doctorAppointment.userFullname,
						icon: .empty,
						stateAppearance: .noPossibilityEdit,
						isEnabled: false,
						tapHandler: nil
					),
					.init(
						title: NSLocalizedString("questionnaire_phone_title", comment: ""),
						placeholder: NSLocalizedString("questionnaire_phone_title", comment: ""),
						value: doctorAppointment.userPhoneNumber,
						icon: .rightArrow,
						isEnabled: true,
						tapHandler: { [weak self] in
							guard let self
							else { return }
							
							self.output.updatePhone(
								self.doctorAppointment.userPhoneNumber
							)
							{ [weak self] phone in
								self?.doctorAppointment.userPhoneNumber = phone
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
						value: doctorAppointment.doctorSpeciality,
						icon: .empty,
						stateAppearance: .noPossibilityEdit,
						isEnabled: false,
						tapHandler: nil
					),
					.init(
						title: NSLocalizedString("questionnaire_date_visit_title", comment: ""),
						placeholder: NSLocalizedString("questionnaire_date_visit_title", comment: ""),
						value: doctorAppointment.visitDate,
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
							guard let self
							else { return }
							
							self.output.selectedDate(
								self.input.doctorCall.visitDates.firstIndex(where: { $0.dateString == self.doctorAppointment.visitDate }) ?? 0,
								self.input.doctorCall.visitDates.map { $0.dateString }
							)
							{ [weak self] index in
								self?.doctorAppointment.visitDate = self?.input.doctorCall.visitDates[safe: index]?.dateString
							}
						}
					),
					.init(
						title: NSLocalizedString("questionnaire_sick_list_title", comment: ""),
						placeholder: NSLocalizedString("questionnaire_sick_list_title", comment: ""),
						value: doctorAppointment.medicalLeaveAnswer,
						icon: input.doctorCall.medicalLeaveAnswers.count > 1
							? .rightArrow
							: .empty
						,
						stateAppearance: input.doctorCall.medicalLeaveAnswers.count > 1
							? .regular
							: .noPossibilityEdit
						,
						isEnabled: true,
						tapHandler: { [weak self] in
							guard let self
							else { return }
							
							self.output.updateMedicalLeaveAnswer(
								self.input.doctorCall.medicalLeaveAnswers.firstIndex(where: { $0 == self.doctorAppointment.medicalLeaveAnswer }) ?? 0,
								self.input.doctorCall.medicalLeaveAnswers
							)
							{ [weak self] index in
								self?.doctorAppointment.medicalLeaveAnswer = self?.input.doctorCall.medicalLeaveAnswers[safe: index]
							}
						}
					),
					.init(
						title: NSLocalizedString("questionnaire_symptoms_title", comment: ""),
						placeholder: NSLocalizedString("questionnaire_symptoms_title", comment: ""),
						value: doctorAppointment.symptoms,
						icon: .rightArrow,
						isEnabled: true,
						tapHandler: { [weak self] in
							guard let self
							else { return }
							
							self.output.updateSymptoms(
								self.doctorAppointment.symptoms
							) { [weak self] symptoms in
								self?.doctorAppointment.symptoms = symptoms
							}
						}
					)
				]
			)
		]
	}
	
	private func getAddressArray() -> [SectionsCardView.Item] {
		var array: [SectionsCardView.Item] = []
		
		array.append(
			.init(
				title: NSLocalizedString("questionnaire_location_title", comment: ""),
				placeholder: NSLocalizedString("questionnaire_location_title", comment: ""),
				value: doctorAppointment.distanceType,
				icon: input.doctorCall.distanceType.count > 1
					? .rightArrow
					: .empty
				,
				stateAppearance: input.doctorCall.distanceType.count > 1
					? .regular
					: .noPossibilityEdit
				,
				isEnabled: true,
				tapHandler: { [weak self] in
					guard let self = self
					else { return }
					
					self.output.updateDistanceType(
						self.input.doctorCall.distanceType.firstIndex(where: { $0 == self.doctorAppointment.distanceType }) ?? 0,
						self.input.doctorCall.distanceType
					)
					{ [weak self] index in
						self?.doctorAppointment.distanceType = self?.input.doctorCall.distanceType[safe: index]
					}
				}
			)
		)
				
		array.append(
			.init(
				title: NSLocalizedString("questionnaire_address_title", comment: ""),
				placeholder: NSLocalizedString("questionnaire_address_title", comment: ""),
				value: doctorAppointment.address,
				icon: .rightArrow,
				isEnabled: true,
				tapHandler: { [weak self] in
					guard let self = self
					else { return }
				
					self.output.updateAddress(
						doctorAppointment.address
					)
					{ [weak self] address in
						self?.doctorAppointment.address = address
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
	}

	@objc func sendButtonAction() {
		guard let insuranceId = doctorAppointment.insuranceId,
			  let userFullname = doctorAppointment.userFullname,
			  let symptoms = doctorAppointment.symptoms,
			  let userPhoneNumber = doctorAppointment.userPhoneNumber,
			  let address = doctorAppointment.address,
			  let doctorSpeciality = doctorAppointment.doctorSpeciality,
			  let distanceType = doctorAppointment.distanceType,
			  let medicalLeaveAnswer = doctorAppointment.medicalLeaveAnswer,
			  let visitDate = input.doctorCall.visitDates.first(where: { $0.dateString == doctorAppointment.visitDate })?.date
		else { return }
		
		self.output.sendQuestionnaire(
			.init(
				insuranceId: insuranceId,
				userFullame: userFullname,
				symptoms: symptoms,
				userPhone: userPhoneNumber,
				userAddress: address,
				doctorSpeciality: doctorSpeciality,
				distanceType: distanceType,
				medicalLeaveIsRequiredTitle: medicalLeaveAnswer,
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
