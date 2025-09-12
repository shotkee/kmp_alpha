//
//  OtherVehicleDamagedPartViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 23.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class OtherVehicleDamagedPartViewController: EuroProtocolBaseScrollViewController, UITextFieldDelegate {
    struct Output {
        let save: (EuroProtocolVehiclePart) -> Void
    }

    var output: Output!

    private var partName: String?
    private var partDescription: String?

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var inputsStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.axis = .vertical
        return stack
    }()

    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label <~ Style.Label.secondaryText
        label.text = NSLocalizedString(
            "insurance_euro_protocol_damaged_part_other_vehicle_input_description",
            comment: ""
        )
        return label
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var nameTextField: UITextField = {
        let field = UITextField()
        field <~ Style.TextField.primaryText
        field.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString(
                "insurance_euro_protocol_damaged_part_other_vehicle_input_field_name",
                comment: ""
            ),
            attributes: Style.Label.secondaryText.textAttributes
        )
        field.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)
        field.returnKeyType = .done
        field.delegate = self
        return field
    }()

    private lazy var noteView: NoteView = {
        let note = NoteView()
        note.setPlaceholderLabelStyle(Style.Label.secondaryText)
        note.textView <~ Style.TextView.primaryText
        note.textView.isScrollEnabled = false
        note.text = nil
        note.placeholderText = NSLocalizedString(
            "insurance_euro_protocol_damaged_part_other_vehicle_input_field_description",
            comment: ""
        )
        note.textViewChangedCallback = { [unowned self] textView in
            self.partDescription = textView.text
            self.updateUI()
        }
        return note
    }()

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = Style.Color.background
        title = NSLocalizedString("insurance_euro_protocol_damaged_part_other_vehicle_title", comment: "")

        addBottomButtonsContent(saveButton)

        scrollContentView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(captionLabel)
        contentStackView.addArrangedSubview(inputsStackView)
        inputsStackView.addArrangedSubview(inputBoxView(with: nameTextField))
        inputsStackView.addArrangedSubview(inputBoxView(with: noteView))

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
                contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
                contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
                contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),

                saveButton.heightAnchor.constraint(equalToConstant: 48)
            ]
        )

        let onTap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(onTap)
        updateUI()
    }

    private func updateUI() {
        saveButton.isEnabled = partName != nil && partName != ""
    }

    private func inputBoxView(with content: UIView) -> UIView {
        let box = UIView()
        let separator = separatorView()
        box.addSubview(content)
        box.addSubview(separator)
        content.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: content,
                in: box,
                margins: .init(top: 18, left: 0, bottom: 18, right: 0)
            ) +
            [
                box.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
                separator.bottomAnchor.constraint(equalTo: box.bottomAnchor),
                separator.leadingAnchor.constraint(equalTo: box.leadingAnchor),
                separator.trailingAnchor.constraint(equalTo: box.trailingAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1),
            ]
        )
        return box
    }

    private func separatorView() -> HairLineView {
        let separator: HairLineView = .init(frame: .zero)
        separator.lineColor = Style.Color.Palette.lightGray
        return separator
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @objc private func nameChanged(_ field: UITextField) {
        partName = field.text
        updateUI()
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    @objc private func saveButtonAction() {
        guard let name = partName else { return }

        let part: EuroProtocolVehiclePart = .other(detailName: name, description: partDescription)
        output.save(part)
    }
}
