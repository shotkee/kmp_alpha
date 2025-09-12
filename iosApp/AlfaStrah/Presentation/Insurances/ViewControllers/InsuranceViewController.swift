//
//  InsuranceViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable file_length
class InsuranceViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    private enum Constants {
        static let dmsInsuranceFranchiseProductId = "15"
    }

    @IBOutlet private var switchView: RMRStyledSwitch!
    @IBOutlet private var switchSection: UIView!
    @IBOutlet private var eventListContainerView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var actionButton: RoundEdgeButton!

    struct Input {
        var insurance: Insurance
        var category: InsuranceCategory
		var isDemo: Bool
        var canAddToPassbook: Bool
        var eventListController: UIViewController?
        var vzrOnOffDashboard: (@escaping (Result<VzrOnOffDashboardInfo?, AlfastrahError>) -> Void) -> Void
        var flatOnOffInsurance: (@escaping (Result<FlatOnOffInsurance, AlfastrahError>) -> Void) -> Void
        var flatOnOffBalance: (_ id: String, _ completion: @escaping (Result<Int, AlfastrahError>) -> Void) -> Void
		var hideTabSwitch: Bool?
		var initialSelectedTab: State?
		var title: String?
    }

    struct Output {
        var linkTap: (URL) -> Void
        var pdfLinkTap: (URL) -> Void
        var openBills: () -> Void
        var openGuaranteeLetters: () -> Void
        var phoneTap: (Phone) -> Void
        var renewInsurance: () -> Void
        var buyNewInsurance: () -> Void
        var makeChanges: () -> Void
        var osagoTerminate: () -> Void
        var vzrTerminate: () -> Void
        var addToPassbook: () -> Void
        var instructions: () -> Void
        var askQuestion: () -> Void
        var tripIntermediatePoints: (UIView) -> Void
        var createEvent: (String?) -> Void
        var telemedicine: () -> Void
        var callKidsDoctor: () -> Void
        var vzrBuyDays: () -> Void
        var vzrStartTrip: () -> Void
        var vzrTripList: () -> Void
        var vzrPurchaseList: () -> Void
        var vzrOnOffRequestPermissions: () -> Void
        var flatOnOffBuyDays: () -> Void
        var flatOnOffActivate: () -> Void
        var flatOnOffOpenActivations: () -> Void
        var flatOnOffOpenPurchases: () -> Void
        var changeFranchiseProgram: () -> Void
        var useVzrBonuses: () -> Void
        var vzrFranchiseCertificate: () -> Void
        var kaskoExtend: () -> Void
        var vzrRefundCertificate: () -> Void
        var dmsCostRecovery: () -> Void
        var openHealthAcademy: () -> Void
        var openInsuranceProgram: () -> Void
        var medicalCard: () -> Void
        var manageSubscription: () -> Void
        var appointBeneficiary: () -> Void
        var editInsuranceAgreement: () -> Void
		let insuranceInfoTap: () -> Void
		let tabSwitched: (Insurance) -> Void
		let demo: () -> Void
		let medicalServiceTap: (InfoField) -> Void
    }

    var input: Input!
    var output: Output!
    
    struct Notify {
        let insuranceUpdated: (Insurance) -> Void
    }
    
    private(set) lazy var notify = Notify(
        insuranceUpdated: { [weak self] insurance in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            guard insurance.id == self.input.insurance.id
            else { return }
            
            self.input.insurance = insurance
            
            self.updateData(
                insurance: insurance,
                category: self.input.category
            )
            self.tableView.reloadData()
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateData(insurance: input.insurance, category: input.category)
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vzrOnOffCell.map(refreshVzrOnOffCell)
        flatOnOffCell.map(refreshFlatOnOffCell)
    }

    private func setup() {
        view.backgroundColor = .Background.backgroundContent
        
		title = input.title ?? input.insurance.title
		
		// only needed for ios 15
		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 0
		}

        tableView.estimatedRowHeight = 102
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .Background.background
        tableView.separatorColor = .Stroke.divider

        if input.insurance.type == .vzr {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage.Icons.call,
                style: .plain,
                target: self,
                action: #selector(callEmergencyPhone)
            )
        }

        let rightSwitchTitle: String
        let actionButtonTitle: String
		let onTryToSwitchTab: (() -> Bool)?
		
        actionButton.isHidden = !input.insurance.canCreateInsuranceEvent
		switch input.insurance.insuranceEventKind {
			case .auto, .propetry:
				onTryToSwitchTab = nil
				switchSection.isHidden = input.hideTabSwitch ?? false
				actionButtonTitle = NSLocalizedString("insurance_create_title", comment: "")
				rightSwitchTitle = NSLocalizedString("insurance_loss_status", comment: "")
				
			case .passengers:
				onTryToSwitchTab = nil
				switchSection.isHidden = input.hideTabSwitch ?? false
				actionButtonTitle = NSLocalizedString("insurance_create_title", comment: "")
				rightSwitchTitle = NSLocalizedString("insurance_case", comment: "")
				
			case .doctorAppointment(let doctorAppointmentType):
				onTryToSwitchTab = { [weak self] in
					guard let self else {
						return true
					}
					
					if input.isDemo {
						output.demo()
						return false
					} else {
						return true
					}
				}
				
				switchSection.isHidden = input.hideTabSwitch ?? false
				rightSwitchTitle = NSLocalizedString("insurance_appointments", comment: "")
				
				switch doctorAppointmentType {
					case .doctorAppointment:
						actionButtonTitle = NSLocalizedString("insurance_create_title_dms", comment: "")
					case .interactiveSupport:
						actionButtonTitle = NSLocalizedString("insurance_create_interactive_support_action_title", comment: "")
				}
				
			case .accident:
				onTryToSwitchTab = nil
				switchView.isHidden = input.hideTabSwitch ?? false
				actionButtonTitle = NSLocalizedString("insurance_create_title_accident", comment: "")
				rightSwitchTitle = NSLocalizedString("insurance_cases", comment: "")
				
			case .vzr:
				onTryToSwitchTab = nil
				switchSection.isHidden = input.hideTabSwitch ?? false
				actionButtonTitle = NSLocalizedString("insurance_create_title_vzr", comment: "")
				rightSwitchTitle = NSLocalizedString("insurance_create_right_title_vzr", comment: "")
				
			case .none:
				onTryToSwitchTab = nil
				switchSection.isHidden = true
				actionButtonTitle = input.insurance.type == .life
					? NSLocalizedString("main_faq_title", comment: "")
					: ""
				rightSwitchTitle = ""
		}

        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        actionButton.setTitle(actionButtonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(createEventTap(_:)), for: .touchUpInside)
        
        switchView.style(
            leftTitle: NSLocalizedString("insurance_information", comment: ""),
            rightTitle: rightSwitchTitle,
            titleColor: .Text.textPrimary,
            backgroundColor: .Background.backgroundTertiary,
            selectedTitleColor: .Text.textContrast,
            selectedBackgroundColor: .Background.segmentedControlAccent
        )
		switchView.onTryToSwitchTab = onTryToSwitchTab
		
        output.vzrOnOffRequestPermissions()

        // Harcoded table view inset for action button (66 = 16 bottom inset from safe areа + 48 button height + extra 18 points).
        // This is needed because there is a layout bug in iOS<14 with stack view and table view clip to bounds = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 82, right: 0)
		
		if let initialSelectedTab = input.initialSelectedTab {
			state = initialSelectedTab
		}
    }
    
    private func add(childViewController: UIViewController, to view: UIView) {
        addChild(childViewController)
        childViewController.view.frame = view.bounds
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }

    enum State: Int {
        case insuranceInfo = 0
        case insuranceEvent = 1
    }

    private var state: State = .insuranceInfo {
        didSet {
            updateState()
        }
    }

    private func updateState() {
        switch state {
            case .insuranceInfo:
                break
            case .insuranceEvent:
                if eventListContainerView.subviews.isEmpty, let controller = input.eventListController {
                    add(childViewController: controller, to: eventListContainerView)
                }
        }

        tableView.isHidden = state != .insuranceInfo
        eventListContainerView.isHidden = state != .insuranceEvent
    }

    private func refreshVzrOnOffCell(_ cell: InsuranceVzrOnOffCell) {
        cell.notify.stateUpdated(.loading)
        cell.output = .init(
            buyDays: self.output.vzrBuyDays,
            startTrip: self.output.vzrStartTrip,
            tripList: self.output.vzrTripList,
            purchaseList: self.output.vzrPurchaseList
        )
        input.vzrOnOffDashboard { [weak self, weak cell] result in
            guard
                let self = self,
                let cell = cell
            else { return }

            cell.notify.stateUpdated(.loading)
            cell.output = .init(
                buyDays: self.output.vzrBuyDays,
                startTrip: self.output.vzrStartTrip,
                tripList: self.output.vzrTripList,
                purchaseList: self.output.vzrPurchaseList
            )
            switch result {
                case .success(let dashboardInfo):
                    if let info = dashboardInfo {
                        if let activeTrip = info.activeTripList.first(where: { $0.status == .active }) {
                            cell.notify.stateUpdated(.activeTrip(info.balance, activeTrip))
                        } else {
                            cell.notify.stateUpdated(.balance(info.balance))
                        }
                    } else {
                        cell.notify.stateUpdated(.error(nil))
                    }
                case .failure:
                    cell.notify.stateUpdated(.error({ self.refreshVzrOnOffCell(cell) }))
            }

            self.tableView.beginUpdates()
            cell.layoutIfNeeded()
            self.tableView.endUpdates()
        }
    }

    private func refreshFlatOnOffCell(_ cell: InsuranceFlatOnOffCell) {
        cell.notify.stateUpdated(.loading)
        cell.output = .init(
            openActivations: self.output.flatOnOffOpenActivations,
            openPurchases: self.output.flatOnOffOpenPurchases,
            buyDays: self.output.flatOnOffBuyDays,
            activate: self.output.flatOnOffActivate
        )
        updateCellLayout(cell)
        input.flatOnOffInsurance { [weak self, weak cell] result in
            guard let self = self, let cell = cell else { return }

            switch result {
                case .success(let insurance):
                    self.refreshFlatOnOffBalance(cell: cell, insurance: insurance)
                case .failure:
                    cell.notify.stateUpdated(.error(.basic, { self.refreshFlatOnOffCell(cell) }))
                    self.updateCellLayout(cell)
            }
        }
    }

    private func refreshFlatOnOffBalance(cell: InsuranceFlatOnOffCell, insurance: FlatOnOffInsurance) {
        cell.notify.stateUpdated(.loading)
        input.flatOnOffBalance(insurance.id) { [weak self, weak cell] result in
            guard let self = self, let cell = cell else { return }

            switch result {
                case .success(let balance):
                    if let active = insurance.protections.first(where: { $0.status == .active }) {
                        cell.notify.stateUpdated(.active(active.startDate, active.endDate, balance))
                    } else {
                        cell.notify.stateUpdated(.inactive(balance))
                    }
                case .failure(let error):
                    switch error.businessErrorKind {
                        case .flatOnOffRetryRequest:
                            cell.notify.stateUpdated(.error(.custom(error.title ?? "", error.message ?? ""), {
                                self.refreshFlatOnOffBalance(cell: cell, insurance: insurance)
                            }))
                        default:
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
            }
            self.updateCellLayout(cell)
        }
    }

    private func updateCellLayout(_ cell: UITableViewCell) {
        tableView.beginUpdates()
        cell.layoutIfNeeded()
        tableView.endUpdates()
    }

    private func configureOptionalFeatureCell(
        cell: InsuranceOptionalFeatureCell,
        title: String,
        description: String,
        buttonTitle: String,
        action: (() -> Void)?
    ) {
        cell.input = .init(title: title, description: description, buttonTitle: buttonTitle)
        cell.output = .init(action: action)
    }

    private struct ActionCellData {
        let title: String
        let icon: UIImage?
        let tapAction: TapAction
    }

    private struct InfoCellData {
		let infoField: InfoField?
        let title: String
        let subtitle: String
        var icon: UIImage?
        var iconTintColor: UIColor?
        let tapAction: TapAction
    }

    private enum TapAction {
        case none
        case url(URL)
        case openBills
        case guaranteeLetters
        case pdf(URL)
        case copyText(InfoField)
        case instructions
        case buyNewInsurance
        case renewInsurance
        case makeChanges
        case osagoTerminate
        case vzrTerminate
        case askQuestion
        case addToPassbook
        case tripIntermediatePoints
        case telemedicine
        case kidsDoctorCall
        case phone(Phone)
        case doctorAppointment(filter: String)
        case changeFranchiseProgram
        case useVzrBonuses
        case vzrFranchiseCertificate
        case kaskoExtend
        case vzrRefundCertificate
        case dmsCostRecovery
        case healthAcademy
        case insuranceProgram
        case medicalCard
        case manageSubscription
        case appointBeneficiary
        case editInsuranceAgreement
    }
    
    private enum TableSection {
        case dmsInsuranceInfo(String)
        case action(cells: [ActionCellData])
        case telemedicine
        case vzrOnOff
        case flatOnOff
        case kidsDoctorCall
        case info(title: String, cells: [InfoCellData])
    }

    private var sections: [TableSection] = []
    private weak var vzrOnOffCell: InsuranceVzrOnOffCell?
    private weak var flatOnOffCell: InsuranceFlatOnOffCell?
    
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable:next function_body_length
    private func updateData(insurance: Insurance, category: InsuranceCategory) {
        sections = []
        
        if insurance.type == .dms {
            if insurance.isArchive {
                sections.append(.dmsInsuranceInfo(
                    NSLocalizedString("insurance_dms_info_message_appointment_not_available", comment: "")
                ))
            } else if insurance.startDate > Date() { // insurance period has not started yet
                sections.append(.dmsInsuranceInfo(
                    NSLocalizedString("insurance_dms_info_message_appointment_will_be_available", comment: "")
                ))
            }
        }

        // Configure actions section
        var actionCells: [ActionCellData] = []
        let canRenew = input.insurance.renewAvailable ?? false
        let renewAvailable = input.insurance.type == .osago
            ? canRenew && (input.insurance.osagoRenewStatus ?? .notAvailable) != .notAvailable
            : canRenew
        if renewAvailable {
            let title = NSLocalizedString("insurance_renew_without_changes", comment: "")
            actionCells.append(ActionCellData(
                title: title,
                icon: UIImage.Icons.wallet,
                tapAction: .renewInsurance
            ))
        }
        
        if input.insurance.isEditInsuranceAgreementAvailable {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("marks_web_edit_insurance_agreement", comment: ""),
                icon: UIImage(named: "insurance-action-edit-insurance-agreement"),
                tapAction: .editInsuranceAgreement
            ))
        }
    
        if input.insurance.isAppointBeneficiaryAvailable {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("marks_web_appoint_beneficiary", comment: ""),
				icon: .Icons.profileSettings.tintedImage(withColor: .Icons.iconAccent),
                tapAction: .appointBeneficiary
            ))
        }
        
        if input.insurance.isManageSubscriptionAvailable {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("marks_web_manage_subscription", comment: ""),
                icon: UIImage(named: "insurance-action-manage-subscription"),
                tapAction: .manageSubscription
            ))
        }
        
        if input.insurance.type == .kasko && input.insurance.isKaskoPolicyExtensionAvailable {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("kasko_policy_extension", comment: ""),
                icon: .Icons.wallet.tintedImage(withColor: .Icons.iconAccent).resized(newWidth: 24),
                tapAction: .kaskoExtend
            ))
        }
        
        if input.insurance.type == .osago {
            if input.insurance.isOsagoChangeAvailable {
                actionCells.append(
                    ActionCellData(
                        title: NSLocalizedString("insurance_make_changes", comment: ""),
						icon: .Icons.wallet.tintedImage(withColor: .Icons.iconAccent).resized(newWidth: 24),
                        tapAction: .makeChanges
                    )
                )
            }
            
            if input.insurance.isOsagoTerminationAvailable {
                actionCells.append(
                    ActionCellData(
                        title: NSLocalizedString("insurance_terminate", comment: ""),
						icon: .Icons.walletPlus.tintedImage(withColor: .Icons.iconAccent),
                        tapAction: .osagoTerminate
                    )
                )
            }
        }

        if input.insurance.sosActivities.contains(.buyAgain) || input.insurance.sosActivities.contains(.buyNew) {
            actionCells.append(
				ActionCellData(
					title: NSLocalizedString("insurance_buy_new", comment: ""),
					icon: .Icons.walletPlus,
					tapAction: .buyNewInsurance
				)
			)
        }

        let passbookAvailable = (input.insurance.passbookAvailableOnline ?? false) || (input.insurance.passbookAvailable ?? false)
        if passbookAvailable && input.canAddToPassbook {
            actionCells.append(ActionCellData(title: NSLocalizedString("insurance_add_to_passbook", comment: ""),
				icon: .Icons.walletApple.tintedImage(withColor: .Icons.iconAccent), tapAction: .addToPassbook))
        }

        if insurance.productId == Constants.dmsInsuranceFranchiseProductId,
           insurance.type == .dms,
           input.insurance.shouldShowBills {
            actionCells.append(ActionCellData(title: NSLocalizedString("insurance_bills", comment: ""),
				icon: UIImage(named: "insurance-action-buy-franchise"), tapAction: .openBills))
        }

        if input.insurance.shouldShowGuaranteeLetters {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("insurance_letters_of_guarantee", comment: ""),
                icon: UIImage.Icons.guaranteeLetter,
                tapAction: .guaranteeLetters
            ))
        }

        var tapForInsuranceProgram: TapAction?
        
        switch input.insurance.helpType {
            case nil, .some(.none):
                tapForInsuranceProgram = nil
            case .some(.openFile):
                if let url = input.insurance.helpURL {
                    tapForInsuranceProgram = .pdf(url)
                }
            case .some(.blocks), .some(.blocksWithFile):
                tapForInsuranceProgram = .insuranceProgram
        }

        if let tapForInsuranceProgram {
            actionCells.append(
                ActionCellData(
                    title: NSLocalizedString("insurance_program", comment: ""),
                    icon: UIImage.Icons.document,
                    tapAction: tapForInsuranceProgram
                )
            )
        }

        if let url = input.insurance.pdfURL {
            actionCells.append(ActionCellData(title: NSLocalizedString("insurance_pdf_insurance", comment: ""),
                icon: UIImage.Icons.pdf, tapAction: .pdf(url)))
        }

        if input.insurance.type == .kasko {
            actionCells.append(ActionCellData(title: NSLocalizedString("insurance_ask_question", comment: ""),
                icon: UIImage(named: "insurance-action-askQuestion"), tapAction: .askQuestion))
        }
        
        if input.insurance.isDmsCostRecoveryAvailable {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("dms_cost_recovery", comment: ""),
                icon: UIImage(named: "insurance-action-cost-recovery"),
                tapAction: .dmsCostRecovery
            ))
        }
        
		if input.insurance.isFranchiseTransitionAvailable {
            actionCells.append(ActionCellData(title: NSLocalizedString("franchise_transition", comment: ""),
											  icon: .Icons.documentRefresh, tapAction: .changeFranchiseProgram))
		}
        
        if input.insurance.isMedicalCardAvailable {
            actionCells.append(
                ActionCellData(
                    title: NSLocalizedString("medical_card_menu_item_title", comment: ""),
                    icon: UIImage.Icons.documentPlus,
                    tapAction: .medicalCard
                )
            )
        }
                
        if input.insurance.isVzrBonusPolicyAvailable {
            actionCells.append(ActionCellData(title: NSLocalizedString("vzr_bonus_policies", comment: ""),
                icon: UIImage(named: "insurance-action-vzr-bonus"), tapAction: .useVzrBonuses))
        }

        if input.insurance.isVzrFranchiseCerificateAvailable {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("vzr_bonus_franchise_certificate", comment: ""),
                icon: UIImage(named: "insurance-action-vzr-franchise-certificate"),
                tapAction: .vzrFranchiseCertificate
            ))
        }
        
        if input.insurance.isVzrTerminationAvailable {
            actionCells.append(
                ActionCellData(
                    title: NSLocalizedString("vzr_terminate", comment: ""),
                    icon: UIImage(named: "vzr_terminate"),
                    tapAction: .vzrTerminate
                )
            )
        }
                
        if input.insurance.isVzrRefundCertificateAvailable {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("vzr_bonus_refund_cerificate", comment: ""),
                icon: UIImage(named: "insurance-action-manual"),
                tapAction: .vzrRefundCertificate
            ))
        }
        
        if input.insurance.type != .life {
            actionCells.append(ActionCellData(
                title: NSLocalizedString("insurance_instruction", comment: ""),
                icon: UIImage.Icons.document,
                tapAction: .instructions
            ))
        }
        
        if input.insurance.isHealthAcademyAvailable {
            actionCells.append(
                ActionCellData(
                    title: NSLocalizedString("insurance_health_academy", comment: ""),
                    icon: UIImage.Icons.tickInHeart,
                    tapAction: .healthAcademy
                )
            )
        }

        sections.append(.action(cells: actionCells))

        if input.insurance.isYandexEmployeeChild {
            sections.append(.kidsDoctorCall)
        }

        if input.insurance.telemedicine {
            sections.append(.telemedicine)
        }

        if input.insurance.type == .vzrOnOff {
            sections.append(.vzrOnOff)
        }

        if input.insurance.type == .flatOnOff {
            sections.append(.flatOnOff)
        }

        // Configure info sections
        for (index, sectionGroup) in insurance.fieldGroupList.enumerated() {
            var infoCells: [InfoCellData] = []
            for field in sectionGroup.fields {
                switch field.type {
                    case .text, .map:
                        infoCells.append(InfoCellData(
							infoField: field,
                            title: field.title,
                            subtitle: field.text,
                            tapAction: .copyText(field)
                        ))
                    case .link:
                        if let url = URL(string: field.text) {
                            infoCells.append(InfoCellData(
								infoField: field,
                                title: field.title,
                                subtitle: field.text,
                                tapAction: .url(url)
                            ))
                        } else {
                            infoCells.append(InfoCellData(
								infoField: field,
                                title: field.title,
                                subtitle: field.text,
                                tapAction: .none
                            ))
                        }
                    case .phone:
                        infoCells.append(InfoCellData(
							infoField: field,
                            title: field.title,
                            subtitle: field.text,
                            icon: UIImage(named: "icon-phone"),
                            iconTintColor: .Icons.iconAccent,
                            tapAction: .phone(input.insurance.emergencyPhone)
                        ))
                    case .clinicsList:
                        infoCells.append(InfoCellData(
							infoField: field,
                            title: field.title,
                            subtitle: field.text,
                            icon: UIImage(named: "icon-accessory-arrow-gray"),
                            iconTintColor: .Icons.iconSecondary,
                            tapAction: .doctorAppointment(filter: field.text)
                        ))
                }
            }

            // We are adding trip segments to the end of first group, if they are available
            if index == 0, let tripDeparture = insurance.tripDeparture, let tripArrival = insurance.tripArrival {
                infoCells.append(InfoCellData(
					infoField: nil,
                    title: NSLocalizedString("insurance_trip_departure", comment: ""),
                    subtitle: tripDeparture,
                    icon: nil,
                    iconTintColor: nil,
                    tapAction: .none
                ))
                if !insurance.tripIntermediatePoints.isEmpty {
                    infoCells.append(InfoCellData(
						infoField: nil,
                        title: "",
                        subtitle: NSLocalizedString("insurance_trip_intermediate", comment: ""),
                        icon: UIImage(named: "insurance-intermediate-points"),
                        iconTintColor: nil,
                        tapAction: .tripIntermediatePoints
                    ))
                }
                infoCells.append(InfoCellData(
					infoField: nil,
                    title: NSLocalizedString("insurance_trip_arrival", comment: ""),
                    subtitle: tripArrival,
                    icon: nil,
                    iconTintColor: nil,
                    tapAction: .none
                ))
            }

            sections.append(.info(title: sectionGroup.title, cells: infoCells))
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    // MARK: - Actions

    @objc func createEventTap(_ sender: UIButton) {
		let category = input.category
		
        switch category.kind {
            case .travel:
                analytics.track(event: AnalyticsEvent.Vzr.reportVzrPolicy)
            case .auto:
                analytics.track(event: AnalyticsEvent.Auto.reportAutoPolicy)
            case .health:
				break	// handle this event in flow
            case .passengers:
                analytics.track(event: AnalyticsEvent.Passenger.reportPassengersPolicy)
            case .none, .life, .property:
                break
        }
        output.createEvent(nil)
    }

    @objc private func callEmergencyPhone() {
        output.phoneTap(input.insurance.emergencyPhone)
    }

    @IBAction func switchTap(_ sender: RMRStyledSwitch) {
		guard let newState = State(rawValue: sender.selectedIndex)
		else { return }
		
		state = newState
		output.tabSwitched(input.insurance)
    }

    private func handleAction(_ action: TapAction, cell: UITableViewCell?) {
        switch action {
            case .none:
                break
				
            case .url(let url):
                output.linkTap(url)
				
            case .openBills:
                output.openBills()
				
            case .guaranteeLetters:
                output.openGuaranteeLetters()
				
            case .pdf(let url):
				if url == input.insurance.pdfURL {
					output.insuranceInfoTap()
				}
                output.pdfLinkTap(url)
				
            case .copyText(let field):
                let alertController = UIAlertController(title: field.title, message: nil,
                    preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(
                    title: NSLocalizedString("common_copy", comment: ""),
                    style: .default,
                    handler: { _ in
                        UIPasteboard.general.string = field.text
                    }
                ))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .destructive,
                    handler: nil))
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell?.bounds ?? CGRect(x: 1, y: 1, width: 1, height: 1)
                }
                present(alertController, animated: true, completion: nil)
				
            case .renewInsurance:
                output.renewInsurance()
				
            case .buyNewInsurance:
                output.buyNewInsurance()
				
            case .makeChanges:
                output.makeChanges()
				
            case .osagoTerminate:
                output.osagoTerminate()
				
            case .vzrTerminate:
                output.vzrTerminate()
				
            case .addToPassbook:
                output.addToPassbook()
				
            case .instructions:
                output.instructions()
				
            case .askQuestion:
                output.askQuestion()
				
            case .tripIntermediatePoints:
                cell.do(output.tripIntermediatePoints)
				
            case .telemedicine:
                output.telemedicine()
				
            case .kidsDoctorCall:
                output.callKidsDoctor()
				
            case .phone(let phone):
                output.phoneTap(phone)
				
            case .doctorAppointment(let filterName):
                output.createEvent(filterName)
				
            case .changeFranchiseProgram:
                output.changeFranchiseProgram()
				
            case .useVzrBonuses:
                output.useVzrBonuses()
				
            case .vzrFranchiseCertificate:
                output.vzrFranchiseCertificate()
				
            case .kaskoExtend:
                output.kaskoExtend()
				
            case .vzrRefundCertificate:
                output.vzrRefundCertificate()
				
            case .dmsCostRecovery:
                output.dmsCostRecovery()
				
            case .healthAcademy:
                output.openHealthAcademy()
				
            case .insuranceProgram:
                output.openInsuranceProgram()
				
            case .medicalCard:
                output.medicalCard()
				
            case .manageSubscription:
                output.manageSubscription()
				
            case .appointBeneficiary:
                output.appointBeneficiary()
				
            case .editInsuranceAgreement:
                output.editInsuranceAgreement()
				
        }
    }

    // MARK: - TableView data source & delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
            case .dmsInsuranceInfo, .telemedicine, .vzrOnOff, .flatOnOff, .kidsDoctorCall:
                return 1
            case .action(let rows):
                return rows.count
            case .info(_, let rows):
                return rows.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
            case .action:
                return 60
            default:
                return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
            case .dmsInsuranceInfo(let message):
                let cell = tableView.dequeueReusableCell(ArchiveDmsAlertCell.id)
                cell.set(title: message)
                cell.selectionStyle = .gray
                return cell
            case .action(let cells):
                let cellInfo = cells[indexPath.row]
                let cell = tableView.dequeueReusableCell(InsuranceActionCell.id)
				if indexPath.row == cells.count - 1 {
					cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
				}
                cell.configure(title: cellInfo.title, icon: cellInfo.icon, showRedDot: shouldShowRedDot(for: cellInfo))
                cell.selectionStyle = .none
                return cell
            case .info(_, let infoCells):
                let cellInfo = infoCells[indexPath.row]
                let cell = tableView.dequeueReusableCell(InsuranceInfoCell.id)
				if indexPath.row == infoCells.count - 1 {
					cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
				}
                switch cellInfo.tapAction {
                    case .none:
                        cell.set(
                            title: cellInfo.title,
                            text: cellInfo.subtitle,
                            kind: .text,
                            icon: cellInfo.icon,
                            iconTintColor: cellInfo.iconTintColor
                        )
                        cell.selectionStyle = .none
                    default:
                        if case .url = cellInfo.tapAction {
                            cell.set(
                                title: cellInfo.title,
                                text: cellInfo.subtitle,
                                kind: .link,
                                icon: cellInfo.icon,
                                iconTintColor: cellInfo.iconTintColor
                            )
                        } else {
                            cell.set(
                                title: cellInfo.title,
                                text: cellInfo.subtitle,
                                kind: .text,
                                icon: cellInfo.icon,
                                iconTintColor: cellInfo.iconTintColor
                            )
                        }
                        cell.selectionStyle = .none
                }
                return cell
            case .telemedicine:
                let cell = tableView.dequeueReusableCell(InsuranceOptionalFeatureCell.id)
                cell.selectionStyle = .none
                configureOptionalFeatureCell(
                    cell: cell,
                    title: NSLocalizedString("telemedicine_cell_title", comment: ""),
                    description: NSLocalizedString("telemedicine_cell_description", comment: ""),
                    buttonTitle: NSLocalizedString("telemedicine_get_details", comment: ""),
                    action: { [weak self, cell] in
                        self?.handleAction(.telemedicine, cell: cell)
                    }
                )
                return cell
            case .vzrOnOff:
                let cell = tableView.dequeueReusableCell(InsuranceVzrOnOffCell.id)
                cell.selectionStyle = .none
                refreshVzrOnOffCell(cell)
                vzrOnOffCell = cell
                return cell
            case .flatOnOff:
                let cell = tableView.dequeueReusableCell(InsuranceFlatOnOffCell.id, indexPath: indexPath)
                cell.selectionStyle = .none
                refreshFlatOnOffCell(cell)
                flatOnOffCell = cell
                return cell
            case .kidsDoctorCall:
                let cell = tableView.dequeueReusableCell(InsuranceOptionalFeatureCell.id)
                cell.selectionStyle = .none
                configureOptionalFeatureCell(
                    cell: cell,
                    title: NSLocalizedString("medical_operator_call_cell_title", comment: ""),
                    description: NSLocalizedString("medical_operator_call_cell_description", comment: ""),
                    buttonTitle: NSLocalizedString("medical_operator_call_get_details", comment: ""),
                    action: { [weak self, cell] in
                        self?.handleAction(.kidsDoctorCall, cell: cell)
                    }
                )
                return cell
        }
    }

    private func shouldShowRedDot(for cellData: ActionCellData) -> Bool {
        if input.insurance.hasUnpaidBills, case .openBills = cellData.tapAction {
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch sections[indexPath.section] {
            case .dmsInsuranceInfo, .telemedicine, .vzrOnOff, .flatOnOff, .kidsDoctorCall:
                break
            case .action(let infoCells):
                handleAction(infoCells[indexPath.row].tapAction, cell: tableView.cellForRow(at: indexPath))
            case .info(_, let infoCells):
                handleAction(infoCells[indexPath.row].tapAction, cell: tableView.cellForRow(at: indexPath))
				
				if let infoField = infoCells[indexPath.row].infoField {
					output.medicalServiceTap(infoField)
				}
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if case .info(let title, _) = sections[section] {
            let view = UIView()
            let label = UILabel()
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
                label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -18)
            ])

            view.backgroundColor = .Background.background
            label <~ Style.Label.secondaryText
            label.text = title

            return view
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if case .info = sections[section] {
            return 44
        } else {
            return 0
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
