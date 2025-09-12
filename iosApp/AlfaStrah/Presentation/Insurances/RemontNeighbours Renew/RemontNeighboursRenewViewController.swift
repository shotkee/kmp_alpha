//
//  RemontNeighboursRenewViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 6/11/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class RemontNeighboursRenewViewController: ViewController,
                                           InsurancesServiceDependency,
                                           LoyaltyServiceDependency,
                                           PolicyServiceDependency,
										   UITableViewDataSource,
										   UITableViewDelegate,
										   UITextFieldDelegate {
    var insurancesService: InsurancesService!
    var loyaltyService: LoyaltyService!
    var policyService: PolicyService!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var commonTermsUserAgreementView: CommonUserAgreementView!
    @IBOutlet private var dataUsageAndPrivacyPolicyAgreementView: CommonUserAgreementView!
    @IBOutlet private var renewButton: RMRRedSubtitleButton!
    @IBOutlet private var tableFooterView: UIView!
    @IBOutlet private var pointsUsageDescriptionLabel: UILabel!
    @IBOutlet private var alfaPointsToSpendInput: UITextField!
    @IBOutlet private var pointsToSpendSlider: UISlider!
    @IBOutlet private var pointsToSpendMinLabel: UILabel!
    @IBOutlet private var pointsToSpendMaxLabel: UILabel!
    @IBOutlet private var userPointsLabel: UILabel!
    @IBOutlet private var bonusPointsGainedLabel: UILabel!
    @IBOutlet private var bonusPointsGainedInfoLabel: UILabel!
    @IBOutlet private var bonusPointsGainedSeparatorView: UIView!
    @IBOutlet private var resultPriceLabel: UILabel!
	@IBOutlet private var pointsUsageTitleLabel: UILabel!
	@IBOutlet private var pointsLabel: UILabel!
	@IBOutlet var onYourAccountLabel: UILabel!
	@IBOutlet var totalPriceTitleLabel: UILabel!
	
	private var bonusViews: [UIView] {
        [ bonusPointsGainedLabel, bonusPointsGainedInfoLabel, bonusPointsGainedSeparatorView ]
    }
	private let headerID = String(describing: RMRTableSectionHeader.self)
    private let alfaSymbolPointsPlaceholder = "АльфаБаллы"
    private var errorEncountered: ((Error?) -> Void)?
    private var proceedToPayment: ((URL) -> Void)?

    private var personalDataUsageAndPrivacyPolicyURLs: PersonalDataUsageAndPrivacyPolicyURLs?

    private var insurance: Insurance! {
        didSet {
            guard let insurance = insurance else {
                tableView.reloadData()
                return
            }

            updateData(for: insurance)
        }
    }

    private var category: InsuranceCategory!

    private struct SectionContent {
        var infoTitle: String
        var infoValue: String
        var isImportant: Bool
        var isRisksListItem: Bool = false

        init(infoTitle: String, infoValue: String, isRisksListItem: Bool = false, isImportant: Bool = false) {
            self.infoTitle = infoTitle
            self.infoValue = infoValue
            self.isRisksListItem = isRisksListItem
            self.isImportant = isImportant
        }
    }

    private struct Section {
        var title: String
        var contents: [SectionContent]
    }

    private struct Model {
        var sections: [Section] = []
    }

    private struct PriceAndPointsData {
        var renewedInsuranceStartDate: Date
        var renewedInsuranceEndDate: Date
        var price: Int
        var maxPointsThatCanBeSpent: Int
        var bonusPointsGainedForRenew: Int
        var propertyRisks: [InsuranceProlongationEstateRisk]
        var userPoints: Int
    }

    private var priceAndPointsData: PriceAndPointsData?

    private var model: Model = Model() {
        didSet {
            tableView.reloadData()
        }
    }

    lazy var spendPointsInputAccessory: RMRRedSubtitleButton = {
        let accessory = RMRRedSubtitleButton(type: .custom)
        accessory.title = self.renewButton.title
        accessory.subtitle = self.renewButton.subtitle
        accessory.isEnabled = self.renewButton.isEnabled
		
		accessory.setTitleColor(.Text.textContrast, for: .normal)
		accessory.backgroundColor = .Background.backgroundAccent

        var frame = self.renewButton.bounds
        frame.size.height = 48
        accessory.frame = frame

        if let actions = self.renewButton.actions(forTarget: self, forControlEvent: .touchUpInside) {
            accessory.addTarget(self, action: #selector(renewInsurance(_:)), for: .touchUpInside)
        }

        return accessory
    }()

    func set(
        proceedToPayment: @escaping (URL) -> Void,
        errorEncountered: @escaping (Error?) -> Void
    ) {
        self.proceedToPayment = proceedToPayment
        self.errorEncountered = errorEncountered
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Пролонгация полиса"
		
		pointsUsageDescriptionLabel <~ Style.Label.secondarySubhead
		pointsUsageTitleLabel <~ Style.Label.secondaryText
		pointsLabel <~ Style.Label.primaryHeadline1
		pointsToSpendMinLabel <~ Style.Label.secondaryCaption1
		pointsToSpendMaxLabel <~ Style.Label.secondaryCaption1
		userPointsLabel <~ Style.Label.primaryHeadline1
		onYourAccountLabel <~ Style.Label.secondaryText
		totalPriceTitleLabel <~ Style.Label.secondaryText
		resultPriceLabel <~ Style.Label.primaryHeadline1

        decoratePointsUsageDescriptionLabelText()
        setupCommonUserAgreementLinks()
        setupPrivacyPolicyAgreementLinks()
        validateFields()

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: headerID, bundle: nil), forHeaderFooterViewReuseIdentifier: headerID)
		tableView.backgroundColor = .clear
		tableView.registerReusableHeaderFooter(RemontNeighboursRenewTableSectionHeader.id)

        alfaPointsToSpendInput.inputAccessoryView = spendPointsInputAccessory
		alfaPointsToSpendInput.font = Style.Font.title1

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
	
	private func setupRenewButton() {
		renewButton.layer.cornerRadius = 24
		renewButton.layer.masksToBounds = true
		
		renewButton.setTitleColor(.Text.textContrast, for: .normal)
		renewButton.setBackgroundImage(.from(color: .Background.backgroundAccent), for: .normal)
		
		renewButton.setTitleColor(.Text.textContrast, for: .highlighted)
		renewButton.setBackgroundImage(.from(color: .States.backgroundAccentPressed), for: .highlighted)
		
		renewButton.setTitleColor(.Text.textContrast, for: .disabled)
		renewButton.setBackgroundImage(.from(color: .States.backgroundAccentDisabled), for: .disabled)
	}

    @objc private func keyboardWillAppear(_ notification: Notification) {
        guard let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }

        let accessory = alfaPointsToSpendInput.inputAccessoryView
        tableView.contentInset.bottom = endFrame.size.height + (accessory?.bounds.size.height ?? 0)
    }

    @objc private func keyboardWillDisappear() {
        tableView.contentInset.bottom = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let insurance = insurance {
            updateData(for: insurance)
        }
		
		setupRenewButton()
    }

    func set(insurance: Insurance, category: InsuranceCategory) {
        self.insurance = insurance
        self.category = category
    }

    private var isUpdating: Bool = false

    private func updateData(for insurance: Insurance) {
        guard isUpdating == false else { return }

        isUpdating = true

        let hide = showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        insurancesService.renewPriceProperty(insuranceID: insurance.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let propertyRenewCalc):
                    self.loyaltyService.loyalty(useCache: false) { result in
                        hide {}
                        switch result {
                            case .success(let response):
                                let userPoints = Int(response.amount)
                                let data = PriceAndPointsData(
                                    renewedInsuranceStartDate: propertyRenewCalc.startDate,
                                    renewedInsuranceEndDate: propertyRenewCalc.endDate,
                                    price: propertyRenewCalc.price,
                                    maxPointsThatCanBeSpent: propertyRenewCalc.maxSpendPoints,
                                    bonusPointsGainedForRenew: propertyRenewCalc.accrualPoints,
                                    propertyRisks: propertyRenewCalc.risks,
                                    userPoints: userPoints
                                )
                                self.displayData(data)
                            case .failure(let error):
                                self.errorEncountered?(error)
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                        }
                    }
                case .failure(let error):
                    hide {}
                    self.errorEncountered?(error)
            }
        }
    }

    private func displayData(_ data: PriceAndPointsData) {
        priceAndPointsData = data
        updateModel(for: insurance, priceAndPointsData: data)
    }

    private func getRenewLink(pointsToSpend: UInt, completion: @escaping (URL) -> Void) {
        let hide = showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        insurancesService.renewInsurance(
            insuranceID: insurance.id,
            points: Int(pointsToSpend),
            agreedToPersonalDataPolicy: dataUsageAndPrivacyPolicyAgreementView.userConfirmedAgreement
        ) { [weak self] result in
            hide(nil)
            guard let self = self else { return }

            switch result {
                case.success(let url):
                    completion(url)
                case .failure(let error):
                    self.processError(error)
            }
        }
    }

    private func updateModel(for insurance: Insurance, priceAndPointsData data: PriceAndPointsData) {
        var sections: [Section] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        var insuranceInfoSectionContents: [SectionContent] = []
        let renewPrice = SectionContent(infoTitle: "Цена за пролонгацию полиса", infoValue: "\(data.price) ₽", isImportant: true)
        insuranceInfoSectionContents.append(renewPrice)

        let fromDate = dateFormatter.string(from: data.renewedInsuranceStartDate)
        let endDate = dateFormatter.string(from: data.renewedInsuranceEndDate)
        let validUntilString = "с \(fromDate) до \(endDate)"
        insuranceInfoSectionContents.append(SectionContent(infoTitle: "Срок действия полиса", infoValue: validUntilString))

        let infoSection = Section(title: "Информация о полисе", contents: insuranceInfoSectionContents)
        sections.append(infoSection)

        let insuredObjectContent = SectionContent(infoTitle: "Адрес", infoValue: insurance.insuredObjectTitle)
        let insuredObjectSection = Section(title: "Объект страхования", contents: [ insuredObjectContent ])
        sections.append(insuredObjectSection)

        if !data.propertyRisks.isEmpty {
            let risksContent = data.propertyRisks.map { riskItem in
                SectionContent(
                    infoTitle: riskItem.title,
                    infoValue: AppLocale.price(from: NSNumber(value: riskItem.limit)),
                    isImportant: false
                )
            }
            let risksSection = Section(title: "Предметы страхования и страховые суммы", contents: risksContent)
            sections.append(risksSection)
        }

        model = Model(sections: sections)

        let maxPointsCanSpendValue = min(data.maxPointsThatCanBeSpent, data.userPoints)
        let price = data.price
        userPointsLabel.text = "\(data.userPoints)"
        pointsToSpendMaxLabel.text = "\(maxPointsCanSpendValue)"
        pointsToSpendSlider.setThumbImage(UIImage(named: "insurance-slider-thumb"), for: .normal)
        pointsToSpendSlider.minimumValue = 0
        pointsToSpendSlider.maximumValue = Float(min(data.maxPointsThatCanBeSpent, data.userPoints))
        pointsToSpendSlider.value = Float(maxPointsCanSpendValue)
        alfaPointsToSpendInput.text = "\(maxPointsCanSpendValue)"
        bonusPointsGainedLabel.text = (maxPointsCanSpendValue == 0) ? "\(data.bonusPointsGainedForRenew)" : "0"
        resultPriceLabel.text = "\(price - maxPointsCanSpendValue)"

        if maxPointsCanSpendValue == 0 {
            alfaPointsToSpendInput.isEnabled = false
            pointsToSpendSlider.isEnabled = false
        }

        tableView.tableFooterView = tableFooterView
    }

    private func updateLabelsFor(sliderValue: Float) {
        guard let data = priceAndPointsData else { return }

        let points = Int(sliderValue)
        alfaPointsToSpendInput.text = "\(points)"
        bonusPointsGainedLabel.text = (Int(sliderValue) == 0) ? "\(data.bonusPointsGainedForRenew)" : "0"
        let price = data.price
        resultPriceLabel.text = "\(price - points)"
        bonusViews.forEach { $0.isHidden = !sliderValue.isEqual(to: 0) }
    }

    /// Заменяем "АльфаБаллы" на 𝛂-баллы
    private func decoratePointsUsageDescriptionLabelText() {
        guard
            let text = pointsUsageDescriptionLabel.text,
            let range = text.range(of: alfaSymbolPointsPlaceholder)
        else {
            return
        }

        let loc = text.distance(from: text.startIndex, to: range.lowerBound)
        let len = text.distance(from: range.lowerBound, to: range.upperBound)
        let nsRange = NSRange(location: loc, length: len)

        let fontKey = NSAttributedString.Key.font

        guard let attributedText = pointsUsageDescriptionLabel.attributedText else { return }

        let charFont = UIFont.boldSystemFont(ofSize: 15)
        let newText = NSMutableAttributedString(attributedString: attributedText)
        let attrib: [NSAttributedString.Key: Any] = [ fontKey: charFont ]
        let alfaAttributed = NSAttributedString(string: alfaSymbolPointsPlaceholder, attributes: attrib)
        let replacement = NSMutableAttributedString(attributedString: alfaAttributed)

        newText.replaceCharacters(in: nsRange, with: replacement)
        pointsUsageDescriptionLabel.attributedText = newText
    }

    private func setupCommonUserAgreementLinks() {
        let commonTermsLink = LinkArea(
            text: NSLocalizedString("remont_with_conditions", comment: ""),
            link: personalDataUsageAndPrivacyPolicyURLs?.personalDataUsageUrl
        ) { [weak self] _ in
            
            guard let self = self
            else { return }

            if let termsURL = self.category.termsURL {
                self.openUrl(termsURL)
                return
            }
        }

        commonTermsUserAgreementView.set(
            text: NSLocalizedString("remont_agreement_with_conditions", comment: ""),
            links: [ commonTermsLink ],
            handler: .init(
                userAgreementChanged: { [weak self] _ in
                    self?.validateFields()
                }
            )
        )
    }

    private func setupPrivacyPolicyAgreementLinks() {
        let personalDataUsageTermsLink = LinkArea(
            text: NSLocalizedString("personal_data_usage_terms_link", comment: ""),
            link: personalDataUsageAndPrivacyPolicyURLs?.personalDataUsageUrl
        ) { [weak self] url in
            
            guard let self = self
            else { return }

            if let url = url {
                self.openUrl(url)
                return
            }

            self.getPrivacyPolicyUrls { [weak self] urls in
                self?.personalDataUsageAndPrivacyPolicyURLs = urls
                self?.openUrl(urls.personalDataUsageUrl)
            }
        }

        let privacyPolicyLink = LinkArea(
            text: NSLocalizedString("privacy_policy_link", comment: ""),
            link: personalDataUsageAndPrivacyPolicyURLs?.privacyPolicyUrl
        ) { [weak self] url in
            guard let self = self
            else { return }

            if let url = url {
                self.openUrl(url)
                return
            }
            
            self.getPrivacyPolicyUrls { [weak self] urls in
                self?.personalDataUsageAndPrivacyPolicyURLs = urls
                self?.openUrl(urls.privacyPolicyUrl)
            }
        }

        dataUsageAndPrivacyPolicyAgreementView.set(
            text: NSLocalizedString("personal_data_usage_and_privacy_policy_agreement_checkbox_text", comment: ""),
            links: [ personalDataUsageTermsLink, privacyPolicyLink ],
            handler: .init(
                userAgreementChanged: { [weak self] _ in
                    self?.validateFields()
                }
            )
        )
    }

    private func getPrivacyPolicyUrls(completion: @escaping (PersonalDataUsageAndPrivacyPolicyURLs) -> Void) {
        let hide = self.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        self.policyService.getPersonalDataUsageTermsUrl(on: .goodNeighborsAndAlphaRemontProlongation) { [weak self] result in
            hide(nil)
            guard let self = self else { return }

            switch result {
                case.success(let data):
                    completion(data)
                case .failure(let error):
                    self.processError(error)
            }
        }
    }

    private func openUrl(_ url: URL) {
        SafariViewController.open(url, from: self)
    }

    private func validateFields() {
        renewButton.isEnabled
            = commonTermsUserAgreementView.userConfirmedAgreement
            && dataUsageAndPrivacyPolicyAgreementView.userConfirmedAgreement
    }

    @IBAction private func renewInsurance(_ sender: UIButton) {
        let pointsToSpend = alfaPointsToSpendInput.text.flatMap { UInt($0) }
        let hide = showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        insurancesService.renewInsurance(
            insuranceID: insurance.id,
            points: Int(pointsToSpend ?? 0),
            agreedToPersonalDataPolicy: dataUsageAndPrivacyPolicyAgreementView.userConfirmedAgreement
        ) { [weak self] result in
            hide(nil)
            guard let self = self else { return }

            switch result {
                case.success(let renewURL):
                    self.proceedToPayment?(renewURL)
                case .failure(let error):
                    self.errorEncountered?(error)
            }
        }
    }

    @IBAction private func pointsToSpendEditingChanged(_ textField: UITextField) {
        guard let text = textField.text, let points = Int(text), let data = priceAndPointsData else { return }

        let filtered = min(data.maxPointsThatCanBeSpent, min(data.userPoints, points))
        let fvalue = Float(filtered)
        pointsToSpendSlider.value = fvalue
        updateLabelsFor(sliderValue: fvalue)
        textField.text = "\(filtered)"
    }

    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        let newValue = ceilf(sender.value)
        updateLabelsFor(sliderValue: newValue)
        sender.value = newValue
    }

    // MARK: - UITableView data source

    func numberOfSections(in tableView: UITableView) -> Int {
        model.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.sections[section].contents.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contents = model.sections[indexPath.section].contents[indexPath.row]

        if contents.isRisksListItem {
            tableView.deselectRow(at: indexPath, animated: true)
            let alert = UIAlertController(
                title: nil,
                message: priceAndPointsData?.propertyRisks[indexPath.row].description,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: NSLocalizedString("common_ok_button", comment: ""), style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contents = model.sections[indexPath.section].contents[indexPath.row]

        let cell: UITableViewCell
        if contents.isRisksListItem {
            cell = tableView.dequeueReusableCell(AlfaPropertyListTableViewCell.reusable)
        } else if contents.isImportant {
            cell = tableView.dequeueReusableCell(AlfaImportantInfoTableViewCell.reusable)
        } else {
            cell = tableView.dequeueReusableCell(AlfaCommonInfoTableViewCell.reusable)
        }

        guard let infoCell = cell as? RenewInfoTableViewCell else {
            fatalError("\(type(of: self)).\(#function): Expected RenewInfoTableViewCell -> got \(cell)")
        }

        infoCell.set(infoTitle: contents.infoTitle, infoValue: contents.infoValue)

        return cell
    }

    // MARK: - UITableView delegate
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = tableView.dequeueReusableHeaderFooter(OneTextRowHeaderView.id)
		
		view.set(title: model.sections[section].title)
		
		return view
	}
	
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID)
        let size = header?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size?.height ?? 0
    }

    // MARK: UITextField delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.text = "\(Int(pointsToSpendSlider.value))"
        }
    }
	
	// MARK: - Dark theme support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		setupRenewButton()
	}
}

class RemontNeighboursRenewTableSectionHeader: UITableViewHeaderFooterView {
	static let id: Reusable<RemontNeighboursRenewTableSectionHeader> = .fromClass()
	
	private let titleLabel = UILabel()
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		setupUI()
	}
	
	private func setupUI() {
		titleLabel <~ Style.Label.secondaryText
		
		addSubview(titleLabel)
		
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate(
			NSLayoutConstraint.fill(
				view: titleLabel,
				in: self,
				margins: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
			)
		)
	}
	
	func set(title: String) {
		titleLabel.text = title
	}
}
