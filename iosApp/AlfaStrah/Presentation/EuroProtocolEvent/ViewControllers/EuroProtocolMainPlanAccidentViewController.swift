//
//  EuroProtocolMainPlanAccidentViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 01.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class EuroProtocolMainPlanAccidentViewController: EuroProtocolBaseViewController, EuroProtocolServiceDependency {
    enum Constatns {
        static let photosCount = 3
    }

    struct Input {
        let loadPhoto: (_ index: Int) -> UIImage?
    }

    struct Output {
        let addPhoto: (_ index: Int, @escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void) -> Void
        let removePhoto: (_ index: Int, @escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
        let nextScreen: () -> Void
    }

    var input: Input!
    var output: Output!

    var euroProtocolService: EuroProtocolService!

    private lazy var rootStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.spacing = 26

        return value
    }()

    private lazy var infoLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value <~ Style.Label.secondaryText
        value.textAlignment = .left
        value.numberOfLines = 0

        return value
    }()

    private lazy var nextButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_continue", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var pickerView: PhotoPickerView = {
        let value = PhotoPickerView()
        value.output = .init(
            selected: { [unowned self] index in self.addPhoto(index: index) },
            delete: { [unowned self] index, completion in self.deletePhoto(index: index, completion: completion) },
            photosPicked: { [unowned self] amount in
                self.nextButton.isEnabled = amount == Constatns.photosCount ? true : false
            }
        )
        return value
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
        addZeroView()

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
        view.addSubview(rootStackView)
        view.addSubview(nextButton)

        rootStackView.addArrangedSubview(infoLabel)
        rootStackView.addArrangedSubview(pickerView)

        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            rootStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
        title = NSLocalizedString("insurance_euro_protocol_main_accident_photo_title", comment: "")
        infoLabel.text = NSLocalizedString("insurance_euro_protocol_main_accident_photo_info", comment: "")

        pickerView.configure(
            type: .camera,
            size: .small,
            numberOfCards: Constatns.photosCount,
            shouldShowInfoString: true
        )

        for index in 0..<Constatns.photosCount {
            pickerView.set(input.loadPhoto(index), at: index)
        }
    }

    @objc private func nextButtonAction() {
        let viewController: InfoBottomViewController = .init()
        container?.resolve(viewController)

        viewController.input = .init(
            title: NSLocalizedString("insurance_euro_protocol_remove_car_title", comment: ""),
            description: NSLocalizedString("insurance_euro_protocol_remove_car_text", comment: ""),
            primaryButtonTitle: NSLocalizedString("common_continue", comment: ""),
            secondaryButtonTitle: nil
        )
        viewController.output = .init(
            close: { [weak self] in
                self?.dismiss(animated: true)
            },
            primaryAction: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.output.nextScreen()
                }
            }
        )

        showBottomSheet(contentViewController: viewController)
    }

    private func addPhoto(index: Int) {
        output.addPhoto(index) { [weak self] result in
            switch result {
                case .success(let image):
                    self?.pickerView.set(image, at: index)
                case .failure(let error):
                    switch error {
                        case .sdkError(.didCancelCamera):
                            break
                        default:
                            self?.handleError(error)
                    }
            }
        }
    }

    private func deletePhoto(index: Int, completion: @escaping (Bool) -> Void) {
        output.removePhoto(index) { result in
            switch result {
                case .success:
                    completion(true)
                default:
                    completion(false)
            }
        }
    }

    // MARK: - Handle Error

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        processError(error)

        return true
    }
}
