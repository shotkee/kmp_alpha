//
//  ProfileInfoInputView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/11/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class ProfileInfoInputView: UIView, UITextFieldDelegate {
    private enum Constants {
        static let defaultOffset: CGFloat = 16
    }

    enum InputViewType {
        case phone
        case email
    }

    struct Input {
        let title: String
        let info: String
        let inputViewType: InputViewType
    }

    struct Output {
        let data: (String) -> Void
    }

    var input: Input! {
        didSet {
            guard input != nil else { return }

            updateUI()
        }
    }
    var output: Output!

    private let titleLabel: UILabel = .init()
    private let infoTextField: UITextField = .init()
    private let separatorView: UIView = .init()
    private var textInputController: TextFieldController?

    @discardableResult override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()

        infoTextField.resignFirstResponder()
        return true
    }

    override var isFirstResponder: Bool {
        infoTextField.isFirstResponder
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(infoTextField)
        addSubview(separatorView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoTextField.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultOffset),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.defaultOffset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultOffset),
            infoTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            infoTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultOffset),
            infoTextField.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -18),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: infoTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        titleLabel <~ Style.Label.secondaryText
        separatorView.backgroundColor = Style.Color.Palette.lightGray
        backgroundColor = .clear
        infoTextField.font = Style.Font.headline1
    }

    private func updateUI() {
        titleLabel.text = input.title
        infoTextField.text = input.info
        switch input.inputViewType {
            case .email:
                infoTextField.keyboardType = .emailAddress
                infoTextField.delegate = self
            case .phone:
                infoTextField.keyboardType = .numberPad
                let formatter = PhoneNumberFormatter(predefinedAreaCode: 7, maxNumberLength: 10)
                textInputController = TextFieldController(textField: infoTextField, asYouTypeFormatter: formatter)
                textInputController?.onTextDidChange = { [weak self] textField in
                    self?.output.data(textField.text ?? "")
                }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        output.data(resultString)
        return true
    }
}
