//
//  CircumstancesAccidentAddressInputViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 22.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class CircumstancesAccidentAddressViewController: EuroProtocolBaseViewController, EuroProtocolServiceDependency {
    private lazy var contentStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill

        return value
    }()

    private lazy var addressInputView: SmallValueCardView = {
        let value = SmallValueCardView()
        value.set(
            title: NSLocalizedString("insurance_euro_protocol_accident_address_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_accident_address_title", comment: ""),
            value: input.address,
            error: nil
        )

        value.tapHandler = { [unowned self] in
            self.openTextInputBottomViewController(
                with: value,
                title: NSLocalizedString("insurance_euro_protocol_accident_address_title", comment: ""),
                description: "",
                placeholder: NSLocalizedString("insurance_euro_protocol_accident_address_title", comment: "")
            ) { [unowned self] string in
                value.update(value: string)
                self.selectedAddress = string
                self.updateUI()
            }
        }

        return value
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        value.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        value <~ Style.RoundedButton.oldPrimaryButtonSmall

        return value
    }()

    private var selectedAddress: String?

    var euroProtocolService: EuroProtocolService!

    struct Output {
        let save: (_ address: String, _ completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
    }

    struct Input {
        var address: String?
    }

    var output: Output!
    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
        updateUI()

        euroProtocolService.subscribeForPermissionsStatusUpdates { [weak self] status in
            self?.handlePermissions(status: status)
        }.disposed(by: disposeBag)

        handlePermissions(status: euroProtocolService.permissionsStatus)
    }

    private func handlePermissions(status: EuroProtocolServicePermissionsStatus) {
        switch status {
            case .unknown, .cameraAccessRequired, .locationPermissionRequired, .photoStoragePermissionRequired:
                let permissionsCards = CommonPermissionsView.PermissionCardInfo.euroProtocolPermissions
                zeroView?.update(viewModel: .init(kind: .permissionsRequired(permissionsCards)))
                showZeroView()
            case .permissionsGranted:
                hideZeroView()
        }
    }

    private func commonSetup() {
        view.addSubview(contentStackView)
        view.addSubview(saveButton)

        contentStackView.addArrangedSubview(CardView(contentView: addressInputView))

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_accident_address_title", comment: "")
        selectedAddress = input.address
    }

    private func updateUI() {
        saveButton.isEnabled = selectedAddress != nil
    }

    private func openTextInputBottomViewController(
        with infoView: SmallValueCardView,
        title: String,
        description: String,
        placeholder: String,
        completion: @escaping (String) -> Void
    ) {
        let controller: TextAreaInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: title,
            description: description,
            textInputTitle: nil,
            textInputPlaceholder: placeholder,
            initialText: infoView.getValue(),
            validationRules: [ RequiredValidationRule() ],
            showValidInputIcon: true,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            charsLimited: .unlimited,
            showMaxCharsLimit: false
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            text: { [unowned self] result in
                completion(result)
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    @objc private func saveButtonAction() {
        guard let selectedAddress = selectedAddress else { return }

        let hide = showLoadingIndicator(message: NSLocalizedString("insurance_euro_protocol_accident_address_loading_info", comment: ""))

        output.save(selectedAddress) { [weak self] result in
            hide {}
            if case .failure(let error) = result {
                self?.processError(error)
            }
        }
    }
}
