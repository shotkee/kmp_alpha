//
//  CreateInsuranceSearchRequestViewController.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 30.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import Legacy

// swiftlint:disable file_length

class CreateInsuranceSearchRequestViewController: ViewController, PhoneCallsServiceDependency, InsurancesServiceDependency,
        UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var phoneCallsService: PhoneCallsService!
    var insurancesService: InsurancesService!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var insuranceNumberInput: InsuranceDataTextInputView!
    @IBOutlet private var insuranceProductPickerView: SelectedInsuranceDataView!
    @IBOutlet private var insuranceIssueDateView: SelectedInsuranceDataView!
    @IBOutlet private var insuranceStartDateView: SelectedInsuranceDataView!
    @IBOutlet private var suggestView: UIView!
    @IBOutlet private var photoView: InsuranceDataPhotoView!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private var selectDateView: SelectDateView!
    @IBOutlet private var suggestLabel: UILabel!
    @IBOutlet private var exampleLabel: UILabel!
    @IBOutlet private var sendRequestButton: RoundEdgeButton!
	@IBOutlet private var headerLabel: UILabel!
	@IBOutlet private var noticeLabel: UILabel!
	
	private let keyboardBehavior: KeyboardBehavior = .init()
	
    var onSearchRequestSent: (() -> Void)?

    private struct Model {
        var productsAvailableForSearch: [InsuranceSearchPolicyProduct] = []
        var product: InsuranceSearchPolicyProduct? {
            didSet {
                insuranceNumber = nil
                date = nil
                image = nil
            }
        }
        var insuranceNumber: String?
        var date: Date?
        var image: UIImage?
        var shownFromMainMenu: Bool = false

        var isReady: Bool {
            let dateReady: Bool
            if let product = product, (product.isAccident || product.isDms) {
                dateReady = true
            } else {
                dateReady = date != nil
            }
            return product != nil && !(insuranceNumber?.isEmpty ?? true) && dateReady
        }
    }

    private var model: Model = Model()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		sendRequestButton <~ Style.RoundedButton.redBackground
		
		setupNoticeLabel()
		
        title = NSLocalizedString("search_insurance_title", comment: "")

        addZeroView()

        selectDateView.toggleDateMode()
        selectDateView.onDateSelected = { [unowned self] date in
            self.model.date = date
            let value = self.dateFormatter.string(from: date)
            self.insuranceStartDateView.set(state: .typeSelected(value: value))
            self.insuranceIssueDateView.set(state: .typeSelected(value: value))
			self.insuranceIssueDateView.isRequired = true
            self.selectDateView.isHidden = true
            self.updateSendRequestButton()
        }

        updateUI()

        keyboardBehavior.animations = { [weak self] frame, _, _ in
            guard let self = self else { return }

            self.scrollView.contentInset.bottom = frame.height
        }

        loadProducts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardBehavior.subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardBehavior.unsubscribe()
    }

    private func updateUI() {
        guard viewIfLoaded != nil else { return }

        selectDateView.isHidden = true
        insuranceNumberInput.textFieldInput.text = nil
        insuranceStartDateView.set(state: .empty)
        insuranceIssueDateView.set(state: .empty)
		insuranceIssueDateView.isRequired = true

        stackView.subviews.forEach { $0.removeFromSuperview() }

        switch model.product {
            case .none:
                configureDefaultSections()
            case .some(let product):
                if product.isDms {
                    configureDmsProductSections()
                } else if product.isAccident {
                    configureAccidentProductSections()
                } else {
                    configureProductSections()
                }
                suggestLabel.text = product.suggest
				suggestLabel.textColor = product.isOsago ? .Text.textAccent : .Text.textSecondary
				suggestLabel.font = Style.Font.headline2
                if let example = product.example {
					exampleLabel <~ Style.Label.secondaryText
                    exampleLabel.text = String(format: NSLocalizedString("insurance_search_example_value", comment: ""), example)
                }
                if product.isOsago {
                    insuranceNumberInput.textFieldInput.keyboardType = .decimalPad
                    insuranceNumberInput.maxCharacters = 10
                    insuranceNumberInput.validCharacters = CharacterSet.decimalDigits
                } else {
                    insuranceNumberInput.textFieldInput.keyboardType = .default
                    insuranceNumberInput.maxCharacters = nil
                    insuranceNumberInput.validCharacters = nil
                }
        }

        if model.image != nil {
            photoView.set(hasPhoto: true)
        }

        updateSendRequestButton()
    }
	
	private func setupNoticeLabel() {
		let noticeText = NSMutableAttributedString()
		
		let highlightedTextStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textAccent,
			.font: Style.Font.caption2
		]

		let highlightedText = NSLocalizedString("insurance_search_request_notice_highlighted_text", comment: "") <~ highlightedTextStyle
		noticeText.append(highlightedText)
		
		let textStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textSecondary,
			.font: Style.Font.caption2
		]
		
		noticeText.append(
			NSLocalizedString("insurance_search_request_notice_text", comment: "") <~ textStyle
		)
		noticeLabel.attributedText = noticeText
	}

    private func configureDefaultSections() {
		headerView.backgroundColor = .Background.background
        stackView.addArrangedSubview(headerView)
		
		let descriptionText = NSMutableAttributedString()
		
		let highlightedTextStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textAccent,
			.font: Style.Font.subhead
		]

		let highlightedText = NSLocalizedString("insurance_search_request_header_highlighted_text", comment: "") <~ highlightedTextStyle
		descriptionText.append(highlightedText)
		
		let textStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textSecondary,
			.font: Style.Font.subhead
		]
		
		descriptionText.append(
			NSLocalizedString("insurance_search_request_header_text", comment: "") <~ textStyle
		)
		headerLabel.attributedText = descriptionText
		
        stackView.addArrangedSubview(insuranceProductPickerView)
        stackView.addArrangedSubview(footerView)
    }

    private func configureProductSections() {
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(insuranceProductPickerView)
        stackView.addArrangedSubview(insuranceNumberInput)
        stackView.addArrangedSubview(suggestView)
        stackView.addArrangedSubview(insuranceIssueDateView)
        stackView.addArrangedSubview(selectDateView)
        stackView.addArrangedSubview(photoView)
        stackView.addArrangedSubview(footerView)
    }

    private func configureDmsProductSections() {
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(insuranceProductPickerView)
        stackView.addArrangedSubview(insuranceStartDateView)
        stackView.addArrangedSubview(selectDateView)
        stackView.addArrangedSubview(insuranceNumberInput)
        stackView.addArrangedSubview(suggestView)
        stackView.addArrangedSubview(photoView)
        stackView.addArrangedSubview(footerView)
    }

    private func configureAccidentProductSections() {
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(insuranceProductPickerView)
        stackView.addArrangedSubview(insuranceNumberInput)
        stackView.addArrangedSubview(suggestView)
        stackView.addArrangedSubview(photoView)
        stackView.addArrangedSubview(footerView)
    }

    private func updateSendRequestButton() {
        sendRequestButton.isEnabled = model.isReady
    }

    private func dummyDate(show: Bool) {
        if show {
            if !stackView.arrangedSubviews.contains(insuranceStartDateView) {
                insuranceStartDateView.set(state: .empty)
                stackView.insertArrangedSubview(insuranceStartDateView, at: 2)
            }
        } else {
            stackView.removeArrangedSubview(insuranceStartDateView)
            insuranceStartDateView.removeFromSuperview()
        }
    }

    private func loadProducts() {
        guard model.productsAvailableForSearch.isEmpty else { return }

        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()

        insurancesService.insuranceSearchPolicyProducts { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let products):
                    self.model.productsAvailableForSearch = products
                    if products.isEmpty {
                        let zeroViewModel = ZeroViewModel(
                            kind: .custom(
                                title: NSLocalizedString("search_insurance_no_products", comment: ""),
                                message: nil,
                                iconKind: .search
                            ),
                            buttons: [ .retry { [weak self] in self?.loadProducts() } ]
                        )
                        self.zeroView?.update(viewModel: zeroViewModel)
                        self.showZeroView()
                    } else {
                        self.hideZeroView()
                    }
                case .failure(let error):
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.loadProducts() }))
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
                    self.showZeroView()
            }
        }
    }

    @IBAction private func selectInsuranceProduct() {
        let title = NSLocalizedString("search_insurance_type", comment: "")
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        for product in model.productsAvailableForSearch {
            let productAction = UIAlertAction(title: product.title, style: .default) { [unowned self] _ in
                if let selectedProduct = self.model.product, selectedProduct == product {
                    return
                }

                self.model.product = product
                self.insuranceProductPickerView.set(state: .typeSelected(value: product.title))
				self.insuranceProductPickerView.isRequired = true
                self.updateUI()
            }
            actionSheet.addAction(productAction)
        }

        let cancel = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel, handler: nil)
        actionSheet.addAction(cancel)

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = insuranceProductPickerView
            popoverController.sourceRect = insuranceProductPickerView.bounds
        }
        actionSheet.popoverPresentationController?.sourceView = insuranceProductPickerView
        present(actionSheet, animated: true, completion: nil)
        cancelEditing()
    }

    @IBAction private func insuranceNumberDidBeginEditing() {
        selectDateView.isHidden = true
    }

    @IBAction func textFieldValueChanged(_ sender: InsuranceDataTextInputView) {
        let textFieldValue = sender.value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let value = (textFieldValue?.isEmpty ?? true) ? nil : textFieldValue

        switch sender {
            case insuranceNumberInput:
                model.insuranceNumber = value
            default:
                break
        }
        updateSendRequestButton()
    }

    @IBAction private func cancelEditing() {
        insuranceNumberInput.cancelEditing()
        selectDateView.isHidden = true
        view.endEditing(true)
    }

    @IBAction private func showDatePicker() {
        selectDateView.isHidden = !selectDateView.isHidden
        if !selectDateView.isHidden {
            view.layoutIfNeeded()
            scrollView.scrollRectToVisible(selectDateView.frame, animated: true)
        }
    }

    @IBAction private func photoViewTapped() {
        present(selectPhotoSourceActionSheet(), animated: true, completion: nil)
    }

    private func selectPhotoSourceActionSheet() -> UIAlertController {
        let other = model.image != nil
        let takePhotoString = other
            ? NSLocalizedString("search_insurance_take_other_photo", comment: "")
            : NSLocalizedString("search_insurance_take_photo", comment: "")
        let choosePhotoString = other
            ? NSLocalizedString("search_insurance_choose_other_photo", comment: "")
            : NSLocalizedString("search_insurance_choose_photo", comment: "")

        let takePhoto = UIAlertAction(title: takePhotoString, style: .default) { [unowned self] _ in
            self.takePhoto()
        }

        let pickPhoto = UIAlertAction(title: choosePhotoString, style: .default) { [unowned self] _ in
            self.choosePhoto()
        }

        let cancel = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel, handler: nil)

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(pickPhoto)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = photoView
            popoverController.sourceRect = photoView.bounds
        }
        return actionSheet
    }

    private func takePhoto() {
        Permissions.camera { [weak self] granted in
            if granted {
                self?.showCamera()
            }
        }
    }

    private func choosePhoto() {
        Permissions.photoLibrary(for: .readWrite) { [weak self] granted in
            if granted {
                self?.showGallery()
            }
        }
    }

    private func showGallery() {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    private func showCamera() {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self
        controller.allowsEditing = true
        present(controller, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let edited = info[.editedImage] as? UIImage {
            model.image = edited
        } else if let original = info[.originalImage] as? UIImage {
            model.image = original
        }

        dismiss(animated: true, completion: nil)
    }

    @IBAction private func sendRequest() {
        guard let productID = model.product?.id, let number = model.insuranceNumber else { return }

        let hide = showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
        insurancesService.insuranceSearchPolicyRequestCreate(
            policyId: "\(productID)",
            insuranceNumber: number,
            date: model.date,
            photo: model.image
        ) { [weak self] result in
            guard let self = self else { return }

            hide(nil)
            switch result {
                case .success(let responseMap):
                    self.process(createdRequest: responseMap.request, isNew: responseMap.isNew)
                case .failure(let error):
                    self.processError(error)
            }
        }
    }

    private func process(createdRequest: InsuranceSearchPolicyRequest, isNew: Bool) {
        let storyboard = UIStoryboard(name: "InsuranceSearchRequest", bundle: nil)
        let simpleAction = { [weak self] (controller: InsuranceSearchResultsViewController) -> Void in
            guard let self = self else { return }

            if self.model.shownFromMainMenu {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            } else {
                controller.dismiss(animated: true, completion: nil)
            }
        }
        switch (createdRequest.state, isNew) {
            case (.confirmed, _):
                let controller: InsuranceSearchResultsViewController = storyboard.instantiate(id: "CONFIRMED")
                controller.primaryAction = simpleAction
                navigationController?.pushViewController(controller, animated: true)
            case (.confirmedWithDelay, _):
                let controller: InsuranceSearchResultsViewController = storyboard.instantiate(id: "CONFIRMED_DELAY")
                controller.primaryAction = simpleAction
                navigationController?.pushViewController(controller, animated: true)
            case (.notFound, true):
                let controller: InsuranceSearchResultsViewController = storyboard.instantiate(id: "CONFIRMED_DELAY")
                controller.primaryAction = simpleAction
                controller.secondaryAction = { result in
                    result.navigationController?.popViewController(animated: true)
                }
                controller.loadViewIfNeeded() // TODO: Refactor this
                if let attributed = controller.attributedHint?.mutable {
                    getHumanReadableCallCenterPhone { phone in
                        let attributedPhoneString = NSMutableAttributedString(string: "\n\(phone)")
                        let nsRange = NSRange(location: 0, length: attributedPhoneString.length)
                        attributedPhoneString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: nsRange)
                        attributedPhoneString.addAttribute(.foregroundColor, value: Style.Color.Palette.gray, range: nsRange)
                        attributed.append(attributedPhoneString)
                        controller.set(attributedHint: attributed)
                    }
                }
                navigationController?.pushViewController(controller, animated: true)
            case (.wrongNumber, _):
                let controller: InsuranceSearchResultsViewController = storyboard.instantiate(id: "NUMBER_WRONG")
                controller.primaryAction = { result in
                    result.navigationController?.popViewController(animated: true)
                }
                controller.secondaryAction = simpleAction
                navigationController?.pushViewController(controller, animated: true)
            case (.personNotFound, _):
                let controller: InsuranceSearchResultsViewController = storyboard.instantiate(id: "PERSON_NOT_FOUND")
                controller.primaryAction = { result in
                    result.navigationController?.popViewController(animated: true)
                }
                controller.secondaryAction = simpleAction
                navigationController?.pushViewController(controller, animated: true)
            case (.processing, true), (.unconfirmed, true):
                let isWaiting = (model.product?.isDms ?? false) || (model.product?.isAccident ?? false)
                let controller: InsuranceSearchResultsViewController = storyboard.instantiate(id: "UNCONFIRMED_NEW_REQUEST")
                controller.toggleCheckBox(hidden: isWaiting ? true : false)
                controller.primaryAction = { [weak self, unowned controller] _ in
                    guard let self = self else { return }

                    if controller.checked {
                        // TODO: Search
                        let reqModel = SubscribeRequestModel(requestID: "\(createdRequest.id)")
                        let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
                        self.insurancesService.insuranceSearchPolicyRequestNotify(policyId: reqModel.requestID) { [weak self] subResult in
                            guard let self = self else { return }

                            hide(nil)
                            switch subResult {
                                case .success:
                                    simpleAction(controller)
                                case .failure(let error):
                                    self.processError(error)
                            }
                        }
                    } else {
                        simpleAction(controller)
                    }
                }

                controller.titleText = isWaiting
                    ? String(format: NSLocalizedString("search_insurance_request_success", comment: ""), createdRequest.insuranceNumber)
                    : NSLocalizedString("search_insurance_no_data", comment: "")

                let plannedDateString: String
                if isWaiting {
                    let dmsPlannedDays = 5
                    let plannedDate = Calendar.current.date(byAdding: .day, value: dmsPlannedDays, to: Date())
                    plannedDateString = plannedDate.flatMap { dateFormatter.string(from: $0) } ?? "–"
                } else {
                    if let minDate = createdRequest.plannedDateMin, let date = createdRequest.plannedDate {
                        let fromDateString = dateFormatter.string(from: minDate)
                        let toDateString = dateFormatter.string(from: date)
                        plannedDateString = "с \(fromDateString) по \(toDateString)"
                    } else if let date = createdRequest.plannedDate {
                        plannedDateString = dateFormatter.string(from: date)
                    } else {
                        plannedDateString = "–"
                    }
                }
                let hint = String(format: NSLocalizedString("search_insurance_planned_date_hint", comment: ""), plannedDateString)
                controller.hintText = hint

                navigationController?.pushViewController(controller, animated: true)
            case (.processing, false), (.unconfirmed, false), (.notFound, false):
                let controller: InsuranceSearchResultsViewController = storyboard.instantiate(id: "UNCONFIRMED_REQUEST_EXISTS")
                controller.primaryAction = simpleAction
                navigationController?.pushViewController(controller, animated: true)
        }
    }

    struct SubscribeRequestModel {
        var requestID: String

        var requestParameters: [String: Any] {
            [ "insurance_search_policy_request_id": requestID ]
        }
    }

    private func getHumanReadableCallCenterPhone(completion: @escaping (String) -> Void) {
        phoneCallsService.phoneListFromCallCenter { result in
            switch result {
                case .success(let phones):
                    let phone = phones.first?.humanReadable ?? Constants.defaultEmergencyPhone
                    completion(phone)
                case .failure:
                    completion(Constants.defaultEmergencyPhone)
                }
        }
    }

    private enum Constants {
        static let defaultEmergencyPhone: String = kRMRAlfaMainPhoneHumanReadable
    }
}

// swiftlint:enable file_length
