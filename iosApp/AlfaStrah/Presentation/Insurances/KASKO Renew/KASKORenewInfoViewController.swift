//
//  RenewInsuranceInfoViewController.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 12.09.17.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class KASKORenewInfoViewController: ViewController,
                                    InsurancesServiceDependency,
                                    LoyaltyServiceDependency,
                                    PolicyServiceDependency,
                                    UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var insurancesService: InsurancesService!
    var loyaltyService: LoyaltyService!
    var policyService: PolicyService!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var dataUsageAndPrivacyPolicyAgreementView: CommonUserAgreementView!
    @IBOutlet private var commonUserAgreementView: CommonUserAgreementView!
    @IBOutlet private var renewButton: RoundEdgeButton!
    @IBOutlet private var cashBackButton: RoundEdgeButton!
    @IBOutlet private var tableFooterView: UIView!
    @IBOutlet private var pointsUsageDescriptionLabel: UILabel!
    // не хочет красится template image
    @IBOutlet private var alfaIcon: UIImageView!
    @IBOutlet private var alfaPointsToSpendInput: UITextField!
    @IBOutlet private var pointsToSpendSlider: UISlider!
    @IBOutlet private var pointsToSpendMinLabel: UILabel!
    @IBOutlet private var pointsToSpendMaxLabel: UILabel!
    @IBOutlet private var userPointsLabel: UILabel!
    @IBOutlet private var bonusPointsGainedLabel: UILabel!
    @IBOutlet private var resultPriceLabel: UILabel!
    @IBOutlet private var cashbackTitleLabel: UILabel!
    @IBOutlet private var cashbackTextLabel: UILabel!

	@IBOutlet private var alfaPointsTitle: UILabel!
	@IBOutlet private var userPointsTitleLabel: UILabel!
	@IBOutlet private var bonusPointsGainedTitleLabel: UILabel!
	@IBOutlet private var resultPriceTitleLabel: UILabel!
	@IBOutlet private var pointsLabel: UILabel!
	
	struct Output {
        let linkTap: (URL) -> Void
    }

    var output: Output!

    private let headerID = String(describing: RMRTableSectionHeader.self)
    private let alfaSymbolPointsPlaceholder = "{ALFA_SYMBOL_POINTS}"

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
        var isImportant: Bool = false

        init(infoTitle: String, infoValue: String, isImportant: Bool = false) {
            self.infoTitle = infoTitle
            self.infoValue = infoValue
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
        var price: Int
        var maxPointsThatCanBeSpent: Int
        var bonusPointsGainedForRenew: Int
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
        accessory.title = self.renewButton.title(for: .normal)
        accessory.isEnabled = self.renewButton.isEnabled

        var frame = self.renewButton.bounds
        frame.size.height = 55
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
		
		alfaPointsTitle <~ Style.Label.secondaryText
		pointsUsageDescriptionLabel <~ Style.Label.secondarySubhead
		
		pointsToSpendMinLabel <~ Style.Label.secondaryCaption1
		pointsToSpendMaxLabel <~ Style.Label.secondaryCaption1
		
		userPointsLabel <~ Style.Label.primaryHeadline1
		userPointsTitleLabel <~ Style.Label.secondaryText
		
		bonusPointsGainedLabel <~ Style.Label.primaryHeadline1
		bonusPointsGainedTitleLabel <~ Style.Label.secondaryText
		
		resultPriceLabel <~ Style.Label.primaryHeadline1
		resultPriceTitleLabel <~ Style.Label.secondaryText
		
		pointsLabel <~ Style.Label.accentHeadline2

        forceTintInAlfaIcon()
        decoratePointsUsageDescriptionLabelText()
        renewButton.isEnabled = false

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: headerID, bundle: nil), forHeaderFooterViewReuseIdentifier: headerID)

        alfaPointsToSpendInput.inputAccessoryView = spendPointsInputAccessory
		alfaPointsToSpendInput.font = Style.Font.title1

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear),
            name: UIResponder.keyboardWillHideNotification, object: nil)

        renewButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        renewButton.setTitle(NSLocalizedString("kasko_renew_button_titile", comment: ""), for: .normal)
        cashBackButton <~ Style.RoundedButton.redBordered
        cashBackButton.setTitle(NSLocalizedString("kasko_renew_cashback_button_title", comment: ""), for: .normal)
        cashbackTitleLabel <~ Style.Label.primaryHeadline2
        cashbackTitleLabel.text = NSLocalizedString("kasko_renew_cashback_title", comment: "")
        cashbackTextLabel <~ Style.Label.primaryCaption1
        cashbackTextLabel.text = NSLocalizedString("kasko_renew_cashback_text", comment: "")

        setupCommonUserAgreementLinks()
        setupPrivacyPolicyAgreementLinks()
    }

    @objc private func keyboardWillAppear(_ notification: Notification) {
        guard
            let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
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

        insurancesService.renewPrice(insuranceID: insurance.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let object):
                    let renewPrice: Int = Int(object.price)
                    let canSpendAlfaPoints: Int = object.maxSpendPoints
                    let bonusPointsGained: Int = object.accrualPoints
                    self.loyaltyService.loyalty(useCache: false) { result in
                        hide {}
                        switch result {
                            case .success(let response):
                                let userPoints: Int = Int(response.amount)
                                let data = PriceAndPointsData(
                                    price: renewPrice,
                                    maxPointsThatCanBeSpent: canSpendAlfaPoints,
                                    bonusPointsGainedForRenew: bonusPointsGained,
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

    private var urlActivation: URL?
    private var urlInsurance: URL?

    private func getRenewUrlTerms(completion: @escaping (OsagoProlongationURLs) -> Void) {
        let hide = showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        insurancesService.renewUrlTerms(insuranceID: insurance.id) { [weak self] result in
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

    private func setupCommonUserAgreementLinks() {
        let activationLink: LinkArea = .init(
            text: NSLocalizedString("flat_on_off_terms_agreement_link", comment: ""),
            link: urlActivation
        ) { [weak self] url in
            guard let self = self
            else { return }

            if let url = url {
                self.output.linkTap(url)
                return
            }

            self.getRenewUrlTerms { [weak self] data in
                self?.urlActivation = data.urlActivation
                self?.urlInsurance = data.urlInsurance
                self?.output.linkTap(data.urlActivation)
            }
        }

        let insuranceLink: LinkArea = .init(
            text: NSLocalizedString("flat_on_off_agreement_insurance_terms_link", comment: ""),
            link: urlInsurance
        ) { [weak self] url in
            guard let self = self
            else { return }

            if let url = url {
                self.output.linkTap(url)
                return
            }

            self.getRenewUrlTerms { [weak self] data in
                self?.urlActivation = data.urlActivation
                self?.urlInsurance = data.urlInsurance
                self?.output.linkTap(data.urlInsurance)
            }
        }

        commonUserAgreementView.set(
            text: NSLocalizedString("flat_on_off_agreement_terms_text", comment: ""),
            links: [ activationLink, insuranceLink ],
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
                self.output.linkTap(url)
                return
            }

            self.getPrivacyPolicyUrls { [weak self] urls in
                self?.personalDataUsageAndPrivacyPolicyURLs = urls
                self?.output.linkTap(urls.personalDataUsageUrl)
            }
        }

        let privacyPolicyLink = LinkArea(
            text: NSLocalizedString("privacy_policy_link", comment: ""),
            link: personalDataUsageAndPrivacyPolicyURLs?.privacyPolicyUrl
        ) { [weak self] url in
            
            guard let self = self
            else { return }

            if let url = url {
                self.output.linkTap(url)
                return
            }

            self.getPrivacyPolicyUrls { [weak self] urls in
                self?.personalDataUsageAndPrivacyPolicyURLs = urls
                self?.output.linkTap(urls.privacyPolicyUrl)
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

        self.policyService.getPersonalDataUsageTermsUrl(on: .kaskoProlongation) { [weak self] result in
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

    private func validateFields() {
        renewButton.isEnabled
            = dataUsageAndPrivacyPolicyAgreementView.userConfirmedAgreement
            && commonUserAgreementView.userConfirmedAgreement
    }

    private func updateModel(for insurance: Insurance, priceAndPointsData data: PriceAndPointsData) {
        var sections: [Section] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        var insuranceInfoSectionContents: [SectionContent] = []
        let renewPrice = SectionContent(infoTitle: "Цена за пролонгацию полиса", infoValue: "\(data.price) ₽", isImportant: true)
        insuranceInfoSectionContents.append(renewPrice)

        let validUntilString = "с \(dateFormatter.string(from: insurance.startDate)) до \(dateFormatter.string(from: insurance.endDate))"
        insuranceInfoSectionContents.append(SectionContent(infoTitle: "Срок действия полиса", infoValue: validUntilString))

        let infoSection = Section(title: "Информация о полисе", contents: insuranceInfoSectionContents)
        sections.append(infoSection)

        let groups = insurance.fieldGroupList
        var vehicleInfoIndex = 0
        if groups.endIndex != 0 {
            vehicleInfoIndex = groups.index(after: 0)
        }

        let group = groups[vehicleInfoIndex]

        // Необходимо показать первые два поля. Но не обязательно полей будет 2.
        let groupContents = group.fields.prefix(2).map { SectionContent(infoTitle: $0.title, infoValue: $0.text) }

        let newSection = Section(title: group.title, contents: groupContents)
        sections.append(newSection)

        model = Model(sections: sections)

        let maxPointsCanSpendValue = min(data.maxPointsThatCanBeSpent, data.userPoints)
        let price = data.price
        userPointsLabel.text = "\(data.userPoints)"
        pointsToSpendMaxLabel.text = "\(maxPointsCanSpendValue)"
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
    }

    private func forceTintInAlfaIcon() {
        guard let image = alfaIcon.image else { return }

        let tinted = image.tintedImage(withColor: Style.Color.Palette.red)
        alfaIcon.image = tinted
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

        let char = "α"
        let suffix = "-БАЛЛЫ"

        guard
            let attributedSubstring = pointsUsageDescriptionLabel.attributedText?.attributedSubstring(from: nsRange),
            let font = attributedSubstring.attribute(fontKey, at: 0, effectiveRange: nil) as? UIFont,
            let attributedText = pointsUsageDescriptionLabel.attributedText,
            let charFont = UIFont(name: "HelveticaNeue-Bold", size: font.pointSize)
        else { return }

        let newText = NSMutableAttributedString(attributedString: attributedText)
        let attrib: [NSAttributedString.Key: Any] = [ fontKey: charFont, NSAttributedString.Key.foregroundColor: Style.Color.main ]
        let alfaAttributed = NSAttributedString(string: char, attributes: attrib)
        let replacement = NSMutableAttributedString(attributedString: alfaAttributed)

        let suffAttrib = attributedSubstring.attributes(at: 0, effectiveRange: nil)
        let suffixAttributed = NSAttributedString(string: suffix, attributes: suffAttrib)
        replacement.append(suffixAttributed)

        newText.replaceCharacters(in: nsRange, with: replacement)
        pointsUsageDescriptionLabel.attributedText = newText
    }
	
    @IBAction private func showTermsOfUse() {
        guard let url = category.termsURL else { return }

        SafariViewController.open(url, from: self)
    }

    @IBAction private func renewInsurance(_ sender: UIButton)
    {
        let pointsToSpend = alfaPointsToSpendInput.text.flatMap { UInt($0) }
        let hide = showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: "")
        )

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

    @IBAction private func cashBackButtonTap(_ sender: UIButton) {
        let url = "http://alfadriver.ru/?utm_source=mp&utm_medium=prolong&utm_campaign=prolong_mp"
        SafariViewController.open(url, from: self)
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contents = model.sections[indexPath.section].contents[indexPath.row]

        let cell: UITableViewCell

        if contents.isImportant {
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
}
