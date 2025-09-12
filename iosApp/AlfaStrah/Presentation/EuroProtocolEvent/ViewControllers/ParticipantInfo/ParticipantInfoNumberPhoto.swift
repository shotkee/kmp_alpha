//
//  ParticipantInfoNumberPhoto.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 14.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class ParticipantInfoNumberPhoto: EuroProtocolBaseViewController, EuroProtocolServiceDependency {
    struct Input {
        let loadPhoto: () -> UIImage?
        let addPhoto: (@escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void) -> Void
        let removePhoto: (@escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
    }

    struct Output {
        let finish: () -> Void
    }

    var input: Input!
    var output: Output!

    var euroProtocolService: EuroProtocolService!

    enum Constatns {
        static let photosCount = 1
    }

    private lazy var rootStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
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
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var pickerView: PhotoPickerView = {
        let value = PhotoPickerView()
        value.output = .init(
            selected: { [unowned self] _ in
                self.addPhoto()
            },
            delete: { [unowned self] _, _  in
                self.removePhoto()
            },
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
            rootStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_participant_info_photo_number_title", comment: "")
        infoLabel.text = NSLocalizedString("insurance_euro_protocol_participant_info_photo_number_info", comment: "")

        pickerView.configure(
            type: .camera,
            size: .small,
            numberOfCards: Constatns.photosCount,
            shouldShowInfoString: true
        )

        pickerView.set(input.loadPhoto(), at: 0)
    }

    @objc private func nextButtonAction() {
        output.finish()
    }

    private func addPhoto() {
        input.addPhoto { [weak self] result in
            switch result {
                case .success(let image):
                    self?.pickerView.set(image, at: 0)
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

    private func removePhoto() {
        input.removePhoto { [weak self] result in
            switch result {
                case .success:
                    self?.pickerView.set(nil, at: 0)
                case .failure(let error):
                    self?.handleError(error)
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
