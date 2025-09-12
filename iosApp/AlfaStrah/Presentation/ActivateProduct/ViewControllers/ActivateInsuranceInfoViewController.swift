//
//  ActivateInsuranceInfoViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/23/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ActivateInsuranceInfoViewController: ViewController {
    struct Input {
        let stepsCount: Int
        let currentStepIndex: Int
        let minimumDate: Date
    }

    struct Output {
        let showPrices: (_ completion: @escaping (Money) -> Void) -> Void
        let continueWithInsuranceInfo: (InsuranceActivateInsuranceInfo) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var productTitleLabel: UILabel!
    @IBOutlet private var stepInfoLabel: UILabel!
    @IBOutlet private var purchaseDateView: UIView!
    @IBOutlet private var purchaseDateLabel: UILabel!
    @IBOutlet private var insuranceNumberInput: FancyTextInput!
    @IBOutlet private var priceTitleLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var continueButton: RoundEdgeButton!
    @IBOutlet private var scrollViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet private var accessoryImageView: UIImageView!
	
	private let keyboardBehavior: KeyboardBehavior = .init()
    private var defaultInsets: UIEdgeInsets = .zero
    private var price: Money? {
        didSet {
            updateContinueButton()
        }
    }
    private var purchaseDate: Date? {
        didSet {
            updateContinueButton()
        }
    }

    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = AppLocale.currentLocale
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    private lazy var accessorySignUpButton: UIButton = {
        let button = UIButton(type: .custom)
        button <~ Style.Button.ActionRed(title: NSLocalizedString("common_next", comment: ""))
        button.frame = CGRect(x: 0, y: 0, width: 160, height: 52)
        button.addTarget(self, action: #selector(continueTap(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
        datePicker.locale = AppLocale.currentLocale
        datePicker.minimumDate = self.input.minimumDate
        datePicker.maximumDate = Date()
        return datePicker
    }()

    private lazy var datePickerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 216).with(priority: .required - 1),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        view.isHidden = true
        view.clipsToBounds = true
        return view
    }()

    private var isInsuranceNumberValid: Bool {
        let insuranceNumberString = insuranceNumberInput.textField.text ?? ""
        return !insuranceNumberString.isEmpty
    }

    private var isPurchaseDateValid: Bool {
        purchaseDate != nil
    }

    private var isPriceValid: Bool {
        price != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardBehavior.subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardBehavior.unsubscribe()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        priceLabel.text = nil
        productTitleLabel <~ Style.Label.primaryText
        stepInfoLabel <~ Style.Label.primaryText
        productTitleLabel.text = NSLocalizedString("activate_product_product_purchase_location", comment: "")
        stepInfoLabel.text = String(
            format: NSLocalizedString("activate_product_step", comment: ""),
            input.currentStepIndex, input.stepsCount
        )
        insuranceNumberInput.textField.inputAccessoryView = accessorySignUpButton
        insuranceNumberInput.textFieldPlaceholderText = NSLocalizedString("activate_product_product_number", comment: "")
        insuranceNumberInput.descriptionText = NSLocalizedString("activate_product_product_number", comment: "")
		insuranceNumberInput.textField.font = Style.Font.text
        insuranceNumberInput.onTextDidChange = { [weak self] _ in
            self?.updateContinueButton()
        }
        insuranceNumberInput.onEditingDidBegin = { [weak self] _ in
            guard let self = self else { return }

            if self.datePicker.isFirstResponder {
                self.toggleDatePickerVisibility()
            }
        }
		purchaseDateLabel.backgroundColor = .clear
        purchaseDateLabel <~ Style.Label.tertiaryText
        purchaseDateLabel.text = NSLocalizedString("activate_product_purchase_date", comment: "")
        purchaseDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(purchaseDateTap(_:))))
        priceTitleLabel <~ Style.Label.secondaryText
        priceLabel <~ Style.Label.primaryText

        let indexOfPicker = stackView.arrangedSubviews.firstIndex(of: purchaseDateView)?.advanced(by: 1) ?? 0
        stackView.insertArrangedSubview(datePickerContainerView, at: indexOfPicker)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:))))
        updateContinueButton()
        keyboardBehavior.animations = { [weak self] frame, _, _ in
            guard let self = self else { return }

            let frameInView = self.scrollView.convert(frame, from: nil)
            let bottomInset = max(self.scrollView.bounds.maxY - frameInView.minY, 0)
            var insets = self.defaultInsets
            insets.bottom = max(insets.bottom, bottomInset)
            self.scrollView.contentInset = insets
            self.scrollView.scrollIndicatorInsets = insets
            if self.datePicker.isFirstResponder {
                self.scrollView.scrollRectToVisible(self.datePicker.frame, animated: true)
            } else if self.insuranceNumberInput.isFirstResponder {
                self.scrollView.scrollRectToVisible(self.insuranceNumberInput.frame, animated: true)
            }
            self.continueButton.alpha = frame.height == 0 ? 0 : 1
        }
		
		continueButton.setTitle(NSLocalizedString("common_next", comment: ""), for: .normal)
		continueButton <~ Style.RoundedButton.redBackground
		accessoryImageView.image = .Icons.chevronSmallRight.tintedImage(withColor: .Icons.iconSecondary)
    }

    private func updateContinueButton() {
        let isEnabled = isPriceValid && isPurchaseDateValid && isInsuranceNumberValid
        continueButton.isEnabled = isEnabled
        accessorySignUpButton.isEnabled = isEnabled
    }

    private func toggleDatePickerVisibility() {
        UIView.animate(withDuration: 0.25) {
            self.datePickerContainerView.isHidden.toggle()
            self.datePickerContainerView.alpha = self.datePickerContainerView.isHidden ? 0 : 1
        }
    }

    @objc private func hideKeyboard(_ sender: Any?) {
        insuranceNumberInput.resignFirstResponder()
        datePickerContainerView.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.datePickerContainerView.isHidden = true
            self.datePickerContainerView.alpha = 0
        }
    }

    @objc private func dateSelected(_ datePicker: UIDatePicker) {
        purchaseDateLabel.text = dateFormatter.string(from: datePicker.date)
        purchaseDate = datePicker.date
    }

    @objc private func purchaseDateTap(_ sender: UITapGestureRecognizer) {
        toggleDatePickerVisibility()
        dateSelected(datePicker)
    }

    @IBAction private func priceTap(_ sender: UIButton) {
        datePicker.resignFirstResponder()
        if datePicker.isFirstResponder {
            toggleDatePickerVisibility()
        }
        output.showPrices { [weak self] money in
            guard let self = self else { return }

            self.price = money
            self.priceLabel.text = AppLocale.price(from: NSNumber(value: money.amount / 100))
        }
    }

    @IBAction func continueTap(_ sender: UIButton) {
        guard
            let price = price,
            let number = insuranceNumberInput.textField.text,
            let purchaseDate = purchaseDate
        else {
            return
        }

        let insuranceInfo = InsuranceActivateInsuranceInfo(price: price, insuranceNumber: number, purchaseDate: purchaseDate)
        output.continueWithInsuranceInfo(insuranceInfo)
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		let accessoryImage = accessoryImageView.image
		
		accessoryImageView.image = accessoryImage?.tintedImage(withColor: .Background.backgroundSecondary)
	}
}
