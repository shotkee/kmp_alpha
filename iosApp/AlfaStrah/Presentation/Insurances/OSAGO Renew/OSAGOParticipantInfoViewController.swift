//
//  OSAGOPartisipantInfoViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 26.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class OSAGOParticipantInfoViewController: ViewController {
    private lazy var scrollView: UIScrollView = .init(frame: .zero)
    private lazy var rootView: UIView = .init(frame: .zero)

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16

        return stack
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button <~ Style.Button.ActionRedRounded(title: NSLocalizedString("common_save", comment: ""))
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        button.isEnabled = false

        return button
    }()

    private var minimumAgeDate: Date? {
        guard let birthdayDate = input.participant.birthdayDate else { return nil }

        return CalendarDate(birthdayDate).dateByAdding(years: 16)?.date
    }

    private let textInputMinHeight: CGFloat = 50

    struct Input {
        var participant: OsagoProlongationParticipant
        var viewModel: OSAGORenewViewModel
    }

    struct Output {
        let saveParticipantTap: (OsagoProlongationParticipant) -> Void
        let enterAddress: (String, String?, @escaping (Result<[GeoPlace], AlfastrahError>) -> Void) -> Void
        let buyPolicy: (ViewController) -> Void
    }

    var output: Output!
    var input: Input!

    private var fieldsToEdit: [OsagoProlongationField] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailed = input.participant.detailed else { return }

        fieldsToEdit = detailed.fieldGroups.flatMap { $0.fields }
        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        view.addSubview(scrollView)
        view.addSubview(saveButton)

        scrollView.addSubview(rootView)
        rootView.addSubview(contentStackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        rootView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            rootView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            rootView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            rootView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            rootView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rootView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            contentStackView.topAnchor.constraint(equalTo: rootView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            contentStackView.rightAnchor.constraint(equalTo: rootView.rightAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 18),

            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupUI() {
        title = input.participant.detailed?.description
        view.backgroundColor = Style.Color.Palette.white

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12

        guard let detailed = input.participant.detailed else { return }

        detailed.fieldGroups.forEach { element in
            if let title = element.title {
                stackView.addArrangedSubview(createHeaderTitleSectionLabel(title))
            }

            stackView.addArrangedSubview(createCardView(with: element.fields))
        }

        contentStackView.addArrangedSubview(stackView)

        updateUI()
    }

    private func updateUI() {
        saveButton.isEnabled = fieldsToEdit.allSatisfy { $0.isReady }
    }

    private func createHeaderTitleSectionLabel(_ text: String) -> UILabel {
        let label: UILabel = .init(frame: .zero)
        label <~ Style.Label.primaryHeadline1
        label.numberOfLines = 1
        label.text = text

        return label
    }

    private func createCardView(with fields: [OsagoProlongationField]) -> CardView {
        let cardStackView = UIStackView()
        cardStackView.axis = .vertical
        cardStackView.spacing = 0

        fields.forEach {
            cardStackView.addArrangedSubview(createCommonView(with: $0))
        }

        return CardView(contentView: cardStackView)
    }

    private func createCommonView(with field: OsagoProlongationField) -> CommonNoteLabelView {
        let infoView: CommonNoteLabelView = .init()

        let originalField = input.viewModel.originalField(for: field)
        let canEdit = originalField?.hasError ?? false

        infoView.set(
            title: field.title,
            note: field.value ?? "",
            style: .center(canEdit ? UIImage(named: "right_arrow_icon_gray") : nil),
            margins: Style.Margins.defaultInsets,
            appearance: .regular,
            appearanceError: field.hasError ? .error : nil,
            validationRules: canEdit ? [ RequiredValidationRule(), NotSameValidationRule(originalField?.value ?? "") ] : []
        )

        infoView.validate()
        infoView.tapHandler = { [weak self] in
            guard canEdit, let field = self?.fieldsToEdit.first(where: { $0 == field })  else { return }

            self?.chooseActionType(with: field, infoView: infoView)
        }

        return infoView
    }

    // MARK: - Tap Actions Info View

    private func chooseActionType(with field: OsagoProlongationField, infoView: CommonNoteProtocol) {
        guard let data = field.data else { return }

        switch data {
            case .string(let data):
                openStringInputBottomView(with: field, data: data, infoView: infoView)
            case .date(let data):
                openDateInputBottomView(with: field, date: data, infoView: infoView)
            case .geo(let data):
                openGeoPlaceInputBottomView(with: field, data: data, infoView: infoView)
            case .driverLicense(let driverLicense):
                openDriverLicenseNumberInputBottomView(with: field, driverLicense: driverLicense, infoView: infoView)
        }
    }

    private func openStringInputBottomView(
        with field: OsagoProlongationField,
        data: String,
        infoView: CommonNoteProtocol
    ) {
        let controller: TextNoteInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: "",
            description: "",
            textInputTitle: "",
            textInputPlaceholder: "",
            initialText: data,
            showSeparator: true,
            validationRules: [ RequiredValidationRule() ],
            keyboardType: .default,
            textInputMinHeight: textInputMinHeight,
            charsLimited: .unlimited,
            scenario: .osagoParticipantInfo
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            text: { [unowned self] text in
                self.updateField(field, data: .string(text))
                self.updateInputView(infoView, text: text)
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func openDateInputBottomView(
        with field: OsagoProlongationField,
        date: Date = Date(),
        infoView: CommonNoteProtocol
    ) {
        let controller: DateInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: field.title,
            mode: .date,
            date: date,
            maximumDate: Date(),
            minimumDate: field.isDriverLicenseIssueDateField ? minimumAgeDate : nil
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },

            selectDate: { [unowned self] date in
                self.updateField(field, data: .date(date))
                self.updateInputView(infoView, text: AppLocale.dateString(date))
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func openGeoPlaceInputBottomView(
        with field: OsagoProlongationField,
        data: GeoPlace,
        infoView: CommonNoteProtocol
    ) {
        let controller: GeoPlaceInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            geoPlace: data
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] place in
                self.updateField(field, data: .geo(place))
                self.updateInputView(infoView, text: place.infoDescription)
                self.dismiss(animated: true)
            },
            enterAddress: output.enterAddress,
            buyPolicy: output.buyPolicy
        )

        showBottomSheet(contentViewController: controller)
    }

    private func openDriverLicenseNumberInputBottomView(
        with field: OsagoProlongationField,
        driverLicense: SeriesAndNumberDocument,
        infoView: CommonNoteProtocol
    ) {
        let controller: InputBottomViewController = .init()
        container?.resolve(controller)

        let seriaInput = InputBottomViewController.InputObject(
            text: driverLicense.series,
            placeholder: NSLocalizedString("osago_prolongation_driver_license_seria_placeholder", comment: ""),
            keyboardType: .default,
            validationRule: [ RequiredValidationRule() ]
        )

        let numberInput = InputBottomViewController.InputObject(
            text: driverLicense.number,
            placeholder: NSLocalizedString("osago_prolongation_driver_license_number_placeholder", comment: ""),
            keyboardType: .numberPad,
            validationRule: [ RequiredValidationRule() ]
        )

        controller.input = .init(
            title: NSLocalizedString("osago_prolongation_driver_license_title", comment: ""),
            infoText: nil,
            inputs: [ seriaInput, numberInput ]
        )
        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            },
            done: { [unowned self] result in
                let driverLicense = SeriesAndNumberDocument(series: result[seriaInput.id] ?? "", number: result[numberInput.id] ?? "")
                self.updateField(field, data: .driverLicense(driverLicense))
                self.updateInputView(infoView, text: driverLicense.description)
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func updateField(_ field: OsagoProlongationField, data: OsagoProlongationFieldData) {
        guard let index = fieldsToEdit.firstIndex(where: { $0 == field }) else { return }

        let hasError = input.viewModel.originalField(for: field)?.data == data

        var editField = fieldsToEdit[index]
        editField.setData(data, hasError: hasError)
        fieldsToEdit[index] = editField
    }

    private func updateInputView(_ infoView: CommonNoteProtocol, text: String) {
        infoView.updateText(text)
        infoView.validate()

        updateUI()
    }

    // MARK: - Button Actions

    @objc private func saveAction() {
        var editedParticipant = input.participant

        guard let detailed = input.participant.detailed, var editedParticipantDetailed = editedParticipant.detailed else { return }

        for (groupIndex, group) in detailed.fieldGroups.enumerated() {
            var editedFields: [OsagoProlongationField] = []
            for field in group.fields {
                if let editedField = fieldsToEdit.first(where: { $0 == field }) {
                    editedFields.append(editedField)
                } else {
                    editedFields.append(field)
                }
            }
            editedParticipantDetailed.fieldGroups[groupIndex].fields = editedFields
            editedParticipant.detailed = editedParticipantDetailed
        }

        output.saveParticipantTap(editedParticipant)
    }
}
