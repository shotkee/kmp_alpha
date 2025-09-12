//
//  AddressInputViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 25.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class AddressInputViewController: ViewController,
                                  UITextFieldDelegate,
                                  UITableViewDelegate,
                                  UITableViewDataSource {
    enum Scenario {
        case autoEvent
        case interactiveSupportEvent
    }
    
    struct Input {
		let isDemo: Bool
        let scenario: Scenario
        let currentAddress: String?
    }

    struct Output {
        let enterAddress: (String, String, @escaping (Result<[GeoPlace], AlfastrahError>) -> Void) -> Void
        let selectAddress: (GeoPlace) -> Void
        let showMap: () -> Void
        let saveAddress: ((String) -> Void)?
    }

    @IBOutlet private var addressInputTextField: UITextField!
    @IBOutlet private var bottomHintLabel: UILabel!
    @IBOutlet private var clearButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var containerStackView: UIStackView!
    @IBOutlet private var noLocationFoundView: UIView!
    @IBOutlet private var noLocationTitleLabel: UILabel!
    @IBOutlet private var noLocationInfoLabel: UILabel!
    @IBOutlet private var noLocationButton: RoundEdgeButton!
    @IBOutlet private var noLocationButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var iconImageView: UIImageView!
    private let debouncer = Debouncer(milliseconds: 1000)
    private var places: [GeoPlace] = []
    private var isInitialSearch: Bool = true
    private var oldAdress: String = ""

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        oldAdress = input.currentAddress ?? ""
        setupUI()
        updateUI(addressInputTextField)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.contentInset.top = containerStackView.frame.height + 12
    }

    private func setupUI() {
        view.backgroundColor = .Background.backgroundContent
        
        tableView.backgroundColor = .clear
        
        switch input.scenario {
            case .autoEvent:
                title = NSLocalizedString("text_address_input_title", comment: "")
                bottomHintLabel.text = NSLocalizedString("text_address_input_hint_text", comment: "")
				if input.isDemo
				{
					noLocationInfoLabel.text = NSLocalizedString("questionnaire_text_address_input_not_found_info", comment: "")
					noLocationButton.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
					noLocationInfoLabel.isHidden = true
					noLocationTitleLabel.isHidden = true
					iconImageView.isHidden = true
				}
				else {
					noLocationInfoLabel.text = NSLocalizedString("text_address_input_not_found_info", comment: "")
					noLocationButton.setTitle(NSLocalizedString("text_address_input_select_on_map", comment: ""), for: .normal)
					noLocationInfoLabel.isHidden = false
					noLocationTitleLabel.isHidden = false
					iconImageView.isHidden = false
				}
                
            case .interactiveSupportEvent:
                title = NSLocalizedString("questionnaire_address_title", comment: "")
                bottomHintLabel.text = NSLocalizedString("questionnaire_text_address_input_hint_text", comment: "")
                noLocationInfoLabel.text = NSLocalizedString("questionnaire_text_address_input_not_found_info", comment: "")
                noLocationButton.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
                noLocationInfoLabel.isHidden = true
                noLocationTitleLabel.isHidden = true
                iconImageView.isHidden = true
				noLocationButton.isHidden = true
                
        }
        
        addressInputTextField.backgroundColor = .clear
        addressInputTextField.textColor = .Text.textPrimary
		addressInputTextField.font = Style.Font.text
        
        addressInputTextField.placeholder = NSLocalizedString("common_enter_address", comment: "")
        addressInputTextField.text = input.currentAddress
        addressInputTextField.becomeFirstResponder()
        
        bottomHintLabel <~ Style.Label.secondaryCaption1
        noLocationTitleLabel <~ Style.Label.primaryHeadline1
        noLocationTitleLabel.text = NSLocalizedString("text_address_input_not_found_title", comment: "")
        noLocationInfoLabel <~ Style.Label.secondaryText
        
        noLocationButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        noLocationButton.addTarget(self, action: #selector(notFoundTap(_:)), for: .touchUpInside)
        
        noLocationFoundView.backgroundColor = .Background.backgroundContent
        noLocationFoundView.isHidden = true
        
        tableView.registerReusableCell(AddressSuggestionCell.id)
        subscribeForKeyboardNotifications()
    }
    
    // MARK: - Keyboard notifications handling
    private func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        noLocationButtonBottomConstraint.constant = 6
    }
    
    func moveViewWithKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        else { return }
        
        let safeAreaInsetsBottom = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let spacing: CGFloat = safeAreaInsetsBottom > 0 ? -16 : 16
        let constraintConstant = keyboardHeight + spacing
        
        if  noLocationButtonBottomConstraint.constant != constraintConstant {
            noLocationButtonBottomConstraint.constant = constraintConstant
        }
    }

    private func updateUI(_ textField: UITextField) {
        let isTextEmpty = (textField.text ?? "").isEmpty
        bottomHintLabel.isHidden = !isTextEmpty
        clearButton.isHidden = isTextEmpty
		noLocationButton.isHidden = isTextEmpty

        guard !isInitialSearch else {
            isInitialSearch = false
            return
        }

        debouncer.debounce { [weak self] in
            guard let self = self else { return }

            self.searchAddress(textField: self.addressInputTextField)
        }
    }

    private func searchAddress(textField: UITextField) {
        guard let text = textField.text else { return }

        output.enterAddress(text, "virtualassistant") { [weak self] result in
            guard let self = self
            else { return }

            switch result {
                case .success(let places):
                    self.places = places
                case .failure(let error):
                    self.places = []
					if !self.input.isDemo
					{
						self.alertPresenter.show(alert: BasicNotificationAlert(text: error.displayValue ?? ""))
					}
            }
            self.tableView.reloadData()
            self.noLocationFoundView.isHidden = !self.places.isEmpty && self.oldAdress != text
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateUI(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressInputTextField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateUI(textField)
    }

    @IBAction private func addressInputEditingChanged(_ sender: UITextField) {
        updateUI(sender)
    }

    @IBAction private func addressInputDoneTap(_ sender: UITextField) {
        searchAddress(textField: sender)
    }

    @IBAction private func clearButtonTap(_ sender: UIButton) {
        addressInputTextField.text = nil
        updateUI(addressInputTextField)
    }

    @IBAction func notFoundViewTap(_ sender: UITapGestureRecognizer) {
        addressInputTextField.resignFirstResponder()
    }

    @objc private func notFoundTap(_ sender: UIButton) {
        switch input.scenario {
            case .autoEvent:
				if input.isDemo
				{
					guard let text = addressInputTextField.text
					else { return }
					
					output.saveAddress?(text)
				}
				else
				{
					output.showMap()
				}
            case .interactiveSupportEvent:
                guard let text = addressInputTextField.text
                else { return }
                output.saveAddress?(text)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.selectAddress(places[indexPath.row])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(AddressSuggestionCell.id)
        let place = places[indexPath.row]
        cell.set(street: place.title, city: place.description)
        return cell
    }
}

extension AddressInputViewController {
    enum Constants {
        static let distanceToKeyboard: CGFloat = is7IphoneOrLess ? -18 : 0
        static let is7IphoneOrLess: Bool = UIScreen.main.bounds.height <= 667.0
    }
}
